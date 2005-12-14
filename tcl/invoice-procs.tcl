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
					 [list status new] \
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
					     [list status new] \
					     [list cancelled_p f] ] ]
    }

    return $new_rev_id
}

ad_proc -public iv::invoice::set_status {
    -invoice_id:required
    {-status "new"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-04

    Edit Invoice status
} {
    db_dml update_status {}
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
    set invoice(final_amount) [format "%.2f" [expr $invoice(total_amount)+$invoice(vat)]]

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
    -template:required
    -locale:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with invoice data, invoice items
} {
    set package_id [ad_conn package_id]

    # Get the invoice data
    db_1row get_data {} -column_array invoice
    set invoice(creator_name) "$invoice(first_names) $invoice(last_name)"
    set invoice(amount_diff) [format "%.2f" [expr $invoice(total_amount) - $invoice(amount_sum)]]
    set amount_diff $invoice(amount_diff)
    set invoice(amount_diff) [lc_numeric $invoice(amount_diff) "" $locale]
    set invoice(final_amount) [lc_numeric [format "%.2f" [expr $invoice(total_amount)+$invoice(vat)]] "" $locale]
    set invoice(vat) [lc_numeric [format "%.2f" $invoice(vat)] "" $locale]
    set invoice(amount_sum) [lc_numeric [format "%.2f" $invoice(amount_sum)] "" $locale]
    set invoice(total_amount) [lc_numeric [format "%.2f" $invoice(total_amount)] "" $locale]

    set time_format [lc_get -locale $locale d_fmt]
    set invoice(creation_date) [lc_time_fmt $invoice(creation_date) $time_format]
    set invoice(due_date) [lc_time_fmt $invoice(due_date) $time_format]

    set name [contact::name -party_id $recipient_id]
    set invoice(rep_first_names) [lindex $name 1]
    set invoice(rep_last_name) [string trim [lindex $name 0] ,]
    set invoice(recipient_name) "$invoice(rep_first_names) $invoice(rep_last_name)"
    set rec_organization_id [contact::util::get_employee_organization -employee_id $invoice(recipient_id)]
    set orga_revision_id [content::item::get_best_revision -item_id $invoice(organization_id)]
    set rec_revision_id [content::item::get_best_revision -item_id $recipient_id]
    set invoice(mailing_address) [contact::message::mailing_address -party_id $invoice(organization_id) -format "text/html"]
    set invoice(organization_name) [contact::name -party_id $invoice(organization_id)]
    set invoice(company_name_ext) [ams::value -attribute_name "company_name_ext" -object_id $orga_revision_id -locale $locale]
    set invoice(sticker_salutation) [ams::value -attribute_name "sticker_salutation" -object_id $rec_revision_id -locale $locale]
    if {[empty_string_p $invoice(sticker_salutation)]} {
	set invoice(sticker_salutation) $name
    }
    set sum 0.

    db_multirow -local -extend {amount_sum amount_total category} invoice_items invoice_items {} {
	if {[empty_string_p $credit_percent]} {
	    set credit_percent 0
	}
	set item_units [format "%.2f" [expr $item_units * (1. + ($credit_percent / 100.))]]
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]]
	set sum [expr $sum + $amount_total]
	set amount_total [lc_numeric $amount_total "" $locale]
	set amount_sum [lc_numeric $amount_sum "" $locale]
	set price_per_unit [lc_numeric [format "%.2f" $price_per_unit] "" $locale]
	set item_units [lc_numeric [format "%.2f" $item_units] "" $locale]
	set rebate [lc_numeric [format "%.1f" $rebate] "" $locale]
	set category [lang::util::localize [category::get_name $category_id]]
    }

    set invoice(amount_sum) $sum
    set invoice(total_amount) [expr $sum + $amount_diff]
    set invoice(vat) [expr $invoice(vat_percent) * $invoice(total_amount) / 100.]
    set invoice(final_amount) [lc_numeric [format "%.2f" [expr $invoice(total_amount)+$invoice(vat)]] "" $locale]
    set invoice(vat_percent) [lc_numeric [format "%.1f" $invoice(vat_percent)] "" $locale]
    set invoice(vat) [lc_numeric [format "%.2f" $invoice(vat)] "" $locale]
    set invoice(amount_sum) [lc_numeric [format "%.2f" $invoice(amount_sum)] "" $locale]
    set invoice(total_amount) [lc_numeric [format "%.2f" $invoice(total_amount)] "" $locale]

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

