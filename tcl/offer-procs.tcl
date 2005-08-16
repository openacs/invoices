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
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
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
					 [list payment_days $payment_days] \
					 [list vat_percent $vat_percent] \
					 [list vat $vat] ] ]
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
    {-payment_days ""}
    {-vat_percent ""}
    {-vat ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-18

    Edit Offer
} {
    db_transaction {
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
					     [list payment_days $payment_days] \
					     [list vat_percent $vat_percent] \
					     [list vat $vat] ] ]
    }

    return $new_rev_id
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
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with offer data, offer items
} {
    set package_id [ad_conn package_id]
    set date_format [lc_get formbuilder_date_format]
    set timestamp_format "$date_format [lc_get formbuilder_time_format]"

    db_1row get_data {} -column_array offer

    set name [contact::name -party_id $recipient_id]
    set first_names [lindex $name 0]
    set last_name [lindex $name 1]
    set mailing_address [contact::message::mailing_address -party_id $offer(organization_id) -format "text/html"]
    set organization_name [contact::name -party_id $offer(organization_id)]
    set offer(creator_name) "$offer(first_names) $offer(last_name)"
    set offer(vat_percent) [format "%.1f" $offer(vat_percent)]
    set offer(vat) [format "%.2f" $offer(vat)]
    set offer(amount_sum) [format "%.2f" $offer(amount_sum)]
    set offer(amount_diff) [format "%.2f" [expr $offer(amount_total) - $offer(amount_sum)]]
    set offer(amount_total) [format "%.2f" $offer(amount_total)]
    set offer(offer_id) $offer_id

    db_multirow -local -extend {amount_sum amount_total category} offer_items offer_items {} {
	set price_per_unit [format "%.2f" $price_per_unit]
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]]
	set rebate [format "%.1f" $rebate]
	set category [lang::util::localize [category::get_name $category_id]]
    }

    set file [open "/web/document.html"]
    fconfigure $file -translation binary
    set content [read $file]

    
    # parse template and replace placeholders
    eval [template::adp_compile -string $content]
    set final_content $__adp_output

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
