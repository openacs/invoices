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
    -email_text:required
    {-type "offer"}
    {-accept_link ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21

    Create array and multirow in callers context with offer data, offer items
} {
    set package_id [ad_conn package_id]

    # Get the offer data
    db_1row get_data {} -column_array data
    set locale [lang::user::site_wide_locale -user_id $contact_id]
    set contact_locale $locale
    set data(creator_name) "$data(first_names) $data(last_name)"
    set data(amount_diff) [lc_numeric [format "%.2f" [expr $data(amount_total) - $data(amount_sum)]] "" $locale]
    set data(final_amount) [lc_numeric [format "%.2f" [expr $data(amount_total)+$data(vat)]] "" $locale]
    set data(vat_percent) [lc_numeric [format "%.1f" $data(vat_percent)] "" $locale]
    set data(vat) [lc_numeric [format "%.2f" $data(vat)] "" $locale]
    set data(amount_sum) [lc_numeric [format "%.2f" $data(amount_sum)] "" $locale]
    set data(amount_total) [lc_numeric [format "%.2f" $data(amount_total)] "" $locale]
    set orga_revision_id [content::item::get_best_revision -item_id $data(organization_id)]
    set contact_revision_id [content::item::get_best_revision -item_id $contact_id]
    set rec_client_id [ams::value -attribute_name "client_id" -object_id $orga_revision_id -locale $locale]

    # offer contact data
    contact::employee::get -employee_id $contact_id -array contact_data
    foreach attribute {name company_name_ext address town_line country country_code salutation salutation_letter} {
	set data(contact_$attribute) [value_if_exists contact_data($attribute)]
    }
    set data(document_type) $type

    set time_format "[lc_get -locale $locale d_fmt] [lc_get -locale $locale t_fmt]"
    set data(finish_date) [lc_time_fmt $data(finish_date) $time_format]
    set data(creation_date) [lc_time_fmt $data(creation_date) $time_format]
    set data(accepted_date) [lc_time_fmt $data(accepted_date) $time_format]

    set data(recipient_id) $recipient_id
    set data(name) [contact::name -party_id $recipient_id]
    set data(rep_first_names) [lindex $data(name) 1]
    set data(rep_last_name) [string trim [lindex $data(name) 0] ,]
    set data(recipient_name) "$data(rep_first_names) $data(rep_last_name)"
    set rec_organization_id [contact::util::get_employee_organization -employee_id $data(recipient_id)]

    # data of offer items
    db_multirow -local -extend {amount_sum amount_total category} items offer_items {} {
	set amount_sum [format "%.2f" [expr $item_units * $price_per_unit]]
	set amount_total [lc_numeric [format "%.2f" [expr (1. - ($rebate / 100.)) * $amount_sum]] "" $locale]
	set amount_sum [lc_numeric $amount_sum "" $locale]
	set price_per_unit [lc_numeric [format "%.2f" $price_per_unit] "" $locale]
	set item_units [lc_numeric [format "%.2f" $item_units] "" $locale]
	set rebate [lc_numeric [format "%.1f" $rebate] "" $locale]
	set category [lang::util::localize [category::get_name $category_id] $locale]
    }

    # parse offer email text
    eval [template::adp_compile -string [lang::util::localize $email_text $locale]]
    set final_content [list $__adp_output]

    # get the url to the document template
    set template_path [parameter::get -parameter OfferTemplate]
    util_unlist [iv::invoice::template_files -template $template_path -locale $locale] content styles
	
    # parse template and replace placeholders
    set __adp_output ""
    eval [template::adp_compile -string $content]
    set content_compiled $__adp_output
	
    set __adp_output ""
    eval [template::adp_compile -string $styles]
    set styles_compiled $__adp_output

    lappend final_content [contact::oo::change_content -path $template_path -document_filename "document.odt" -contents [list "content.xml" $content_compiled "styles.xml" $styles_compiled]]

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

ad_proc -public iv::offer::new_credit {
    -organization_id:required
    {-package_id ""}
} {
    @creation-date 2005-10-10

    Creates an empty and closed project and link a new offer with status credit
    for the given organization
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set user_id [ad_conn user_id]
    set creation_ip [ad_conn peeraddr]
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
    set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]
    set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]

    db_transaction {
	set project_rev_id [pm::project::new \
				-project_name "#invoices.credit_project_title#" \
				-description "#invoices.credit_project_desc#" \
				-mime_type "text/plain" \
				-status_id 2 \
				-organization_id $organization_id \
				-creation_user $user_id \
				-creation_ip $creation_ip \
				-package_id $pm_package_id]

	set project_id [pm::project::get_project_item_id -project_id $project_rev_id]

	# grant employees read access to project
	set employees_group_id [group::get_id -group_name "Employees"]
	if { ![empty_string_p $employees_group_id] } {
	    permission::grant -object_id $project_id -party_id $employees_group_id -privilege read
	}

	set currency [iv::price_list::get_currency -organization_id $organization_id]
	set vat_percent "16.0"
	array set org_data [contacts::get_values \
				-group_name "Customers" \
				-object_type "organization" \
				-party_id $organization_id \
				-contacts_package_id $contacts_package_id]
	if {[info exists org_data(vat_percent)]} {
	    set vat_percent [format "%.1f" $org_data(vat_percent)]
	}

	set new_offer_rev_id [iv::offer::new \
				  -title "#invoices.credit_offer_title#" \
				  -description "#invoices.credit_offer_desc#" \
				  -offer_nr [db_nextval iv_offer_seq] \
				  -organization_id $organization_id \
				  -amount_total 0 \
				  -amount_sum 0 \
				  -currency $currency \
				  -payment_days 0 \
				  -vat_percent $vat_percent \
				  -vat 0 \
				  -credit_percent 0 \
				  -package_id $package_id]

	set offer_id [pm::project::get_project_item_id -project_id $new_offer_rev_id]
	iv::offer::set_status -offer_id $offer_id -status credit
	application_data_link::new -this_object_id $offer_id -target_object_id $project_id
    }
}

ad_proc -public iv::offer::pdf_folders {
    -organization_id:required
    {-package_id ""}
} {
    @creation-date 2005-10-10

    Creates folders for offers, accepted offers, invoices (including credit and cancellations)
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]

    if {![empty_string_p $root_folder_id]} {
	db_transaction {
	    foreach foldername [list iv_offer iv_accepted iv_invoice] {
		set new_folder_id [fs::new_folder \
				       -name "${foldername}_$root_folder_id" \
				       -pretty_name "#invoices.folder_$foldername#" \
				       -parent_id $root_folder_id \
				       -no_callback]
	    }
	}
    }
}
