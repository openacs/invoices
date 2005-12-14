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

db_multirow -extend {locale file_id file_title file_link template recipient} invoices invoices {}

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]
set contacts_p [apm_package_installed_p contacts]
set tracking_p [apm_package_installed_p "mail-tracking"]

multirow foreach invoices {
    set locale [lang::user::site_wide_locale -user_id $recipient_id]
    if { $contacts_p } {
	set recipient "<a href=\"[contact::url -party_id $recipient_id]\">[contact::name -party_id $recipient_id]</a>"
    } else {
	set recipient [person::name -person_id $recipient_id]
    }

    if {$total_amount > 0} {
	# send invoice
	set template "InvoiceTemplate"
	set file_title "Invoice_${invoice_nr}.pdf"
    } elseif {[empty_string_p $parent_invoice_id]} {
	# send credit
	set template "CreditTemplate"
	set file_title "Credit_${invoice_nr}.pdf"
    } else {
	# send cancellation
	set template "CancelTemplate"
	set file_title "Cancellation_${invoice_nr}.pdf"
    }

    # create invoice text from template
    set invoice_text [iv::invoice::parse_data -invoice_id $invoice_id -recipient_id $recipient_id -template $template -locale $locale]

    # create pdf from invoice text
    set pdf_file [text_templates::create_pdf_from_html -html_content "$invoice_text"]
    if {![empty_string_p $pdf_file]} {
	set file_size [file size $pdf_file]
	set file_id [cr_import_content -title $file_title -description "PDF version of <a href=[export_vars -base "/invoices/invoice-ae" -url {{mode display} invoice_id}]>this invoice</a>" $invoice_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]

	if { $tracking_p } {
	    set file_link [export_vars "/tracking/download/$file_title" {{version_id $file_id}}]
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
	    link_url_eval {@invoices.file_link@}
        }
	recipient {
	    label "[_ invoices.iv_invoice_recipient]"
	    display_template "@invoices.recipient;noquote@"
	}
    } -actions $actions -sub_class narrow \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars {return_url} \
    -html {width 100%} \
    -filters {organization_id {}}

ad_return_template
