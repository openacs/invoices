ad_page_contract {
    Form to add/edit an offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    offer_id:integer,optional
    {organization_id:integer,optional ""}
    {item_nr:array,optional}
    {item_title:array,optional}
    {item_description:array,optional}
    {item_files:array,optional}
    {item_pages:array,optional}
    {item_category:array,optional}
    {item_units:array,optional}
    {item_price:array,optional}
    {item_rebate:array,optional}
    {offer_item_id:array,optional}
    {__new_p 0}
    {mode edit}
    {accept:optional}
    {send:optional}
    {send_accepted:optional}
    {project_id:optional}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set date_format "YYYY-MM-DD"
set has_submit 0
set has_edit 0
if {![info exists offer_id] || $__new_p} {
    set page_title "[_ invoices.iv_offer_Add2]"
    set _offer_id 0
    set currency [iv::price_list::get_currency -organization_id $organization_id]
} else {
    db_1row get_organization_and_currencies {}
    set cur_vat_percent [format "%.1f" $cur_vat_percent]
    if {$mode == "edit"} {
	db_1row check_invoices {}
	if {$invoice_count>0 && ![info exists send]} {
	    # do not allow to edit an invoiced offer
	    ad_return_complaint 1 "[_ invoices.iv_offer_edit_error]"
	}
        set page_title "[_ invoices.iv_offer_Edit]"
    } else {
        set page_title "[_ invoices.iv_offer_View]"
        set has_submit 1
	set date_format [lc_get formbuilder_date_format]
	set has_edit 1
    }
    set _offer_id [content::item::get_latest_revision -item_id $offer_id]
}

if {[info exists accept]} {
    ad_returnredirect [export_vars -base offer-accept {organization_id offer_id}]
    ad_script_abort
}
if {[info exists send]} {
    ad_returnredirect [export_vars -base offer-send {organization_id offer_id}]
    ad_script_abort
}
if {[info exists send_accepted]} {
    ad_returnredirect [export_vars -base offer-accept-2 {offer_id}]
    ad_script_abort
}


set organization_name [organizations::name -organization_id $organization_id]
set context [list [list "[export_vars -base "offer-list" {organization_id}]" "[_ invoices.iv_offer_2]"] $page_title]
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

set language [lang::conn::language]
set currency_options [db_list_of_lists currencies {}]

set list_id [iv::price_list::get_list_id -organization_id $organization_id]
db_multirow pricelist all_prices {}


ad_form -name iv_offer_form -action offer-ae -mode $mode -has_submit $has_submit -has_edit $has_edit -export {organization_id} -form {
    {offer_id:key}
    {organization_namex:text(inform) {label "[_ invoices.iv_offer_organization]"} {value "<a href=/contacts/${organization_id}/>$organization_name</a>"} {help_text "[_ invoices.iv_offer_organization_help]"}}
    {title:text {label "[_ invoices.iv_offer_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_offer_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_offer_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_offer_Description_help]"}}
    {comment:text(textarea),optional {label "[_ invoices.iv_offer_comment]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_offer_comment_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(offer_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(offer_id) -categorized_object_id $_offer_id -form_name iv_offer_form
}

ad_form -extend -name iv_offer_form -form {
    {offer_nr:text {label "[_ invoices.iv_offer_offer_nr]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_offer_offer_nr_help]"}}
}

if {$_offer_id} {
    # we are editing/displaying data
    set _project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]
}

if {[exists_and_not_null _project_id]} {
    # display linked project

    db_1row get_project {}
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
    set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
    set project_name "<a href=\"[export_vars -base "${pm_base_url}one" {{project_item_id $item_id}}]\">$project_name</a>"

    ad_form -extend -name iv_offer_form -form {
	{project:text(inform),optional {label "[_ invoices.iv_offer_project]"} {value $project_name} {help_text "[_ invoices.iv_offer_project_help]"}}
    }
} elseif {!$has_submit} {
    # let user assign project if not displaying data

    set project_options [concat [list [list "" ""]] [db_list_of_lists open_projects {}]]
    if {[llength $project_options] > 1} {
	ad_form -extend -name iv_offer_form -form {
	    {project_id:text(select),optional {label "[_ invoices.iv_offer_project]"} {options $project_options} {help_text "[_ invoices.iv_offer_project_help]"}}
	}
    }
}

if {$has_submit} {
    # we are just displaying an offer

    ad_form -extend -name iv_offer_form -form {
	{creator_name:text,optional {label "[_ invoices.iv_offer_creation_user]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_offer_creation_user_help]"}}
	{creation_date:text,optional {label "[_ invoices.iv_offer_creation_date]"} {html {size 12 maxlength 10}} {help_text "[_ invoices.iv_offer_creation_date_help]"}}
	{finish_date:text,optional {label "[_ invoices.iv_offer_finish_date]"} {html {size 12 maxlength 10}} {help_text "[_ invoices.iv_offer_finish_date_help]"}}
    }

    if {![empty_string_p $accepted_date]} {
	ad_form -extend -name iv_offer_form -form {
	    {accepted_date:text,optional {label "[_ invoices.iv_offer_accepted_date]"} {html {size 12 maxlength 10}} {help_text "[_ invoices.iv_offer_accepted_date_help]"}}
	}
    }

} else {
    # we are adding/editing data

    ad_form -extend -name iv_offer_form -form {
	{currency:text(select) {mode display} {label "[_ invoices.iv_offer_currency]"} {options $currency_options} {help_text "[_ invoices.iv_offer_currency_help]"}}
	{finish_date:text,optional {label "[_ invoices.iv_offer_finish_date]"} {html {size 12 maxlength 10 id sel1}} {help_text "[_ invoices.iv_offer_finish_date_help]"} {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]}}}
	{finish_time:date,optional {label "[_ invoices.iv_offer_finish_time]"} {format {[lc_get formbuilder_time_format]}} {help_text "[_ invoices.iv_offer_finish_time_help]"}}
    }
}

