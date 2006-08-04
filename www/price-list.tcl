ad_page_contract {
    List of Prices.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    {list_id:integer,optional ""}
    {organization_id:integer,optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set package_id [ad_conn package_id]
set contact_package_id [apm_package_id_from_key contacts]
set contact_master [parameter::get -parameter ContactMaster -package_id $contact_package_id]

if {[empty_string_p $list_id]} {
    set list_id [iv::price_list::get_list_id -organization_id $organization_id -package_id $package_id]
}

set user_id [auth::require_login]
db_1row list_title {}
set page_title $list_title
set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] $page_title]

# ---
# show the organizations that uses this price list
# added 2006/07/31 by nfl
set organization_values ""
set organization_values [application_data_link::get_linked -from_object_id $list_id -to_object_type organization]
# the standard price list isn't linked, so the result will be empty (nfl 31.07.2006)

template::list::create \
    -name iv_customer_using_pricelist \
    -key customer_id \
    -elements {
        customer_no {
            label {}
        }
        customer_name {
            label {}
	    display_template {<a href="/contacts/@iv_customer_using_pricelist.customer_id@">@iv_customer_using_pricelist.customer_name@</a>}
        }
    } 

multirow create iv_customer_using_pricelist customer_id customer_no customer_name

foreach organization_id_new $organization_values {
    set organization_name [contact::name -party_id $organization_id_new]
    set organization_no [ams::value -object_id [content::item::get_best_revision -item_id $organization_id_new] -attribute_name client_id]
    multirow append iv_customer_using_pricelist $organization_id_new $organization_no $organization_name 
} 

# ---

ad_return_template
