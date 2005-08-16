ad_page_contract {
    List of Invoices.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    {format:optional "normal"}
    {orderby:optional ""}
    {page_size:optional 25}
    {organization_id:optional "1302"}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_2]"
set context [list $page_title]

set row_list {invoice_nr {} title {} description {} total_amount {} creation_user {} creation_date {} due_date {} action {}}

ad_return_template