ad_form -extend -name iv_offer_form -form {
    {payment_days:integer,optional {label "[_ invoices.iv_offer_payment_days]"} {html {size 5 maxlength 5}} {help_text "[_ invoices.iv_offer_payment_days_help]"}}
}

if {!$has_submit} {
    # we are adding/editing data
    ad_form -extend -name iv_offer_form -form {
	{vat_percent:float {label "[_ invoices.iv_offer_vat_percent]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_offer_vat_percent_help]"} {after_html {%}}}
	{amount_sum:float,optional {label "[_ invoices.iv_offer_amount_sum]"} {html {size 10 maxlength 10 disabled t}} {help_text "[_ invoices.iv_offer_amount_sum_help]"} {after_html $currency}}
	{amount_total:float,optional {label "[_ invoices.iv_offer_amount_total]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_offer_amount_total_help]"} {after_html $currency}}
    }
}


if {$_offer_id} {
    # edit or display existing offer
    set i 0
    set amount_sum 0.

    db_foreach offer_items {} -column_array item {
	incr i
	set item(price_per_unit) [format "%.2f" $item(price_per_unit)]
	set item(amount_sum) [format "%.2f" [expr $item(item_units) * $item(price_per_unit)]]
	set item(amount_total) [format "%.2f" [expr (1. - ($item(rebate) / 100.)) * $item(amount_sum)]]
	set item(rebate) [format "%.1f" $item(rebate)]
	set item(category) [lang::util::localize [category::get_name $item(category_id)]]

	set item_name "$item(category): $item(item_units) x $item(price_per_unit) $currency = $item(amount_sum) $currency"
	if {$item(rebate) > 0} {
	    append item_name " - $item(rebate)% [_ invoices.iv_offer_item_rebate] = $item(amount_total) $currency"
	}
	set extra_descr {}
	if {![empty_string_p $item(page_count)]} {
	    lappend extra_descr "$item(page_count) [_ invoices.iv_offer_item_pages]"
	}
	if {![empty_string_p $item(file_count)]} {
	    lappend extra_descr "$item(file_count) [_ invoices.iv_offer_item_files]"
	}
	if {![empty_string_p $item(description)]} {
	    lappend extra_descr $item(description)
	}
	if {![empty_string_p $item(comment)]} {
	    lappend extra_descr "<i>$item(comment)</i>"
	}

	if {![empty_string_p $extra_descr]} {
	    append item_name " ([join $extra_descr "; "])"
	}

	set amount_sum [expr $amount_sum + $item(amount_total)]

	if {$mode == "edit"} {
	    # edit: use checkboxes
	    ad_form -extend -name iv_offer_form -form \
		[list [list "offer_item_id.${i}:text(hidden)" \
			   [list value $item(item_id)] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_nr.${i}:text,optional" \
			   [list label "[_ invoices.iv_offer_item_nr]"] \
			   [list html [list size 10 maxlength 10]] \
			   [list value $item(item_nr)] \
			   [list help_text "[_ invoices.iv_offer_item_nr_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_title.${i}:text,optional" \
			   [list label "[_ invoices.iv_offer_item_Title]"] \
			   [list html [list size 80 maxlength 1000]] \
			   [list value $item(title)] \
			   [list help_text "[_ invoices.iv_offer_item_Title_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_description.${i}:text(textarea),optional" \
			   [list label "[_ invoices.iv_offer_item_Description]"] \
			   [list html [list rows 5 cols 80]] \
			   [list value $item(description)] \
			   [list help_text "[_ invoices.iv_offer_item_Description_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_comment.${i}:text(textarea),optional" \
			   [list label "[_ invoices.iv_offer_item_comment]"] \
			   [list html [list rows 5 cols 80]] \
			   [list value $item(comment)] \
			   [list help_text "[_ invoices.iv_offer_item_comment_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_pages.${i}:text,optional" \
			   [list label "[_ invoices.iv_offer_item_page_count]"] \
			   [list html [list size 3 maxlength 3]] \
			   [list value $item(page_count)] \
			   [list help_text "[_ invoices.iv_offer_item_page_count_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_files.${i}:text,optional" \
			   [list label "[_ invoices.iv_offer_item_file_count]"] \
			   [list html [list size 3 maxlength 3]] \
			   [list value $item(file_count)] \
			   [list help_text "[_ invoices.iv_offer_item_file_count_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_category.${i}:text(category),optional" \
			   [list label "[_ invoices.iv_offer_item_category]"] \
			   [list value [list $item(offer_item_id) $container_objects(offer_item_id)]] \
			   [list help_text "[_ invoices.iv_offer_item_category_help]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_units.${i}:float,optional" \
			   [list label "[_ invoices.iv_offer_item_item_units]"] \
			   [list html [list size 5 maxlength 5 onChange calculateItemAmount(${i})]] \
			   [list value $item(item_units)] \
			   [list help_text "[_ invoices.iv_offer_item_item_units_help]"] \
			   [list after_html "[_ invoices.units]"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_price.${i}:float,optional" \
			   [list label "[_ invoices.iv_offer_item_price_per_unit]"] \
			   [list html [list size 7 maxlength 7 onChange calculateItemAmount(${i})]] \
			   [list value $item(price_per_unit)] \
			   [list help_text "[_ invoices.iv_offer_item_price_per_unit_help]"] \
			   [list after_html $currency] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "amount_sum.${i}:float(inform)" \
			   [list label "[_ invoices.iv_offer_item_amount]"] \
			   [list html [list size 10 maxlength 10]] \
			   [list value $item(amount_sum)] \
			   [list help_text "[_ invoices.iv_offer_item_amount_help]"] \
			   [list after_html $currency] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	    ad_form -extend -name iv_offer_form -form \
		[list [list "item_rebate.${i}:float,optional" \
			   [list label "[_ invoices.iv_offer_item_rebate]"] \
			   [list html [list size 5 maxlength 5 onChange calculateTotalAmount()]] \
			   [list value $item(rebate)] \
			   [list help_text "[_ invoices.iv_offer_item_rebate_help]"] \
			   [list after_html "%"] \
			   [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	} else {
	    # display: no checkboxes
	    ad_form -extend -name iv_offer_form -form \
		[list [list "offer_item_ids.${item(offer_item_id)}:text(inform)" \
			   [list label "$item(item_nr), $item(title)"] \
			   [list value "$item_name"] ] ]
	}
    }
}

if {!$has_submit} {
    # adding/editing an offer

    if {!$_offer_id} {
	set start 1
    } else {
	incr i
	set start $i
    }

    for {set i $start} {$i < [expr $start + 5] } {incr i} {
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_nr.${i}:text,optional" \
		       [list label "[_ invoices.iv_offer_item_nr]"] \
		       [list html [list size 10 maxlength 10]] \
		       [list value $i] \
		       [list help_text "[_ invoices.iv_offer_item_nr_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_title.${i}:text,optional" \
		       [list label "[_ invoices.iv_offer_item_Title]"] \
		       [list html [list size 80 maxlength 1000]] \
		       [list help_text "[_ invoices.iv_offer_item_Title_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_description.${i}:text(textarea),optional" \
		       [list label "[_ invoices.iv_offer_item_Description]"] \
		       [list html [list rows 5 cols 80]] \
		       [list help_text "[_ invoices.iv_offer_item_Description_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_comment.${i}:text(textarea),optional" \
		       [list label "[_ invoices.iv_offer_item_comment]"] \
		       [list html [list rows 5 cols 80]] \
		       [list help_text "[_ invoices.iv_offer_item_comment_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_pages.${i}:text,optional" \
		       [list label "[_ invoices.iv_offer_item_page_count]"] \
		       [list html [list size 3 maxlength 3]] \
		       [list help_text "[_ invoices.iv_offer_item_page_count_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_files.${i}:text,optional" \
		       [list label "[_ invoices.iv_offer_item_file_count]"] \
		       [list html [list size 3 maxlength 3]] \
		       [list help_text "[_ invoices.iv_offer_item_file_count_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_category.${i}:text(category),optional" \
		       [list label "[_ invoices.iv_offer_item_category]"] \
		       [list html [list onChange setItemPrice(${i})]] \
		       [list value [list 0 $container_objects(offer_item_id)]] \
		       [list help_text "[_ invoices.iv_offer_item_category_help]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_units.${i}:float,optional" \
		       [list label "[_ invoices.iv_offer_item_item_units]"] \
		       [list html [list size 5 maxlength 5 onChange calculateItemAmount(${i})]] \
		       [list help_text "[_ invoices.iv_offer_item_item_units_help]"] \
		       [list after_html "[_ invoices.units]"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_price.${i}:float,optional" \
		       [list label "[_ invoices.iv_offer_item_price_per_unit]"] \
		       [list html [list size 7 maxlength 7 onChange calculateItemAmount(${i})]] \
		       [list help_text "[_ invoices.iv_offer_item_price_per_unit_help]"] \
		       [list after_html $currency] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "amount_sum.${i}:float,optional" \
		       [list label "[_ invoices.iv_offer_item_amount]"] \
		       [list html [list size 10 maxlength 10 disabled t]] \
		       [list help_text "[_ invoices.iv_offer_item_amount_help]"] \
		       [list value "0.00"] \
		       [list after_html $currency] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
	ad_form -extend -name iv_offer_form -form \
	    [list [list "item_rebate.${i}:float,optional" \
		       [list label "[_ invoices.iv_offer_item_rebate]"] \
		       [list html [list size 5 maxlength 5 onChange calculateTotalAmount()]] \
		       [list help_text "[_ invoices.iv_offer_item_rebate_help]"] \
		       [list value 0] \
		       [list after_html "%"] \
		       [list section "[_ invoices.iv_offer_item_1] $i"] ] ]
    }
}


if {$has_submit} {
    # we are just displaying an offer

    if {$sum_total_diff < 0} {
	ad_form -extend -name iv_offer_form -form {
	    {amount_sum:integer,optional {label "[_ invoices.iv_offer_amount_sum]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_offer_amount_sum_help]"} {after_html $currency}}
	    {amount_diff:integer,optional {label "[_ invoices.iv_offer_amount_diff]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_offer_amount_diff_help]"} {after_html $currency}}
	}
    }

    ad_form -extend -name iv_offer_form -form {
	{amount_total:float,optional {label "[_ invoices.iv_offer_amount_total]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_offer_amount_total_help]"} {after_html $currency}}
	{vat:float {label "[_ invoices.iv_offer_vat]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_offer_vat_help]"} {after_html "$currency ($cur_vat_percent%)"}}
    }

    if {[empty_string_p $accepted_date]} {
	ad_form -extend -name iv_offer_form -form {
	    {accept:text(submit) {label "[_ invoices.iv_offer_accept]"} {value t}}
	    {send:text(submit) {label "[_ invoices.iv_offer_send]"} {value t}}
	}
    } else {
	ad_form -extend -name iv_offer_form -form {
	    {send_accepted:text(submit) {label "[_ invoices.iv_offer_send_accepted]"} {value t}}
	}
    }
}

ad_form -extend -name iv_offer_form -new_request {
    set description ""
    set today [db_string today {}]
    set finish_date ""
    set finish_time ""
    set title "[_ invoices.iv_offer_1] $organization_name $today"
    set offer_nr [db_nextval iv_offer_seq]
    set amount_sum "0.00"
    set amount_total "0.00"

    # get this from organization_id
    set payment_days ""
    set vat_percent "16.0"
    # set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]
    # array set org_data [contacts::get_values \
#			    -group_name "#acs-translation.Customers#" \
#			    -object_type "organization" \
#			    -party_id $organization_id \
#			    -contacts_package_id $contacts_package_id]
    # set payment_days $org_data(payment_days)
    # set vat_percent [format "%.1f" $org_data(vat_percent)]
} -edit_request {
    db_1row get_data {}
    set creator_name "$first_names $last_name"
    set vat_percent [format "%.1f" $vat_percent]
    set vat [format "%.2f" $vat]
    if {$amount_total == 0} {
	set amount_total $amount_sum
    }

    set amount_total [format "%.2f" $amount_total]

    if {$has_submit} {
	set amount_sum [format "%.2f" $amount_sum_]
	set amount_diff [format "%.2f" [expr $amount_total - $amount_sum]]
    } else {
	set finish_time [template::util::date::from_ansi $finish_ansi [lc_get formbuilder_time_format]]
	set finish_date [lindex $finish_date 0]
    }
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(offer_id)]

    set finish_date_list [split $finish_date "-"]
    append finish_date_list " [lrange $finish_time 3 5]"

    set item_sum 0.
    foreach i [array names item_nr] {
	if {[exists_and_not_null item_category($i)] && [exists_and_not_null item_units($i)]} {
	    set item(nr) $item_nr($i)
	    set item(title) $item_title($i)
	    set item(description) $item_description($i)
	    set item(comment) $item_comment($i)
	    set item(category) $item_category($i)
	    set item(units) $item_units($i)
	    set item(price) $item_price($i)
	    set item(rebate) $item_rebate($i)
	    set item(page_count) $item_pages($i)
	    set item(file_count) $item_files($i)

	    if {[empty_string_p $item(price)]} {
		set item(sum) "0"
	    } else {
		set item(sum) [expr $item(units) * $item(price)]
	    }
	    set item(total) [expr (1. - ($item(rebate)/100.)) * $item(sum)]
	    set item(vat) [expr $vat_percent * $item(total) / 100.]
	    set items($i) [array get item]

	    set item_sum [expr $item_sum + $item(total)]
	}
    }
    if {[empty_string_p $amount_total]} {
	set amount_total $amount_sum
    }
    set vat [format "%.2f" [expr $vat_percent * $amount_total / 100.]]
    set item_sum [format "%.2f" $item_sum]

} -new_data {
    db_transaction {
	if {[empty_string_p $amount_total]} {
	    set amount_total $amount_sum
	}
	set new_offer_rev_id [iv::offer::new  \
				  -title $title \
				  -description $description  \
				  -comment $comment  \
				  -offer_nr $offer_nr \
				  -organization_id $organization_id \
				  -amount_total $amount_total \
				  -amount_sum $item_sum \
				  -currency $currency \
				  -finish_date $finish_date \
				  -payment_days $payment_days \
				  -vat_percent $vat_percent \
				  -vat $vat]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_offer_rev_id $category_ids
	}

	set counter 0
	foreach i [array names items] {
	    incr counter
	    array set item $items($i)

	    set new_item_rev_id [iv::offer_item::new \
				     -offer_id $new_offer_rev_id \
				     -title $item(title) \
				     -description $item(description)  \
				     -comment $item(comment)  \
				     -item_nr $item(nr) \
				     -item_units $item(units) \
				     -price_per_unit $item(price) \
				     -rebate $item(rebate) \
				     -page_count $item(page_count) \
				     -file_count $item(file_count) \
				     -sort_order $counter \
				     -vat $item(vat) ]

	    category::map_object -object_id $new_item_rev_id $item(category)
	}
	set offer_id [pm::project::get_project_item_id -project_id $new_offer_rev_id]
    }
} -edit_data {
    db_transaction {
	set new_offer_rev_id [iv::offer::edit \
				  -offer_id $offer_id \
				  -title $title \
				  -description $description  \
				  -comment $comment  \
				  -offer_nr $offer_nr \
				  -organization_id $organization_id \
				  -amount_total $amount_total \
				  -amount_sum $item_sum \
				  -currency $currency \
				  -finish_date $finish_date \
				  -payment_days $payment_days \
				  -vat_percent $vat_percent \
				  -vat $vat]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_offer_rev_id $category_ids
	}

	set counter 0
	foreach i [array names items] {
	    incr counter
	    array set item $items($i)

	    if {[info exists offer_item_id($i)]} {
		# new revision of existing item
		set new_item_rev_id [iv::offer_item::edit \
					 -offer_item_id $offer_item_id($i) \
					 -offer_id $new_offer_rev_id \
					 -title $item(title) \
					 -description $item(description)  \
					 -comment $item(comment)  \
					 -item_nr $item(nr) \
					 -item_units $item(units) \
					 -price_per_unit $item(price) \
					 -rebate $item(rebate) \
					 -page_count $item(page_count) \
					 -file_count $item(file_count) \
					 -sort_order $counter \
					 -vat $item(vat) ]
	    } else {
		# add new item
		set new_item_rev_id [iv::offer_item::new \
					 -offer_id $new_offer_rev_id \
					 -title $item(title) \
					 -description $item(description)  \
					 -comment $item(comment)  \
					 -item_nr $item(nr) \
					 -item_units $item(units) \
					 -price_per_unit $item(price) \
					 -rebate $item(rebate) \
					 -page_count $item(page_count) \
					 -file_count $item(file_count) \
					 -sort_order $counter \
					 -vat $item(vat) ]
	    }

	    category::map_object -object_id $new_item_rev_id $item(category)
	}
    }
} -after_submit {
    if {[exists_and_not_null project_id]} {
	application_data_link::new -this_object_id $offer_id -target_object_id $project_id
    }
    if {![empty_string_p $finish_date]} {
	db_dml set_finish_date {
	    update iv_offers
	    set finish_date = to_timestamp(:finish_date_list,'YYYY MM DD HH24 MI SS')
	    where offer_id = :new_offer_rev_id
	}
    }

    ad_returnredirect [export_vars -base offer-ae {offer_id {mode display}}]
    ad_script_abort
}

ad_return_template
