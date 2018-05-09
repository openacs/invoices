ad_page_contract {
    Display links to pdfs of selected invoices. Form to send or generate the invoices.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-09
} {
    invoice_id:integer,multiple
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_view]"

db_multirow -extend {locale file_id file_title file_link template contact} invoices invoices {}

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]
set contacts_p [apm_package_installed_p contacts]
set tracking_p [apm_package_installed_p "mail-tracking"]

multirow foreach invoices {
    set locale [lang::user::site_wide_locale -user_id $recipient_id]
    if { $contacts_p } {
	set contact "<a href=\"[contact::url -party_id $contact_id]\">[contact::name -party_id $contact_id]</a>"
    } else {
	set contact [person::name -person_id $contact_id]
    }

    if {$total_amount > 0} {
	# send invoice
	set document_type invoice
	set file_title [lang::util::localize "#invoices.file_invoice#_${invoice_nr}.pdf" $locale]
    } elseif {[empty_string_p $parent_invoice_id]} {
	# send credit
	set document_type credit
	set file_title [lang::util::localize "#invoices.file_invoice_credit#_${invoice_nr}.pdf" $locale]
    } else {
	# send cancellation
	set document_type cancel
	set file_title [lang::util::localize "#invoices.file_invoice_cancel#_${invoice_nr}.pdf" $locale]
    }

    # create pdf from invoice text
    # substitute variables in invoice text
    set document_file [lindex [iv::invoice::parse_data -invoice_id $invoice_id -types $document_type -email_text ""] 1]
    if {![empty_string_p $document_file]} {
	set file_size [file size $document_file]
	set file_id [contact::oo::import_oo_pdf -oo_file $document_file -printer_name "pdfconv" -title $file_title -parent_id $invoice_id]
	db_dml set_publish_status {}

	if { $tracking_p } {
	    set file_link [export_vars -base "/tracking/download/$file_title" {file_id}]
	}
    }
}

set return_url [export_vars -base invoice-list {organization_id}]
set actions [list]
set bulk_actions [list "[_ invoices.iv_invoice_send]" "invoices-send" "[_ invoices.iv_invoice_send]" "[_ invoices.iv_invoice_save]" "invoices-save" "[_ invoices.iv_invoice_save]"]

template::list::create \
    -name invoices \
    -key file_id \
    -no_data "[_ invoices.None]" \
    -elements {
	invoice_nr {
	    label {[_ invoices.iv_invoice_invoice_nr]}
	}
        title {
	    label {[_ invoices.iv_invoice_1]}
	    link_url_eval {[export_vars -base "invoice-ae" {invoice_id {mode display}}]}
        }
        file_title {
	    label {[_ invoices.iv_invoice_1]}
	    link_url_eval {$file_link}
        }
	contact {
	    label "[_ invoices.iv_invoice_contact]"
	    display_template "@invoices.contact;noquote@"
	}
    } -actions $actions -sub_class narrow \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars {return_url} \
    -html {width 100%} \
    -filters {organization_id {}}

ad_return_template
