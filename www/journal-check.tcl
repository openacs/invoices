ad_page_contract {
    Check before creation of journal

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2006-01-30
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_journal_check]"
set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]

set confirm_options [list [list "[_ invoices.continue_with_journal]" t] [list "[_ invoices.cancel_and_return]" f]]

ad_form -name journal_confirm -action journal-check -form {
    {user_id:key}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value f}}
} -edit_request {
} -on_submit {
} -after_submit {
    ad_returnredirect "journal-add"
    ad_script_abort
}

ad_return_template
