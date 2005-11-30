ad_page_contract {
    List of Payments.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_payment_2]"
set context [list $page_title]
set package_id [ad_conn package_id]

set actions [list "[_ invoices.iv_payment_New]" payment-ae "[_ invoices.iv_payment_New2]"]

template::list::create \
    -name iv_payment \
    -key payment_id \
    -no_data "[_ invoices.None]" \
    -elements {
        title {
	    label {[_ invoices.iv_payment_1]}
	    link_url_eval {[export_vars -base "payment-ae" {payment_id {mode display}}]}
        }
        action {
	    display_template {<a href="@iv_payment.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_payment.delete_link@">#invoices.Delete#</a>}
	
        }
    } -actions $actions

db_multirow -extend {edit_link delete_link} iv_payment iv_payment {} {
    set edit_link [export_vars -base "payment-ae" {payment_id}]
    set delete_link [export_vars -base "payment-delete" {payment_id}]
}

ad_return_template
    
