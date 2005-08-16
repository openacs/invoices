ad_page_contract {
    Form to send an invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    invoice_id:integer
    {file_ids ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_send]"

db_1row invoice_data {}

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] $page_title]

set invoice_text [iv::invoice::parse_data -invoice_id $invoice_id -recipient_id $recipient_id]

if {$total_amount > 0} {
    # send invoice
    set invoice_text "{[_ invoices.iv_invoice_email]}"
} elseif {[empty_string_p $parent_invoice_id]} {
    # send credit
    set invoice_text "{[_ invoices.iv_invoice_credit_email]}"
} else {
    # send cancellation
    set invoice_text "{[_ invoices.iv_invoice_cancel_email]}"
}

set party_ids [contact::util::get_employees -organization_id $organization_id]
set return_url [export_vars -base invoice-list {organization_id}]

set parties_new [list]
foreach party_id $party_ids {
    
    # Check if the party has a valid e-mail address
    if {![empty_string_p [cc_email_from_party $party_id]]} {
	lappend parties_new $party_id
    }
}

if {[empty_string_p $parties_new]} {
    ad_return_error "No Recipient" "None of the recipients has a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
} else {
    set party_ids $parties_new
}
ad_return_template
