ad_page_contract {
    Form to add/edit Invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_id:integer,optional
    {organization_id:integer,optional ""}
    {project_id:multiple,optional ""}
    {offer_item_ids:array,optional}
    {__new_p 0}
    {mode edit}
    {send:optional}
} -properties {
    context:onevalue
    page_title:onevalue
} -validate {
    org_proj_provided -requires {organization_id:integer} {
	if { [llength $project_id] == 0 } {
	    ad_complain "<b>[_ invoices.You_must_suplly_project_id]</b>"
	}
    }
}

####### FIXME ########
# First try to find the organization_id
if {[empty_string_p $organization_id] } {
    set organisations [db_list organizations "select distinct customer_id from pm_projects where project_id in ([join $project_id ","])"]
    if {[llength $organisations] == 1} {
	set organization_id [lindex $organisations 0]
    } else {
	ad_return_error "More than one customer" "You have selected more than one customer. We are unable to produce one invoice for multiple customers"
    }
}

set package_id [ad_conn package_id]
set user_id [auth::require_login]
set date_format "YYYY-MM-DD"
set has_submit 0
set has_edit 0
if {![info exists invoice_id] || $__new_p} {
    if {$__new_p} {
	set project_id [string trim $project_id "{}"]
    }
    set page_title "[_ invoices.iv_invoice_Add2]"
    set _invoice_id 0
    set invoice_rev_id 0
    set cur_total_amount 0
    set currency [iv::price_list::get_currency -organization_id $organization_id]
} else {
    db_1row get_organization_and_currencies {}
    set cur_vat_percent [format "%.1f" $cur_vat_percent]
    set cur_invoice_rebate [expr $cur_amount_sum - $cur_total_amount]
    if {$cancelled_p == "t"} {
	set has_edit 1
    }
    if {$mode == "edit" && ![info exists send]} {
	if {![empty_string_p $paid_currency] || $cancelled_p == "t" || $status != "new"} {
	    # do not allow to edit a paid invoice
	    ad_return_complaint 1 "[_ invoices.iv_invoice_edit_error]"
	}
        set page_title "[_ invoices.iv_invoice_Edit]"
    } else {
        set page_title "[_ invoices.iv_invoice_View]"
        set has_submit 1
	set date_format [lc_get formbuilder_date_format]
    }
    set _invoice_id [content::item::get_latest_revision -item_id $invoice_id]
}

if {[info exists send]} {
    ad_returnredirect [export_vars -base invoice-send {organization_id invoice_id}]
    ad_script_abort
}