ad_proc -public iv::invoice::template_file {
    -template:required
    -locale:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-07

    Get template file matching locale
} {
    set filename "[acs_root_dir]/$template"
    set system_locale [lang::system::site_wide_locale]
    set language_locale [lang::util::default_locale_from_lang [lindex [split $locale "_"] 0]]

    if {[file exists "${filename}_${locale}.html"]} {
	# file found directly
	set filename "${filename}_${locale}.html"
    } elseif {[file exists "${filename}_${language_locale}.html"]} {
	# file found for language locale
	set filename "${filename}_${language_locale}.html"
    } else {
	# take default file
	set filename "${filename}_${system_locale}.html"
    }

    set file [open $filename]
    fconfigure $file -translation binary
    set content [read $file]
    close $file

    return $content
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


ad_proc -public iv::invoice::year_month_day_filter {
    {-year ""}
    {-month ""}
    {-day ""}
    {-last_years "5"}
    {-extra_vars ""}
    -base:required
} {
    Returns and html filter to use in any adp page for sort data according to date. Return
    the variables year, month, day and any extra variable you recieved in extra_vars to the base
    page (url).
    
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net

    @param year       The year to show.
    @param month      The month to show (depending on the month and year number of days shown are 31,30,29 and 28).
    @param day        The day to show.
    @param last_years How many past years will be shown from the actual year.
    @param extra_vars A list of extra vars to include in the links. They have to be of the form 
                      [list [list var_name value] [list var_name value] ...].
    @param base       The page to redirect in the links.
				    
} {
    set actual_year [string range [dt_sysdate] 0 3]
    set html "<center><table><tr><td>"
    
    for { set i $last_years } { $i > 0 } { set i [expr $i - 1] } {
	set myear [expr $actual_year - $i]
	set send_vars [list [list year $myear] month day last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	if { [string equal $year $myear] } {
	    append html "<b><a href=\"$url\">$myear</a></b>"
	} else {
	    append html "<a href=\"$url\">$myear</a>"
	}
	append html "&nbsp;&nbsp;&nbsp;"
    }
    
    # We always look for 5 years from actual year
    for { set i $actual_year } { $i < [expr $actual_year + 6] } { incr i} {
	set send_vars [list [list year $i] month day last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	if { [string equal $year $i] } {
	    append html "<b><a href=\"$url\">$i</a></b>"
	} else {
	    append html "<a href=\"$url\">$i</a>"
	}
	append html "&nbsp;&nbsp;&nbsp;"
    }
    
    if { [exists_and_not_null year] } {
	set send_vars [list month day last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	append html "<small>(<a href=\"$url\">Clear</a>)</small>"
    }

    append html "</td></tr><tr><td>"
    
    for { set i 1 } { $i < 13 } { incr i } {
	set short_month [template::util::date::monthName $i short]
	# Dates format has a 0 before the number for months that
	# are lower than 10
	if { $i < 10 } {
	    set m "0$i"
	} else {
	    set m $i
	}
	set send_vars [list year [list month $m] day last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	if { [string equal $month $m] } {
	    append html "<b><a href=\"$url\">$short_month</a></b>"
	} else {
	    append html "<a href=\"$url\">$short_month</a>" 
	}
	append html "&nbsp;&nbsp;&nbsp;"
    }

    if { [exists_and_not_null month] } {
	set send_vars [list year day last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	append html "<small>(<a href=\"$url\">Clear</a>)</small>"
    }

    append html "</td></tr><tr><td>"

    # We figure out how many days we are going to show according to the month
    set month_days 31
    if { [exists_and_not_null month] } {
	if { [string equal $month "04"] || [string equal $month "06"] || [string equal $month "09"] ||
	     [string equal $month "11"] } {
	    set month_days 30
	} elseif {[string equal $month "02"] } {
	    if { [exists_and_not_null year] && [string equal [expr $year % 4] "0"] } {
		set month_days 29
	    } else {
		set month_days 28
	    }
	}
    }
    
    for { set i 1 } { $i <= $month_days } { incr i } {
	# Dates format has a 0 before the number for days that
	# are lower than 10
	if { $i < 10 } {
	    set d "0$i"
	} else {
	    set d $i
	}
	set send_vars [list year month [list day $d] last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	if { [string equal $day $d] } {
	    append html "<b><a href=\"$url\">$d</a></b>"
	} else {
	    append html "<a href=\"$url\">$d</a>"
	}
	append html "&nbsp;&nbsp;&nbsp;"
    }
    
    if { [exists_and_not_null day] } {
	set send_vars [list year month last_years]
	foreach var $extra_vars {
	    lappend send_vars $var
	}
	set url [export_vars -base $base $send_vars]
	append html "<small>(<a href=\"$url\">Clear</a>)</small>"
    }
    
    append html "</td></tr></table></center>"
    return $html
}