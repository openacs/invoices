ad_library {
    Invoice procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::invoice {}

ad_proc -public iv::invoice::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-invoice_nr ""}
    {-parent_invoice_id ""}
    {-organization_id ""}
    {-recipient_id ""}
    {-total_amount ""}
    {-amount_sum ""}
    {-currency ""}
    {-paid_amount ""}
    {-paid_currency ""}
    {-due_date ""}
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Invoice
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_invoice_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_invoice} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_invoice} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list invoice_nr $invoice_nr] \
					 [list parent_invoice_id $parent_invoice_id] \
					 [list organization_id $organization_id] \
					 [list recipient_id $recipient_id] \
					 [list total_amount $total_amount] \
					 [list amount_sum $amount_sum] \
					 [list currency $currency] \
					 [list paid_amount $paid_amount] \
					 [list paid_currency $paid_currency] \
					 [list due_date $due_date] \
					 [list payment_days $payment_days] \
					 [list vat_percent $vat_percent] \
					 [list vat $vat] \
					 [list cancelled_p f] ] ]
    }

    return $new_id
}

ad_proc -public iv::invoice::edit {
    -invoice_item_id:required
    {-title ""}
    {-description ""}
    {-invoice_nr ""}
    {-parent_invoice_id ""}
    {-organization_id ""}
    {-recipient_id ""}
    {-total_amount ""}
    {-amount_sum ""}
    {-currency ""}
    {-paid_amount ""}
    {-paid_currency ""}
    {-due_date ""}
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Invoice
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $invoice_item_id \
			    -content_type {iv_invoice} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list invoice_nr $invoice_nr] \
					     [list parent_invoice_id $parent_invoice_id] \
					     [list organization_id $organization_id] \
					     [list recipient_id $recipient_id] \
					     [list total_amount $total_amount] \
					     [list amount_sum $amount_sum] \
					     [list currency $currency] \
					     [list paid_amount $paid_amount] \
					     [list paid_currency $paid_currency] \
					     [list due_date $due_date] \
					     [list payment_days $payment_days] \
					     [list vat_percent $vat_percent] \
					     [list vat $vat] \
					     [list cancelled_p f] ] ]
    }

    return $new_rev_id
}

ad_proc -public iv::invoice::data {
    -invoice_id:required
    -invoice_array:required
    -recipient_array:required
    -item_multirow:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with invoice data, invoice items
} {
    set package_id [ad_conn package_id]
    set date_format [lc_get formbuilder_date_format]
    set timestamp_format "$date_format [lc_get formbuilder_time_format]"

    upvar $invoice_array invoice
    upvar $recipient_array recipient

    # Get the invoice data
    db_1row get_data {} -column_array invoice
    set invoice(creator_name) "$invoice(first_names) $invoice(last_name)"
    set invoice(vat_percent) [format "%.1f" $invoice(vat_percent)]
    set invoice(vat) [format "%.2f" $invoice(vat)]
    set invoice(amount_sum) [format "%.2f" $invoice(amount_sum)]
    set invoice(amount_diff) [format "%.2f" [expr $invoice(total_amount) - $invoice(amount_sum)]]
    set invoice(total_amount) [format "%.2f" $invoice(total_amount)]
    set invoice(recipient_name) "$invoice(rep_first_names) $invoice(rep_last_name)"

    # Get recipient information
    set recipient(recipient_name) "$invoice(rep_first_names) $invoice(rep_last_name)"

    db_multirow -upvar_level 1 -extend {amount_sum amount_total category} $item_multirow invoice_items {} {
	set price_per_unit [format "%.2f" $price_per_unit]
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]]
	set rebate [format "%.1f" $rebate]
	set category [lang::util::localize [category::get_name $category_id]]
    }
}