set organization_name [organizations::name -organization_id $organization_id]
set context [list [list "invoice-list" "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-add {organization_id}] "[_ invoices.iv_invoice_Add]"] $page_title]
array set container_objects [iv::util::get_default_objects -package_id $package_id]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

if {$_invoice_id} {
    set project_id [db_list projects {}]
}

set language [lang::conn::language]
set currency_options [db_list_of_lists currencies {}]

if {[exists_and_not_null parent_invoice_id]} {
    # cancellation: get recipients from parent invoice
    set recipient_options [db_list_of_lists cancellation_recipients {}]
} elseif {$cur_total_amount < 0} {
    # credit: get recipients from organization
    set recipient_options [db_list_of_lists credit_recipients {}]
} else {
    # normal invoice: get recipients from projects
    set recipient_options [db_list_of_lists recipients {}]
    #set recipient_options [wieners::get_recipients -customer_id $organization_id]
}


ad_form -name iv_invoice_form -action invoice-ae -mode $mode -has_submit $has_submit -has_edit $has_edit -export {organization_id project_id} -form {
    {invoice_id:key}
    {organization_name:text(inform) {label "[_ invoices.iv_invoice_organization]"} {value $organization_name} {help_text "[_ invoices.iv_invoice_organization_help]"}}
    {recipient_id:integer(select),optional {label "[_ invoices.iv_invoice_recipient]"} {options $recipient_options} {help_text "[_ invoices.iv_invoice_recipient_help]"}}
    {title:text {label "[_ invoices.iv_invoice_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_invoice_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_invoice_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_invoice_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(invoice_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(invoice_id) -categorized_object_id $_invoice_id -form_name iv_invoice_form
}

ad_form -extend -name iv_invoice_form -form {
    {invoice_nr:text {label "[_ invoices.iv_invoice_invoice_nr]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_invoice_invoice_nr_help]"}}
}

if {$has_submit} {
    # we are just displaying an invoice
    if {$cur_invoice_rebate > 0} {
	ad_form -extend -name iv_invoice_form -form {
	    {invoice_rebate:float {label "[_ invoices.iv_invoice_rebate]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_invoice_rebate_help2]"} {after_html $currency}}
	}
    }

    ad_form -extend -name iv_invoice_form -form {
	{total_amount:integer,optional {label "[_ invoices.iv_invoice_total_amount]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_invoice_total_amount_help]"} {after_html $currency}}
	{vat:float {label "[_ invoices.iv_invoice_vat]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_invoice_vat_help]"} {after_html "$currency ($cur_vat_percent%)"}}
    }

    if {![empty_string_p $paid_currency]} {
	ad_form -extend -name iv_invoice_form -form {
	    {paid_amount:integer,optional {label "[_ invoices.iv_invoice_paid_amount]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_invoice_paid_amount_help]"} {after_html $paid_currency}}
	}
    }

    ad_form -extend -name iv_invoice_form -form {
	{creator_name:text,optional {label "[_ invoices.iv_invoice_creation_user]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_invoice_creation_user_help]"}}
	{creation_date:text,optional {label "[_ invoices.iv_invoice_creation_date]"} {html {size 12 maxlength 10}} {help_text "[_ invoices.iv_invoice_creation_date_help]"}}
	{due_date:text,optional {label "[_ invoices.iv_invoice_due_date]"} {html {size 12 maxlength 10}} {help_text "[_ invoices.iv_invoice_due_date_help]"}}
    }

} else {

    # we are adding/editing data
    ad_form -extend -name iv_invoice_form -form {
	{currency:text(select) {mode display} {label "[_ invoices.iv_invoice_currency]"} {options $currency_options} {help_text "[_ invoices.iv_invoice_currency_help]"}}
	{due_date:text,optional {label "[_ invoices.iv_invoice_due_date]"} {html {size 12 maxlength 10 id sel1}} {help_text "[_ invoices.iv_invoice_due_date_help]"} {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]}}}
    }
}

ad_form -extend -name iv_invoice_form -form {
    {payment_days:integer,optional {label "[_ invoices.iv_invoice_payment_days]"} {html {size 5 maxlength 5}} {help_text "[_ invoices.iv_invoice_payment_days_help]"}}
}

if {!$has_submit} {
    # we are adding/editing data
    ad_form -extend -name iv_invoice_form -form {
	{vat_percent:float {label "[_ invoices.iv_invoice_vat_percent]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_invoice_vat_percent_help]"} {after_html {%}}}
    }

    if {![empty_string_p $project_id]} {
	db_1row get_open_rebate {}
	if {$open_rebate > 0} {
	    set open_rebate [format "%.2f" $open_rebate]
	    ad_form -extend -name iv_invoice_form -form {
		{invoice_rebate:float {label "[_ invoices.iv_invoice_rebate]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_invoice_rebate_help]"} {after_html $currency}}
	    }
	}
    }
}

if {!$_invoice_id} {
    # adding a new invoice
    if {![empty_string_p $project_id]} {
	
	db_foreach offer_items {} -column_array offer {
	    set offer(price_per_unit) [format "%.2f" $offer(price_per_unit)]
	    set offer(amount_sum) [format "%.2f" [expr $offer(item_units) * $offer(price_per_unit)]]
	    set offer(amount) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(amount_sum)]]
	    set offer(rebate) [format "%.1f" $offer(rebate)]
	    set offer(category) [lang::util::localize [category::get_name $offer(category_id)]]

	    if {[empty_string_p $offer(credit_percent)]} {
		set offer(credit_percent) 0.
	    }
	    set offer(credit) [format "%.1f" [expr $offer(item_units) * (($offer(credit_percent) + 100.) / 100.)]]
	    set offer(credit) [format "%.2f" [expr $offer(credit) * $offer(price_per_unit)]]
	    set offer(credit) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(credit)]]
	    set offer(credit) [format "%.2f" [expr $offer(credit) - $offer(amount)]]
	
	    set offer_name "$offer(category): $offer(item_units) x $offer(price_per_unit) $currency = $offer(amount_sum) $currency"
	    if {$offer(rebate) > 0} {
		append offer_name " - $offer(rebate)% [_ invoices.iv_offer_item_rebate] = $offer(amount) $currency"
	    }
	    if {![empty_string_p $offer(description)]} {
		append offer_name " ($offer(description))"
	    }

	    set offers($offer(offer_item_id)) [array get offer]

	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(offer_item_id)}:text(checkbox),optional" \
			   [list label "$offer(item_nr), $offer(title)"] \
			   [list options [list [list "$offer_name" t]]] \
			   [list values [list t]] \
			   [list section "$offer(project_id) $offer(project_title)"] ] ]
	}
    }
} else {
    # edit or display existing invoice
    db_foreach invoice_items {} -column_array offer {
	set offer(price_per_unit) [format "%.2f" $offer(price_per_unit)]
	set offer(amount_sum) [format "%.2f" [expr $offer(item_units) * $offer(price_per_unit)]]
	set offer(amount) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(amount_sum)]]
	set offer(rebate) [format "%.1f" $offer(rebate)]
	set offer(category) [lang::util::localize [category::get_name $offer(category_id)]]

	if {[empty_string_p $offer(credit_percent)]} {
	    set offer(credit_percent) 0.
	}
	set offer(credit) [format "%.1f" [expr $offer(item_units) * (($offer(credit_percent) + 100.) / 100.)]]
	set offer(credit) [format "%.2f" [expr $offer(credit) * $offer(price_per_unit)]]
	set offer(credit) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(credit)]]
	set offer(credit) [format "%.2f" [expr $offer(credit) - $offer(amount)]]
	
	set offer_name "$offer(category): $offer(item_units) x $offer(price_per_unit) $currency = $offer(amount_sum) $currency"
	if {$offer(rebate) > 0} {
	    append offer_name " - $offer(rebate)% [_ invoices.iv_offer_item_rebate] = $offer(amount) $currency"
	}
	if {![empty_string_p $offer(description)]} {
	    append offer_name " ($offer(description))"
	}

	set offers($offer(iv_item_id)) [array get offer]

	if {$mode == "edit"} {
	    # edit: use checkboxes
	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(iv_item_id)}:text(checkbox)" \
			   [list label "$offer(item_nr), $offer(title)"] \
			   [list options [list [list "$offer_name" t]]] \
			   [list values [list t]] \
			   [list section "$offer(project_id) $offer(project_title)"] ] ]
	} else {
	    # display: no checkboxes
	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(iv_item_id)}:text(inform)" \
			   [list label "$offer(title), $offer(item_nr)"] \
			   [list value "$offer_name"] \
			   [list section "$offer(project_id) $offer(project_title)"] ] ]
	}
    }
}

