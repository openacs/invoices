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

if {[empty_string_p $list_id]} {
    set list_id [iv::price_list::get_list_id -organization_id $organization_id -package_id $package_id]
}

set user_id [auth::require_login]
db_1row list_title {}
set page_title $list_title
set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] $page_title]

ad_return_template
