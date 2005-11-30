ad_page_contract {
    Delete Payment.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    payment_id
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_payment_Delete]"
set context [list [list "payment-list" "[_ invoices.iv_payment_2]"] $page_title]

set confirm_options [list [list "[_ invoices.continue_with_delete]" t] [list "[_ invoices.cancel_and_return]" f]]

ad_form -name delete_confirm -action payment-delete -form {
    {payment_id:key}
    {title:text(inform) {label "[_ invoices.Delete]"}}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value f}}
} -select_query_name {title} \
-on_submit {
    if {$confirmation} {
	db_dml mark_deleted {}
    }
} -after_submit {
    ad_returnredirect "payment-list"
    ad_script_abort
}

ad_return_template
    
