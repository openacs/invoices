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

set recipient_count [db_string count_recipients {} -default 0]

# check if at least one recipient found
if {[empty_string_p $recipient_count] || $recipient_count == 0} {
    ad_return_error "No Recipient" "There is not invoice recipient found."
    ad_script_abort
}

# check if more than one recipient found
if {$recipient_count > 1} {
    ad_return_error "Too many Recipients" "You can send invoices only to one recipient, not different ones."
    ad_script_abort
}

# standard mail text
db_1row invoice_data {}

set locale [lang::user::site_wide_locale -user_id $recipient_id]
set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]

set invoice_text "{[_ invoices.iv_invoice_email]}"
set subject [lang::util::localize "#invoices.iv_invoice_email_subject#" $locale]
set return_url [export_vars -base invoice-list {organization_id}]

if {[empty_string_p [cc_email_from_party $recipient_id]]} {
    ad_return_error "No Recipient" "The recipient does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
}

ad_return_template
