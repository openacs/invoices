ad_library {
    Offer procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-18
}

namespace eval iv::offer {}

ad_proc -public iv::offer::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-comment ""}
    {-offer_nr ""}
    {-organization_id ""}
    {-amount_total ""}
    {-amount_sum ""}
    {-currency ""}
    {-finish_date ""}
    {-date_comment ""}
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
    {-credit_percent 0}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-18

    New Offer
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_offer_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_offer} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_offer} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list comment $comment] \
					 [list offer_nr $offer_nr] \
					 [list organization_id $organization_id] \
					 [list amount_total $amount_total] \
					 [list amount_sum $amount_sum] \
					 [list currency $currency] \
					 [list finish_date $finish_date] \
					 [list date_comment $date_comment] \
					 [list payment_days $payment_days] \
					 [list vat_percent $vat_percent] \
					 [list vat $vat] \
					 [list status new] \
					 [list credit_percent $credit_percent] ] ]
    }

    return $new_id
}

ad_proc -public iv::offer::edit {
    -offer_id:required
    {-title ""}
    {-description ""}
    {-comment ""}
    {-offer_nr ""}
    {-organization_id ""}
    {-amount_total ""}
    {-amount_sum ""}
    {-currency ""}
    {-finish_date ""}
    {-date_comment ""}
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
    {-credit_percent 0}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-18

    Edit Offer
} {
    db_transaction {
	set status [iv::offer::get_status -offer_id $offer_id]
	set old_rev_id [content::item::get_best_revision -item_id $offer_id]
	set new_rev_id [content::revision::new \
			    -item_id $offer_id \
			    -content_type {iv_offer} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list comment $comment] \
					     [list offer_nr $offer_nr] \
					     [list organization_id $organization_id] \
					     [list amount_total $amount_total] \
					     [list amount_sum $amount_sum] \
					     [list currency $currency] \
					     [list finish_date $finish_date] \
					     [list date_comment $date_comment] \
					     [list payment_days $payment_days] \
					     [list status $status] \
					     [list vat_percent $vat_percent] \
					     [list vat $vat] \
					     [list credit_percent $credit_percent] ] ]
	db_dml set_accepted_date {}
    }

    return $new_rev_id
}
    
ad_proc -public iv::offer::set_status {
    -offer_id:required
    {-status "new"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-04

    Edit Offer status
} {
    db_dml update_status {}
}

ad_proc -public iv::offer::get_status {
    -offer_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-04

    Get Offer status
} {
    db_1row offer_status {}
}

ad_proc -public iv::offer::accept {
    -offer_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-19

    Accept Offer
} {
    db_dml accept {}
}

ad_proc -public iv::offer::data {
    -offer_id:required
    -offer_array:required
    -item_multirow:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with offer data, offer items
} {
    set package_id [ad_conn package_id]
    set date_format [lc_get formbuilder_date_format]
    set timestamp_format "$date_format [lc_get formbuilder_time_format]"

    upvar $offer_array offer
    db_1row get_data {} -column_array offer

    set offer(creator_name) "$offer(first_names) $offer(last_name)"
    set offer(vat_percent) [format "%.1f" $offer(vat_percent)]
    set offer(vat) [format "%.2f" $offer(vat)]
    set offer(amount_sum) [format "%.2f" $offer(amount_sum)]
    set offer(amount_diff) [format "%.2f" [expr $offer(amount_total) - $offer(amount_sum)]]
    set offer(amount_total) [format "%.2f" $offer(amount_total)]
    set offer(offer_id) $offer_id

    db_multirow -upvar_level 1 -extend {amount_sum amount_total category} $item_multirow offer_items {} {
	set price_per_unit [format "%.2f" $price_per_unit]
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]]
	set rebate [format "%.1f" $rebate]
	set category [lang::util::localize [category::get_name $category_id]]
    }
}

