ad_page_contract {
    List of Pricelists to choose/change the one of the customer.

    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-07-31
} {
    {price_list_id:integer,optional ""}
    {organization_id:integer}
    {delete_only:integer,optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set package_id [ad_conn package_id]
set contact_package_id [apm_package_id_from_key contacts]
set contact_master [parameter::get -parameter ContactMaster -package_id $contact_package_id]

set user_id [auth::require_login]

# set title of the page
set organization_name [contact::name -party_id $organization_id]
set page_title "$organization_name: "
append page_title [_ invoices.iv_price_list]

# set addition to the context (URL line) of the page: price-lists with link and this page without link
set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] $page_title]

set current_pricelist_name [content::item::get_title -item_id [iv::price_list::get_list_id -organization_id $organization_id -package_id $package_id]]

if {($price_list_id == "") && ($delete_only != 1)} {
    # - - - - - - - - - -
    # no price_list_id is provided, so let the user choose a new one
    # - - - - - - - - - -
    
    template::list::create \
	-name iv_pricelist_list \
	-key list_id \
	-no_data "[_ invoices.None]" \
	-elements {
	    title {
		label {[_ invoices.iv_price_list_1]}
		display_template {<a href="@iv_pricelist_list.list_url@">@iv_pricelist_list.title;noquote@</a>}
	    }
	    action {
		display_template {<a href="/invoices/price-list-choose?organization_id=$organization_id&price_list_id=@iv_pricelist_list.list_id@">\#invoices.ok\#</a>} 
	    }
	} 

    # the old one with del links here: display_template {<a href="/invoices/price-list-choose?organization_id=$organization_id&price_list_id=@iv_pricelist_lis\t.list_id@">\#invoices.ok\#</a>&nbsp;<a href="/invoices/price-list-choose?organization_id=$organization_id&price_list_id=@iv_pricelist_\list.list_id@&delete_only=1">\#invoices.Delete\#</a>} 

    db_multirow -extend {list_url} iv_pricelist_list iv_pricelist_list {} {
	set list_url [export_vars -base "price-list" {list_id organization_id}]
	if {$list_id == [parameter::get -parameter "DefaultPriceListID" -default ""]} {
	    append title "<font color=red> *</font>"
	}
    }



} else {
    # - - - - - - - - - -
    # a price_list_id was provided, so make this the new price list for the customer and remove the old one
    # - - - - - - - - - -
    set new_list_id $price_list_id

    # Get id of customer price list (or default)
    set old_list_id [iv::price_list::get_list_id -organization_id $organization_id -package_id $package_id]

    if {($new_list_id != $old_list_id) || ($delete_only == 1)} {
        if {[application_data_link::exist_link -object_id $organization_id -target_object_id $old_list_id]} {
	    # delete the link between the customer and the old price list
	    set object_id1 $organization_id
	    set object_id2 $old_list_id
	    db_dml iv_delete_application_data_link {}
        }

        if {($delete_only != 1) && ($new_list_id != "")} {
            # insert the link between the customer and the new price list
            application_data_link::new -this_object_id $organization_id -target_object_id $new_list_id
        }
    }
    ad_returnredirect "/invoices/price-list?organization_id=$organization_id" 
}    

ad_return_template