if {$mode == "display" && $status == "new"} {
    ad_form -extend -name iv_invoice_form -form {
	{send:text(submit) {label "[_ invoices.iv_invoice_send]"} {value t}}
    }
}


ad_form -extend -name iv_invoice_form -new_request {
    set description [join [db_list project_titles {}] ",\n"]
    set due_date [db_string today {}]
    set title "[_ invoices.iv_invoice_1] $organization_name $due_date"
    set invoice_nr [db_nextval iv_invoice_seq]

    db_1row offer_data {}
    set vat_percent [format "%.1f" $vat_percent]
    set invoice_rebate $open_rebate
} -edit_request {
    db_1row get_data {}
    set creator_name "$first_names $last_name"
    set vat_percent [format "%.1f" $vat_percent]
    set vat [format "%.2f" $vat]
    set total_amount [format "%.2f" $total_amount]
    set invoice_rebate [format "%.2f" [expr $amount_sum - $total_amount]]
    if {![empty_string_p $paid_amount]} {
	set paid_amount [format "%.2f" $paid_amount]
    }
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(invoice_id)]

    set total_amount 0.
    set total_credit 0.
    foreach offer_item_id [array names offer_item_ids] {
	array set offer $offers($offer_item_id)
	set total_amount [expr $total_amount + $offer(amount)]
	set total_credit [expr $total_credit + $offer(credit)]
    }
    set total_amount [format "%.2f" $total_amount]
    set amount_sum $total_amount
    if {[exists_and_not_null invoice_rebate]} {
	set total_amount [expr $total_amount - $invoice_rebate]
    }
    set total_amount [format "%.2f" $total_amount]
    set vat [format "%.2f" [expr $total_amount * $vat_percent / 100.]]
} -new_data {
    db_transaction {
	set new_invoice_rev_id [iv::invoice::new  \
				    -title $title \
				    -description $description  \
				    -recipient_id $recipient_id \
				    -invoice_nr $invoice_nr \
				    -organization_id $organization_id \
				    -total_amount $total_amount \
				    -amount_sum $amount_sum \
				    -currency $currency \
				    -due_date $due_date \
				    -payment_days $payment_days \
				    -vat_percent $vat_percent \
				    -vat $vat]

	set invoice_id [content::revision::item_id -revision_id $new_invoice_rev_id]
	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_invoice_rev_id $category_ids
	}

	set counter 0
	foreach offer_item_id [array names offer_item_ids] {
	    incr counter
	    array set offer $offers($offer_item_id)
	    set offer(vat) [expr $vat_percent * $offer(vat) / 100.]

	    set new_item_rev_id [iv::invoice_item::new \
				     -invoice_id $new_invoice_rev_id \
				     -title $offer(title) \
				     -description $offer(description)  \
				     -item_nr $offer(item_nr) \
				     -offer_item_id $offer_item_id \
				     -item_units $offer(item_units) \
				     -price_per_unit $offer(price_per_unit) \
				     -rebate $offer(rebate) \
				     -amount_total $offer(amount) \
				     -sort_order $counter \
				     -vat $offer(vat) ]
	}

	# add credit offer entry
	if {$total_credit > 0.} {
	    set vat_credit [format "%.2f" [expr $total_credit * $vat_percent / 100.]]
	    db_1row get_credit_offer {}

	    # add new offer item
	    set offer_item_rev_id [iv::offer_item::new \
				       -offer_id $credit_offer_rev_id \
				       -title $title \
				       -description $description \
				       -comment "" \
				       -item_nr $invoice_id \
				       -item_units 1 \
				       -price_per_unit $total_credit \
				       -rebate 0 \
				       -sort_order $invoice_id \
				       -vat $vat_credit]
	}
    }
} -edit_data {
    db_transaction {
	set new_invoice_rev_id [iv::invoice::edit \
				    -invoice_item_id $invoice_id \
				    -title $title \
				    -description $description  \
				    -recipient_id $recipient_id \
				    -invoice_nr $invoice_nr \
				    -organization_id $organization_id \
				    -total_amount $total_amount \
				    -amount_sum $amount_sum \
				    -currency $currency \
				    -due_date $due_date \
				    -payment_days $payment_days \
				    -vat_percent $vat_percent \
				    -vat $vat]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_invoice_rev_id $category_ids
	}

	set counter 0
	foreach iv_item_id [array names offer_item_ids] {
	    incr counter
	    array set offer $offers($iv_item_id)
	    set offer(vat) [expr $vat_percent * $offer(old_vat) / 100.]

	    set new_item_rev_id [iv::invoice_item::edit \
				     -iv_item_item_id $iv_item_id \
				     -invoice_id $new_invoice_rev_id \
				     -title $offer(title) \
				     -description $offer(description)  \
				     -item_nr $offer(item_nr) \
				     -offer_item_id $offer(offer_item_id) \
				     -item_units $offer(item_units) \
				     -price_per_unit $offer(price_per_unit) \
				     -rebate $offer(rebate) \
				     -amount_total $offer(amount) \
				     -sort_order $counter \
				     -vat $offer(vat) ]
	}

	# edit credit offer entry
	if {$total_credit > 0.} {
	    set vat_credit [format "%.2f" [expr $total_credit * $vat_percent / 100.]]
	    db_1row get_credit_offer_item {}

	    # edit offer item
	    set offer_item_rev_id [iv::offer_item::edit \
				       -offer_item_id $credit_offer_item_id \
				       -offer_id $credit_offer_rev_id \
				       -title $title \
				       -description $description \
				       -comment "" \
				       -item_nr $invoice_id \
				       -item_units 1 \
				       -price_per_unit $total_credit \
				       -rebate 0 \
				       -sort_order $invoice_id \
				       -vat $vat_credit]
	}
    }
} -after_submit {
    db_transaction {
	# get all offer_ids
	set offer_ids {}
	foreach iv_item_id [array names offers] {
	    array set offer $offers($iv_item_id)
	    if {[lsearch -exact $offer_ids $offer(offer_id)] == -1} {
		lappend offer_ids $offer(offer_id)
	    }
	}

	# foreach offer_id: check if there's an item that's not billed -> status new, else status billed
	foreach offer_id $offer_ids {
	    set unbilled_items [db_string check_offer_status {} -default 0]

	    if {$unbilled_items == 0} {
		# all offer items billed
		set status billed
	    } else {
		# there are still unbilled offer items
		set status new
	    }

	    db_dml set_status {}
	}
    }

    ad_returnredirect "/contacts/$organization_id/"
    ad_script_abort
}

ad_return_template
