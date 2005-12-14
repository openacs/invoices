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
set locale [lang::user::site_wide_locale -user_id $recipient_id]

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] $page_title]

if {$total_amount > 0} {
    # send invoice
    # set invoice_text "{[_ invoices.iv_invoice_email]}"
    set subject [lang::util::localize "#invoices.iv_invoice_email_subject#" $locale]
    set template "InvoiceTemplate"
    set file_title "Invoice_${invoice_nr}.pdf"
} elseif {[empty_string_p $parent_invoice_id]} {
    # send credit
    # set invoice_text "{[_ invoices.iv_invoice_credit_email]}"
    set subject [lang::util::localize "#invoices.iv_invoice_credit_email_subject#" $locale]
    set template "CreditTemplate"
    set file_title "Credit_${invoice_nr}.pdf"
} else {
    # send cancellation
    # set invoice_text "{[_ invoices.iv_invoice_cancel_email]}"
    set subject [lang::util::localize "#invoices.iv_invoice_cancel_email_subject#" $locale]
    set template "CancelTemplate"
    set file_title "Cancellation_${invoice_nr}.pdf"
}

set invoice_text [iv::invoice::parse_data -invoice_id $invoice_id -recipient_id $recipient_id -template $template -locale $locale]

set project_id [lindex [application_data_link::get_linked -from_object_id $invoice_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
    set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
} else {
    set return_url [export_vars -base invoice-list {organization_id}]
}

if {[empty_string_p $file_ids]} {
    set pdf_file [text_templates::create_pdf_from_html -html_content "$invoice_text"]
    if {![empty_string_p $pdf_file]} {
	set file_size [file size $pdf_file]
	set file_ids [cr_import_content -title $file_title -description "PDF version of <a href=[export_vars -base "/invoices/invoice-ae" -url {{mode display} invoice_id}]>this invoice</a>" $invoice_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
        set return_url [export_vars -base invoice-pdf {invoice_id {file_id $file_ids}}]
    }
} else {
    set return_url [export_vars -base invoice-list {organization_id}]
}

if {[empty_string_p [cc_email_from_party $recipient_id]]} {
    ad_return_error "No Recipient" "The recipient does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
}

ad_return_template
