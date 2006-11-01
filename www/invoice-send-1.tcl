ad_page_contract {
    Form to ask what invoice-documents are sent.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-24
} {
    invoice_id:integer
    {return_url:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_send]"

db_1row invoice_data {}

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] $page_title]

# Get the organization for the invoice
# Default is the organization associated with the invoice
set rec_organization_id $organization_id

if {[person::person_p -party_id $recipient_id]} {
    set rec_organization_list [contact::util::get_employee_organization -employee_id $recipient_id]
    if {[llength $rec_organization_list] > 1} {
	if {[lsearch $rec_organization_list $organization_id] > -1} {
	    set rec_organization_id $organization_id
	} else {
	    set rec_organization_id [lindex $rec_organization_list 0]
	}
    }
} else {
    set rec_organization_id $recipient_id
}

# warn if invoice already got sent
set sent_p 0
if {$status eq "billed"} {
    set sent_p 1
}

set rec_orga_revision_id [content::item::get_best_revision -item_id $rec_organization_id]
set invoice_copy [ams::value -attribute_name "invoice_copy" -object_id $rec_orga_revision_id]

set boolean_options [list [list "[_ invoices.yes]" 1] [list "[_ invoices.no]" 0]]
set email_options [list [list "[_ invoices.invoice_email]" t] [list "[_ invoices.invoice_display]" f]]

#if {$pdf_status != "sent"} {
#    lappend email_options  [list "[_ invoices.invoice_for_join]" j]
#}

ad_form -name invoice_send -action invoice-send-1 -export {return_url} -form {
    {invoice_id:key}
}

if {$contact_id != $recipient_id} {
    ad_form -extend -name invoice_send -form {
	{opening_p:text(radio) {label "[_ invoices.iv_invoice_opening_p]"} {options $boolean_options}}
    }
}

ad_form -extend -name invoice_send -form {
    {invoice_p:text(radio) {label "[_ invoices.iv_invoice_p]"} {options $boolean_options}}
    {copy_p:text(radio) {label "[_ invoices.iv_invoice_copy_p]"} {options $boolean_options}}
    {email_p:text(radio) {label "[_ invoices.iv_invoice_email_p]"} {options $email_options}}
} -edit_request {
    set opening_p 0
    set invoice_p 1

    if {$pdf_status != "sent"} {
	set email_p j
    } else {
	set email_p f
    }

    set copy_p [ad_decode $invoice_copy t 1 0]
    if {[empty_string_p $copy_p]} {
	set copy_p 0
    }
    if {$sent_p} {
	# if invoice is already sent, let user send copy by default
	set invoice_p 0
	set copy_p 1
    }
} -after_submit {
    switch $email_p {
	t { ad_returnredirect [export_vars -base "invoice-send" {invoice_id opening_p invoice_p copy_p return_url}] }
	f { ad_returnredirect [export_vars -base "invoice-documents" {invoice_id opening_p invoice_p copy_p return_url}] }
	j { ad_returnredirect [export_vars -base "invoice-documents" {invoice_id opening_p invoice_p copy_p {display_p 0} return_url}] }
    }
	
    ad_script_abort
}

ad_return_template
