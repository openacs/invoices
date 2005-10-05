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

if {[empty_string_p $file_ids]} {
    set pdf_file [text_templates::create_pdf_from_html -html_content "$invoice_text"]
    if {![empty_string_p $pdf_file]} {
	set file_size [file size $pdf_file]
	set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]
	set invoice_folder_id [lindex [application_data_link::get_linked -from_object_id $root_folder_id -to_object_type content_folder] 0]

	set file_ids [cr_import_content -title "Invoice $invoice_id" -description "PDF version of <a href=[export_vars -base "/invoices/invoice-ae" -url {{mode display} invoice_id}]>this offer</a>" $invoice_folder_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
	application_data_link::new -this_object_id $invoice_id -target_object_id $file_ids
    }
}

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