ad_proc -public iv::invoice::parse_data {
    -invoice_id:required
    -recipient_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with invoice data, invoice items
} {
    set package_id [ad_conn package_id]
    set date_format [lc_get formbuilder_date_format]
    set timestamp_format "$date_format [lc_get formbuilder_time_format]"

    # Get the invoice data
    db_1row get_data {} -column_array invoice
    set invoice(creator_name) "$invoice(first_names) $invoice(last_name)"
    set invoice(vat_percent) [format "%.1f" $invoice(vat_percent)]
    set invoice(vat) [format "%.2f" $invoice(vat)]
    set invoice(amount_sum) [format "%.2f" $invoice(amount_sum)]
    set invoice(amount_diff) [format "%.2f" [expr $invoice(total_amount) - $invoice(amount_sum)]]
    set invoice(total_amount) [format "%.2f" $invoice(total_amount)]
    set name [contact::name -party_id $recipient_id]
    set first_names [lindex $name 0]
    set last_name [lindex $name 1]
    set rec_organization_id [contact::util::get_employee_organization -employee_id $invoice(recipient_id)]
    set mailing_address [contact::message::mailing_address -party_id $rec_organization_id -format "text/html"]
    set organization_name [contact::name -party_id $rec_organization_id]

    db_multirow -local -extend {amount_sum amount_total category} invoice_items invoice_items {} {
	set price_per_unit [format "%.2f" $price_per_unit]
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]]
	set rebate [format "%.1f" $rebate]
	set category [lang::util::localize [category::get_name $category_id]]
    }

    set file_url [parameter::get -parameter InvoiceTemplate]
    
    # We need to add the locale to the InvoiceTemplate name, but for the time being we don't care.
    if {![empty_string_p $file_url]} {
        set file [open $file_url]
        fconfigure $file -translation binary
        set content [read $file]

        # parse template and replace placeholders
        eval [template::adp_compile -string $content]
        set final_content $__adp_output
    } else {
        set final_content ""
    }

    return $final_content
}

ad_proc -public iv::invoice::text {
    -invoice_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Generate invoice text
} {
    iv::invoice::data -invoice_id $invoice_id -invoice_array invoice -item_multirow invoice_items

    set mail_text "
	[_ invoices.iv_invoice_recipient]: $invoice(recipient_name)<br>
	[_ invoices.iv_invoice_Title]: $invoice(title)<br>
	[_ invoices.iv_invoice_Description]: $invoice(description)<br>
	[_ invoices.iv_invoice_invoice_nr]: $invoice(invoice_nr)<br>
	[_ invoices.iv_invoice_due_date]: $invoice(due_date)<br>
        [_ invoices.iv_invoice_payment_days]: $invoice(payment_days)<br><ul>"

    template::multirow foreach invoice_items {

	set item_name "<li>$item_nr, $category<br>$title"
	if {![empty_string_p $description]} {
	    append item_name " ("
	    if {![empty_string_p $page_count]} {
		append item_name "$page_count [_ invoices.iv_offer_item_pages]; "
	    }
	    if {![empty_string_p $file_count]} {
		append item_name "$file_count [_ invoices.iv_offer_item_files]; "
	    }
	    append item_name "$description)"
	}
	append item_name "<br> $item_units x $price_per_unit $invoice(currency) = $amount_sum $invoice(currency)"
	if {$rebate > 0} {
	    append item_name " - $rebate% [_ invoices.iv_invoice_item_rebate] = $amount_total $invoice(currency)"
	}
	append item_name "</li>\n"

	append mail_text $item_name
    }

    append mail_text "</ul>"

    if {$invoice(amount_diff) < 0} {
	append mail_text "
	    [_ invoices.iv_invoice_amount_sum]: $invoice(amount_sum) $invoice(currency)<br>
	    [_ invoices.iv_invoice_amount_diff]: $invoice(amount_diff) $invoice(currency)<br>
	"
    }

    append mail_text "
	[_ invoices.iv_invoice_total_amount]: $invoice(total_amount) $invoice(currency)<br>
	[_ invoices.iv_invoice_vat]: $invoice(vat) $invoice(currency) ($invoice(vat_percent)%)
    "

    return $mail_text
}
