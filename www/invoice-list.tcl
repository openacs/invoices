ad_page_contract {
    List of Invoices.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    {format:optional "normal"}
    {orderby:optional ""}
    {page_size:optional 25}
    {organization_id ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]

# If there is no organization_id require admin permission on invoices
if {[string eq $organization_id ""]} {
    set package_id [ad_conn package_id]
    permission::require_permission -object_id $package_id -privilege "admin"
}

set page_title "[_ invoices.iv_invoice_2]"
set context [list $page_title]

set row_list {checkbox {} invoice_nr {} title {} description {} recipient {} total_amount {} creation_user {} creation_date {} due_date {} action {}}

ad_return_template
