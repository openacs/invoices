ad_page_contract {
    Form to add/edit Price List.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    list_id:integer,optional
    {__new_p 0}
    {mode edit}
    {organization_id:multiple ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set has_submit 0
set organization_values ""
if {![info exists list_id] || $__new_p} {
    set page_title "[_ invoices.iv_price_list_Add]"
    set _list_id 0
} else {
    if {$mode == "edit"} {
        set page_title "[_ invoices.iv_price_list_Edit]"
	set organization_values [application_data_link::get_linked -from_object_id $list_id -to_object_type organization]
    } else {
        set page_title "[_ invoices.iv_price_list_View]"
        set has_submit 1
    }
    set _list_id [content::item::get_latest_revision -item_id $list_id]
}

set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] $page_title]
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]

set language [lang::conn::language]

set currency_options [db_list_of_lists currencies {}]

ad_form -name iv_price_list_form -action price-list-ae -mode $mode -has_submit $has_submit -form {
    {list_id:key}
}
    
ad_form -extend -name iv_price_list_form -form {
    {title:text {label "[_ invoices.iv_price_list_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_price_list_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_price_list_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_price_list_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(list_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(list_id) -categorized_object_id $_list_id -form_name iv_price_list_form
}

if {[string eq "" $organization_id]} {
    set organization_options [db_list_of_lists organization_list {}]
    ad_form -extend -name iv_price_list_form -form {
	{organization_id:text(multiselect),optional,multiple {label "[_ invoices.iv_price_list_organization]"} {options $organization_options} {help_text "[_ invoices.iv_price_list_organization_help]"} {values {$organization_values}}}
    }
} else {
    set organization_name [contact::name -party_id [lindex $organization_id 0]]
    ad_form -extend -name iv_price_list_form -form {
	{organization_name:text(inform) {label "[_ invoices.iv_price_list_organization]"} {value $organization_name } {help_text "[_ invoices.iv_price_list_organization_help]"} }
	{organization_id:text(hidden)}
    }
}

ad_form -extend -name iv_price_list_form -form {
    {currency:text(select) {label "[_ invoices.iv_price_list_currency]"} {options $currency_options} {help_text "[_ invoices.iv_price_list_currency_help]"}}
    {credit_percent:float {label "[_ invoices.iv_price_list_credit_percent]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_price_list_credit_percent_help]"} {after_html {%}}}
} -new_request {
    set title ""
    set description ""
    set currency [parameter::get -parameter "DefaultCurrency" -default "EUR"]
    set credit_percent 0
} -edit_request {
    db_1row get_data {}
    set credit_percent [format "%.1f" $credit_percent]
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(list_id)]
} -new_data {
    db_transaction {
	set new_list_rev_id [iv::price_list::new  \
				 -title $title \
				 -description $description \
				 -currency $currency \
				 -credit_percent $credit_percent]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_list_rev_id $category_ids
	}
    }
} -edit_data {
    db_transaction {
	set new_list_rev_id [iv::price_list::edit \
				 -list_item_id $list_id \
				 -title $title \
				 -description $description \
				 -currency $currency \
				 -credit_percent $credit_percent]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_list_rev_id $category_ids
	}
    }
} -after_submit {
    if {[exists_and_not_null organization_id]} {
	db_1row new_list_id {}

	application_data_link::delete_links -object_id $new_list_id
	foreach o_id $organization_id {
	    # delete old link from organization to price list
	    foreach old_list_id [application_data_link::get_linked_content -from_object_id $o_id -to_content_type iv_price_list] {
		db_dml delete_forward_link {
		    delete from acs_data_links
		    where object_id_one = :o_id
		    and object_id_two = :old_list_id
		}
		db_dml delete_backward_link {
		    delete from acs_data_links
		    where object_id_one = :old_list_id
		    and object_id_two = :o_id
		}
	    }

	    application_data_link::new -this_object_id $new_list_id -target_object_id $o_id
	}
    }

    ad_returnredirect price-list-list
    ad_script_abort
}

ad_return_template
