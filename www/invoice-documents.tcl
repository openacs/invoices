ad_page_contract {
    List to display all invoice documents.

    @param opening_p
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    invoice_id:integer
    {opening_p 0}
    {invoice_p 1}
    {copy_p 0}
    {odt_p 0}
    {file_ids ""}
    {return_url:optional ""}
    {display_p 1}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_documents]"

db_1row invoice_data {}

# We are only getting the invoice_nr here.
if {[string eq $invoice_nr ""]} {
    set invoice_nr [db_nextval iv_invoice_seq]
    db_dml set_invoice_nr {}
}

set locale [lang::user::site_wide_locale -user_id $contact_id]

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] $page_title]

set document_types {}
if {$opening_p} {
    lappend document_types opening
}

if {$total_amount >= 0} {
    # send invoice
    set invoice_title [lang::util::localize "#invoices.file_invoice#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types invoice
    }
} elseif {[empty_string_p $parent_invoice_id]} {
    # send credit
    set invoice_title [lang::util::localize "#invoices.file_invoice_credit#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types credit
    }
} else {
    # send cancellation
    set invoice_title [lang::util::localize "#invoices.file_invoice_cancel#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types cancel
    }
}

if {$copy_p} {
    lappend document_types invoice_copy
}

# substitute variables in invoice text
# and return the content of all necessary document files
# (opening, invoice/credit/cancellation, copy)
set documents [iv::invoice::parse_data -invoice_id $invoice_id -types $document_types -email_text ""]

# We want to get the odt file only
if {$odt_p} {
    set file [lindex $documents 1]
    ad_returnredirect [export_vars -base "invoice.odt" -url {file}]
    ad_script_abort
}

multirow create documents file_id file_title file_url
set files {}
set documents [lreplace $documents 0 0]
foreach document_file $documents type $document_types {
    switch $type {
	opening {
	    set file_title [lang::util::localize "#invoices.file_invoice_opening#_${invoice_nr}.pdf" $locale]
	}
	invoice_copy {
	    set file_title [lang::util::localize "#invoices.file_invoice_copy#_${invoice_nr}.pdf" $locale]
	}
	default { set file_title $invoice_title }
    }

    if {![empty_string_p $document_file]} {
	set file_size [file size $document_file]
	util_unlist [contact::oo::import_oo_pdf -oo_file $document_file -printer_name "pdfconv" -title $file_title -parent_id $invoice_id -no_import] file_mime_type file_name

	lappend files $file_name
    }
}

set file_id [contact::oo::join_pdf -filenames $files -title $invoice_title -parent_id $invoice_id]
multirow append documents $file_id $invoice_title [export_vars -base "/tracking/download/$invoice_title" {file_id}]

# delete old files
foreach one_file $files {
    ns_unlink $one_file
}

if {[multirow size documents] > 0} {

    # an invoice has been generated.
    # Store this fact as "Billed" in the system.

    if {$status == "new" || [empty_string_p $status]} {
	iv::invoice::set_status -invoice_id $invoice_id -status "billed"
    }
    
    # move files to invoice_folder
    set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]
    set invoice_folder_id [fs::get_folder -name "invoices_${root_folder_id}" -parent_id $root_folder_id]
    if {[empty_string_p $invoice_folder_id]} {
	# use folder of party if no invoice-folder exists
	set invoice_folder_id $organization_id
    }

    application_data_link::new -this_object_id $invoice_id -target_object_id $file_id
    db_dml set_publish_status_and_parent {}
    db_dml set_context_id {}

}

if {[empty_string_p $return_url]} { 
    set return_url [export_vars -base invoice-list {organization_id}]
}

if {$display_p} {
    # mark displayed pdf as sent
    iv::invoice::set_pdf_status -invoice_id $invoice_id -status "sent"
} else {
    # if no display requested, mark pdf-file for joining
    # and redirect to return_url
    iv::invoice::set_pdf_status -invoice_id $invoice_id -status "created" -file_id $file_id

    ad_returnredirect $return_url
    ad_script_abort
}


set actions [list "[_ invoices.ok]" $return_url "[_ invoices.ok]"]

template::list::create \
    -name documents \
    -key file_id \
    -no_data "[_ invoices.None]" \
    -elements {
	file_id {
	    label {[_ invoices.iv_invoice_file]}
	    display_template {<a href="@documents.file_url@">@documents.file_title@</a>}
	}
    } -actions $actions -sub_class narrow

ad_return_template
