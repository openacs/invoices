ad_page_contract {
    List of Prices.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    {list_id:notnull}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
db_1row list_title {}
set page_title $list_title
set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] $page_title]

ad_return_template
