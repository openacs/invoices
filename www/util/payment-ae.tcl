ad_page_contract {
    Form to add/edit Payment.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    payment_id:integer,optional
    {__new_p 0}
    {mode edit}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set has_submit 0
if {![info exists payment_id] || $__new_p} {
    set page_title "[_ invoices.iv_payment_Add]"
    set _payment_id 0
} else {
    if {$mode == "edit"} {
        set page_title "[_ invoices.iv_payment_Edit]"
    } else {
        set page_title "[_ invoices.iv_payment_View]"
        set has_submit 1
    }
    set _payment_id [content::item::get_latest_revision -item_id $payment_id]
}

set context [list [list "payment-list" "[_ invoices.iv_payment_2]"] $page_title]
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]

set currency_options [list]

ad_form -name iv_payment_form -action payment-ae -mode $mode -has_submit $has_submit -form {
    {payment_id:key}
}
    
ad_form -extend -name iv_payment_form -form {
    {title:text {label "[_ invoices.iv_payment_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_payment_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_payment_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_payment_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(payment_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(payment_id) -categorized_object_id $_payment_id -form_name iv_payment_form
}

ad_form -extend -name iv_payment_form -form {
	{invoice_id:integer {label "[_ invoices.iv_payment_invoice_id]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_payment_invoice_id_help]"}}
	{organization_id:integer {label "[_ invoices.iv_payment_organization_id]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_payment_organization_id_help]"}}
	{received_date:text {label "[_ invoices.iv_payment_received_date]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_payment_received_date_help]"}}
	{amount:integer {label "[_ invoices.iv_payment_amount]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_payment_amount_help]"}}
	{currency:text(select) {label "[_ invoices.iv_payment_currency]"} {options $currency_options} {help_text "[_ invoices.iv_payment_currency_help]"}}
} -new_request {
    set title ""
    set description ""
	set invoice_id ""
	set organization_id ""
	set received_date ""
	set amount ""
	set currency ""
} -edit_request {
    db_1row get_data {}
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(payment_id)]
} -new_data {
    db_transaction {
	set new_payment_rev_id [iv::payment::new  \
				    -title $title \
				    -description $description  \
				    -invoice_id $invoice_id \
				    -organization_id $organization_id \
				    -received_date $received_date \
				    -amount $amount \
				    -currency $currency ]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_payment_rev_id $category_ids
	}
    }
} -edit_data {
    db_transaction {
	set new_payment_rev_id [iv::payment::edit \
				    -payment_item_id $payment_id \
				    -title $title \
				    -description $description  \
				    -invoice_id $invoice_id \
				    -organization_id $organization_id \
				    -received_date $received_date \
				    -amount $amount \
				    -currency $currency ]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_payment_rev_id $category_ids
	}
    }
} -after_submit {
    ad_returnredirect payment-list
    ad_script_abort
}

ad_return_template
