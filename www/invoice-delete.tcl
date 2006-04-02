ad_page_contract {
    Delete Invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_id
    {return_url:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_invoice_Delete]"
set context [list [list "invoice-list" "[_ invoices.iv_invoice_2]"] $page_title]

set confirm_options [list [list "[_ invoices.continue_with_delete]" t] [list "[_ invoices.cancel_and_return]" f]]

ad_form -name delete_confirm -action invoice-delete -export {return_url} -form {
    {invoice_id:key}
    {title:text(inform) {label "[_ invoices.Delete]"}}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value f}}
} -select_query_name {title} \
-on_submit {
    if {$confirmation} {
	db_dml mark_deleted {}
    }
} -after_submit {
    if {[empty_string_p $return_url]} {
	ad_returnredirect "invoice-list"
    } else {
	ad_returnredirect $return_url
    }
    ad_script_abort
}

ad_return_template
    
