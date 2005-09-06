ad_page_contract {
    List of Offers.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-18
} {
    {format:optional "normal"}
    {orderby:optional ""}
    {page_size:optional 25}
    {organization_id:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_2]"
set context [list $page_title]

set row_list {offer_nr {} title {} description {} comment {} project_id {} amount_total {} creation_user {} creation_date {} finish_date {} accepted_date {} action {}}

ad_return_template
