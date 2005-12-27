ad_page_contract {
    Form to ask what invoice-documents are sent.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-24
} {
    invoice_id:integer
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_send]"

db_1row invoice_data {}

set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-ae {invoice_id}] "[_ invoices.iv_invoice_View]"] $page_title]

set rec_organization_id [contact::util::get_employee_organization -employee_id $recipient_id]
set rec_orga_revision_id [content::item::get_best_revision -item_id $rec_organization_id]
set invoice_copy [ams::value -attribute_name "invoice_copy" -object_id $rec_orga_revision_id]

set boolean_options [list [list "[_ invoices.yes]" 1] [list "[_ invoices.no]" 0]]

ad_form -name invoice_send -action invoice-send-1 -form {
    {invoice_id:key}
}

if {$organization_id != $rec_organization_id} {
    ad_form -extend -name invoice_send -form {
	{opening_p:text(radio) {label "[_ invoices.iv_invoice_opening_p]"} {options $boolean_options}}
    }
}

ad_form -extend -name invoice_send -form {
    {invoice_p:text(radio) {label "[_ invoices.iv_invoice_p]"} {options $boolean_options}}
    {copy_p:text(radio) {label "[_ invoices.iv_invoice_copy_p]"} {options $boolean_options}}
} -edit_request {
    set opening_p 1
    set invoice_p 0
    set copy_p [ad_decode $invoice_copy t 1 0]
    if {[empty_string_p $copy_p]} {
	set copy_p 0
    }
} -after_submit {
    ad_returnredirect [export_vars "invoice-send" {invoice_id opening_p invoice_p copy_p}]
    ad_script_abort
}

ad_return_template
