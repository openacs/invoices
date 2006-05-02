ad_page_contract {
    Form to add an invoice cancellation.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_id:integer,optional
    {organization_id:integer,optional ""}
    {parent_id:integer}
    {__new_p 0}
    {return_url:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set package_id [ad_conn package_id]
set user_id [auth::require_login]
permission::require_permission -party_id $user_id -object_id $package_id -privilege invoice_cancel
set date_format "YYYY-MM-DD"

set page_title "[_ invoices.iv_invoice_cancel_Add]"
set _invoice_id 0
set currency [iv::price_list::get_currency -organization_id $organization_id]
set organization_name [organizations::name -organization_id $organization_id]

set context [list [list "invoice-list" "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-add {organization_id}] "[_ invoices.iv_invoice_Add]"] $page_title]
array set container_objects [iv::util::get_default_objects -package_id $package_id]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

set language [lang::conn::language]
set currency_options [db_list_of_lists currencies {}]
set contact_options [db_list_of_lists cancellation_contacts {}]

set recipient_options {}
db_foreach cancellation_recipients {} {
    lappend recipient_options [list [contact::name -party_id $rec_id -reverse_order] $rec_id]
}
set recipient_options [lsort -dictionary $recipient_options]


ad_form -name iv_invoice_cancel_form -action invoice-cancellation -export {organization_id parent_id return_url} -form {
    {invoice_id:key}
    {organization_name:text(inform) {label "[_ invoices.iv_invoice_organization]"} {value $organization_name} {help_text "[_ invoices.iv_invoice_organization_help]"}}
    {contact_id:integer(select),optional {label "[_ invoices.iv_invoice_contact]"} {options $contact_options} {help_text "[_ invoices.iv_invoice_contact_help]"}}
    {recipient_id:integer(select),optional {label "[_ invoices.iv_invoice_recipient]"} {options $recipient_options} {help_text "[_ invoices.iv_invoice_recipient_help]"}}
    {title:text {label "[_ invoices.iv_invoice_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_invoice_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_invoice_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_invoice_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(invoice_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(invoice_id) -categorized_object_id $_invoice_id -form_name iv_invoice_cancel_form
}

ad_form -extend -name iv_invoice_cancel_form -form {
    {invoice_nr:text {label "[_ invoices.iv_invoice_invoice_nr]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_invoice_invoice_nr_help]"}}
    {currency:text(select) {mode display} {label "[_ invoices.iv_invoice_currency]"} {options $currency_options} {help_text "[_ invoices.iv_invoice_currency_help]"}}
    {due_date:text,optional {label "[_ invoices.iv_invoice_due_date]"} {html {size 12 maxlength 10 id sel1}} {help_text "[_ invoices.iv_invoice_due_date_help]"} {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]}}}
    {vat_percent:float(inform) {label "[_ invoices.iv_invoice_vat_percent]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_invoice_vat_percent_help]"} {after_html {%}}}
    {total_amount:float(inform),optional {label "[_ invoices.iv_invoice_total_amount]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_invoice_total_amount_help]"} {after_html $currency}}
}

ad_form -extend -name iv_invoice_cancel_form -new_request {
    db_1row parent_invoice_data {}

    set description ""
    set due_date [db_string today {}]
    set title "[_ invoices.iv_invoice_cancel_1] $parent_invoice_nr $organization_name $due_date"
    set invoice_nr [db_nextval iv_invoice_seq]
    set vat_percent [format "%.1f" $vat_percent]
    set total_amount [format "%.2f" $total_amount]
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(invoice_id)]
} -new_data {
    db_transaction {
	set total_amount [format "%.2f" [expr -1. * $total_amount]]
	set vat [expr $total_amount * $vat_percent / 100.]
	set vat [format "%.2f" $vat]

	set new_invoice_rev_id [iv::invoice::new \
				    -parent_invoice_id $parent_id \
				    -title $title \
				    -description $description  \
				    -invoice_nr $invoice_nr \
				    -organization_id $organization_id \
				    -contact_id $contact_id \
				    -recipient_id $recipient_id \
				    -amount_sum $total_amount \
				    -total_amount $total_amount \
				    -currency $currency \
				    -due_date $due_date \
				    -vat_percent $vat_percent \
				    -vat $vat]

	# add credit offer entry
	set parent_item_id [content::revision::item_id -revision_id $parent_id]
	db_1row get_credit_offer {}

	if {[db_0or1row get_old_credit {}] && $old_credit < 0.} {
	    # cancelled invoice has credit
	    set invoice_id [content::revision::item_id -revision_id $new_invoice_rev_id]
	    set total_credit [expr -1. * $old_credit]
	    set vat_credit [format "%.2f" [expr $total_credit * $vat_percent / 100.]]

	    # add new offer item
	    set credit_category_id [parameter::get -parameter "CreditCategory"]
	    set offer_item_rev_id [iv::offer_item::new \
				       -offer_id $credit_offer_rev_id \
				       -title $title \
				       -description $description \
				       -comment "" \
				       -item_nr $invoice_id \
				       -item_units $total_credit \
				       -price_per_unit 1 \
				       -rebate 0 \
				       -sort_order $invoice_id \
				       -vat $vat_credit]

	    category::map_object -object_id $offer_item_rev_id $credit_category_id
	}

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_invoice_rev_id $category_ids
	}

	db_dml mark_cancelled {}
    }
} -after_submit {
    if {[empty_string_p $return_url]} {
	ad_returnredirect [export_vars -base invoice-list {organization_id}]
    } else {
	ad_returnredirect $return_url
    }
    ad_script_abort
}

ad_return_template