ad_proc -public iv::offer::parse_data {
    -offer_id:required
    -recipient_id:required
    -template:required
    -locale:required
    {-accept_link ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with offer data, offer items
} {
    set package_id [ad_conn package_id]

    # Get the offer data
    db_1row get_data {} -column_array offer
    set offer(creator_name) "$offer(first_names) $offer(last_name)"
    set offer(amount_diff) [lc_numeric [format "%.2f" [expr $offer(amount_total) - $offer(amount_sum)]] "" $locale]
    set offer(final_amount) [lc_numeric [format "%.2f" [expr $offer(amount_total)+$offer(vat)]] "" $locale]
    set offer(vat_percent) [lc_numeric [format "%.1f" $offer(vat_percent)] "" $locale]
    set offer(vat) [lc_numeric [format "%.2f" $offer(vat)] "" $locale]
    set offer(amount_sum) [lc_numeric [format "%.2f" $offer(amount_sum)] "" $locale]
    set offer(amount_total) [lc_numeric [format "%.2f" $offer(amount_total)] "" $locale]
    set revision_id [contact::live_revision -party_id $recipient_id]
    # set offer(salutation) [ams::value -attribute_name "salutation" -object_id $revision_id -locale $locale]
    set offer(salutation) "Sehr geehrter"

    set time_format "[lc_get -locale $locale d_fmt] [lc_get -locale $locale t_fmt]"
    set offer(finish_date) [lc_time_fmt $offer(finish_date) $time_format]
    set offer(creation_date) [lc_time_fmt $offer(creation_date) $time_format]
    set offer(accepted_date) [lc_time_fmt $offer(accepted_date) $time_format]

    set offer(recipient_id) $recipient_id
    set offer(name) [contact::name -party_id $recipient_id]
    set offer(rep_first_names) [lindex $offer(name) 0]
    set offer(rep_last_name) [lindex $offer(name) 1]
    set offer(recipient_name) "$offer(rep_first_names) $offer(rep_last_name)"
    set rec_organization_id [contact::util::get_employee_organization -employee_id $offer(recipient_id)]
    set offer(mailing_address) [contact::message::mailing_address -party_id $offer(organization_id) -format "text/html"]
    set offer(organization_name) [contact::name -party_id $offer(organization_id)]

    db_multirow -local -extend {amount_sum amount_total category} offer_items offer_items {} {
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [lc_numeric [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]] "" $locale]
	set amount_sum [lc_numeric $amount_sum "" $locale]
	set price_per_unit [lc_numeric [format "%.2f" $price_per_unit] "" $locale]
	set item_units [lc_numeric [format "%.2f" $item_units] "" $locale]
	set rebate [lc_numeric [format "%.1f" $rebate] "" $locale]
	set category [lang::util::localize [category::get_name $category_id]]
    }

    set file_url [parameter::get -parameter $template]
    
    if {![empty_string_p $file_url]} {
	set content [iv::invoice::template_file -template $file_url -locale $locale]

	# parse template and replace placeholders
	eval [template::adp_compile -string $content]
        set final_content $__adp_output
    } else {
        set final_content ""
    }

    return $final_content
}

ad_proc -public iv::offer::text {
    -offer_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Generate offer text
} {
    iv::offer::data -offer_id $offer_id -offer_array offer -item_multirow offer_items

    set mail_text "
	[_ invoices.iv_offer_Title]: $offer(title)<br>
	[_ invoices.iv_offer_Description]: $offer(description)<br>
	[_ invoices.iv_offer_offer_nr]: $offer(offer_nr)<br>
    "

    if {![empty_string_p $offer(finish_date)]} {
	append mail_text "[_ invoices.iv_offer_finish_date]: $offer(finish_date)<br>"
    }

    if {![empty_string_p $offer(accepted_date)]} {
	append mail_text "[_ invoices.iv_offer_accepted_date]: $offer(accepted_date)<br>"
    }

    append mail_text "[_ invoices.iv_offer_payment_days]: $offer(payment_days)<br><ul>"

    template::multirow foreach offer_items {

	set item_name "<li>$item_nr, $category<br>$title"
	set extra_descr {}
	if {![empty_string_p $page_count]} {
	    append item_name "$page_count [_ invoices.iv_offer_item_pages]; "
	}
	if {![empty_string_p $file_count]} {
	    append item_name "$file_count [_ invoices.iv_offer_item_files]; "
	}
	if {![empty_string_p $description]} {
	    lappend extra_descr $description
	}

	if {![empty_string_p $extra_descr]} {
	    append item_name " ([join $extra_descr "; "])"
	}

	append item_name "<br> $item_units x $price_per_unit $offer(currency) = $amount_sum $offer(currency)"
	if {$rebate > 0} {
	    append item_name " - $rebate% [_ invoices.iv_offer_item_rebate] = $amount_total $offer(currency)"
	}
	append item_name "</li>\n"

	append mail_text $item_name
    }

    append mail_text "</ul>"

    if {$offer(amount_diff) < 0} {
	append mail_text "
	    [_ invoices.iv_offer_amount_sum]: $offer(amount_sum) $offer(currency)<br>
	    [_ invoices.iv_offer_amount_diff]: $offer(amount_diff) $offer(currency)<br>
	"
    }

    append mail_text "
	[_ invoices.iv_offer_amount_total]: $offer(amount_total) $offer(currency)<br>
	[_ invoices.iv_offer_vat]: $offer(vat) $offer(currency) ($offer(vat_percent)%)
    "

    return $mail_text
}


ad_proc -public iv::offer::billed_p {
    -offer_id:required
} {
    @creation-date 2005-09-16

    Returns 1 if the offer has been fully billed, 0 otherwise. This procedure is cached
} {
    return [util_memoize [list iv::offer::billed_p_not_cached -offer_id $offer_id]]
}

ad_proc -public iv::offer::billed_p_not_cached {
    -offer_id:required
} {
    @creation-date 2005-09-16

    Returns 1 if the offer has been fully billed, 0 otherwise
} {
    set offer_items_count [db_string get_items_count { } -default 0]

    set billed_items [db_string get_billed_items_count { } -default 0]

    if { [string equal $offer_items_count $billed_items] && [exists_and_not_null offer_id] } {
	return 1
    } else {
	return 0
    }
}