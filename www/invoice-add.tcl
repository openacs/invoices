ad_page_contract {
    Form to select projects to bill in a new Invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-09
} {
    {format:optional "normal"}
    {orderby:optional ""}
    {page_size:optional 25}
    {organization_id:integer}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set organization_name [organizations::name -organization_id $organization_id]
set page_title "[_ invoices.iv_invoice_Add]"
set context [list [list "invoice-list" "[_ invoices.iv_invoice_2]"] $page_title]

set row_list {checkbox {} project_id {} title {} description {} amount_open {} count_total {} count_billed {} creation_date {}}

ad_return_template
