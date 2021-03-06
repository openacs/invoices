ad_page_contract {
    Form to send an invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    invoice_id:integer
    {opening_p 0}
    {invoice_p 1}
    {copy_p 0}
    {file_ids ""}
    {return_url:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_send]"

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
    set invoice_text "#invoices.iv_invoice_email#"
    set subject [lang::util::localize "#invoices.iv_invoice_email_subject#" $locale]
    set invoice_title [lang::util::localize "#invoices.file_invoice#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types invoice
    }
} elseif {[empty_string_p $parent_invoice_id]} {
    # send credit
    set invoice_text "#invoices.iv_invoice_credit_email#"
    set subject [lang::util::localize "#invoices.iv_invoice_credit_email_subject#" $locale]
    set invoice_title [lang::util::localize "#invoices.file_invoice_credit#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types credit
    }
} else {
    # send cancellation
    set invoice_text "#invoices.iv_invoice_cancel_email#"
    set subject [lang::util::localize "#invoices.iv_invoice_cancel_email_subject#" $locale]
    set invoice_title [lang::util::localize "#invoices.file_invoice_cancel#_${invoice_nr}.pdf" $locale]
    if {$invoice_p} {
	lappend document_types cancel
    }
}

if {$copy_p} {
    lappend document_types invoice_copy
}

if {[empty_string_p [cc_email_from_party $contact_id]]} {
    ad_return_error "No Recipient" "The contact does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
    ad_script_abort
}

# substitute variables in invoice text
# and return the content of all necessary document files
# (opening, invoice/credit/cancellation, copy)
set documents [iv::invoice::parse_data -invoice_id $invoice_id -types $document_types -email_text $invoice_text]

set invoice_text [lindex $documents 0]

set project_id [lindex [application_data_link::get_linked -from_object_id $invoice_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
    # set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
} else {
    # set return_url [export_vars -base invoice-list {organization_id}]
}

set file_ids {}
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
	set file_id [contact::oo::import_oo_pdf -oo_file $document_file -printer_name "pdfconv" -title $file_title -parent_id $invoice_id]

	lappend file_ids $file_id
#	db_dml set_publish_status {}
    }
}

if {[llength $file_ids] > 0} {

    # an invoice has been generated.
    # Store this fact as "Billed" in the system.

    set project_id [lindex [application_data_link::get_linked -from_object_id $invoice_id -to_object_type content_item] 0]
    if {![empty_string_p $project_id]} {
	acs_object::get -object_id $project_id -array project
	set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
	# set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
    } else {
	# set return_url [export_vars -base invoice-list {organization_id}]
    }
    
    set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]
    set invoice_folder_id [fs::get_folder -name "invoices_${root_folder_id}" -parent_id $root_folder_id]
    if {[empty_string_p $invoice_folder_id]} {
	# use folder of party if no invoice-folder exists
	set invoice_folder_id $organization_id
    }

    db_transaction {
	# move files to invoice_folder
	foreach one_file $file_id {
	    application_data_link::new -this_object_id $invoice_id -target_object_id $one_file
	    db_dml set_publish_status_and_parent {}
	    db_dml set_context_id {}
	}

	# mark displayed pdf as sent
	iv::invoice::set_pdf_status -invoice_id $invoice_id -status "sent"

	if {$status == "new" || [empty_string_p $status]} {
	    iv::invoice::set_status -invoice_id $invoice_id -status "billed"
	}
    }
}

set cancel_url [export_vars -base invoice-list {organization_id}]

if {[empty_string_p $return_url]} { 
    set return_url [export_vars -base invoice-list {organization_id}]
}

ad_return_template
