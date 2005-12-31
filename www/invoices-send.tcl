ad_page_contract {
    Form to send multiple invoices in one email.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-10
} {
    file_id:integer,multiple
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_send]"

set contact_count [db_string count_contacts {} -default 0]

# check if at least one contact found
if {[empty_string_p $contact_count] || $contact_count == 0} {
    ad_return_error "No Recipient" "There is not invoice contact found."
    ad_script_abort
}

# check if more than one contact found
if {$contact_count > 1} {
    ad_return_error "Too many Contacts" "You can send invoices only to one contact, not different ones."
    ad_script_abort
}

# standard mail text
db_1row invoice_data {}

set locale [lang::user::site_wide_locale -user_id $contact_id]
set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]

# invoice contact data
contact::employee::get -employee_id $contact_id -array contact

set invoice_nrs {}
db_foreach invoice_nrs {} {
    lappend invoice_nrs $invoice_nr
}
set invoice_nrs [join $invoice_nrs ", "]

set invoice_text [lang::util::localize "#invoices.iv_invoices_email#" $locale]
set subject [lang::util::localize "#invoices.iv_invoices_email_subject#" $locale]
set return_url [export_vars -base invoice-list {organization_id}]

if {[empty_string_p [cc_email_from_party $contact_id]]} {
    ad_return_error "No Contact" "The contact does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
}

ad_return_template
