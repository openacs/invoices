ad_page_contract {
    Preview of an invoice

    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    @creation-date 2006-01-26
} {
    invoice_id:integer
    {invoice_p 1}
    {file_ids ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

db_1row invoice_data {}

set locale [lang::user::site_wide_locale -user_id $contact_id]

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] Preview]

set document_types {}

if {$total_amount >= 0} {
    # send invoice
    set invoice_title [lang::util::localize "#invoices.file_invoice#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	set document_types invoice
    } else {
	set document_types invoice_copy
    }
} elseif {[empty_string_p $parent_invoice_id]} {
    # send credit
    set invoice_title [lang::util::localize "#invoices.file_invoice_credit#_${invoice_nr}.pdf" $locale]
    set document_types credit
} else {
    # send cancellation
    set invoice_title [lang::util::localize "#invoices.file_invoice_cancel#_${invoice_nr}.pdf" $locale]
    set document_types cancel
}

# substitute variables in invoice text
# and return the content of all necessary document files
# (opening, invoice/credit/cancellation, copy)
set documents [iv::invoice::parse_data -invoice_id $invoice_id -types $document_types -email_text ""]
set documents [lreplace $documents 0 0]

set file_title $invoice_title

if {![empty_string_p $documents]} {
    set file_size [file size $documents]
    set file [contact::oo::import_oo_pdf -oo_file $documents -printer_name "pdfconv" -title $file_title -parent_id $invoice_id -no_import]
    ns_returnfile 200 [lindex $file 0] [lindex $file 1]
}
