ad_page_contract {
    Form to add/edit Invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_id:integer,optional
    {organization_id:integer,optional ""}
    {project_id:multiple,optional ""}
    {offer_item_ids:array,optional}
    {return_url:optional ""}
    {__new_p 0}
    {mode edit}
    {send:optional}
} -properties {
    context:onevalue
    page_title:onevalue
}

if { ![exists_and_not_null invoice_id] } {
    # We are creating a new invoice so we are going 
    # to make some validations.

    set more_error_p 0
    set projects_error_p 0

    if { [exists_and_not_null organization_id] } {
	# We already have the organization_id so we need to check
	# if there are project_id's and if the customer (organization_id)
	# of the projects is the same that the one we recieved.

	if { ![string equal [llength $project_id] 0] } {
	    set organizations [db_list get_organizations ""]
	    if {[llength $organizations] == 1} {
		if { ![string equal $organization_id [lindex $organizations 0]] } {
		    # The provided organization_id and the one get from the projects are
		    # not the same
		    set more_error_p 1
		}
	    } else {
		# We have more than one organization from the projects
		set more_error_p 1
	    }
	} else {
	    # No projects where supllied
	    set projects_error_p 1
	}
    } else {
	if { [llength $project_id] == 0 } {
	    # No projects where supllied
	    set projects_error_p 1
	} else {
	    set organizations [db_list get_organizations ""]
	    if { [llength $organizations] != 1} {
		# More than one organization form the projects
		set more_error_p 1
	    } else {
		set organization_id [lindex $organizations 0]
	    }
	}
    }
    
    if { $more_error_p } {
	ad_return_error "[_ invoices.More_than_one_customer]" "[_ invoices.You_have_selected_more]"
    }
    if { $projects_error_p } {
	ad_return_error "[_ invoices.No_project_id]" "[_ invoices.You_must_suplly_project_id].<br>&nbsp;"
    }
}

set current_url "[ad_conn url]?[ad_conn query]"
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
    set cur_invoice_rebate [expr $cur_amount_sum - $cur_total_amount]
    if {$cancelled_p == "t"} {
	set has_edit 1
    }
    if {$mode == "display" && $status != "new"} {
	# don't allow edit if offer is sent
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
    ad_returnredirect [export_vars -base invoice-send-1 {organization_id invoice_id}]
    ad_script_abort
}


set organization_name [organizations::name -organization_id $organization_id]

# If the contacts package is installed we can get the incoice specialities.
if {[apm_package_installed_p "contacts"]} {
    set revision_id [contact::live_revision -party_id $organization_id]
    set invoice_specialities [ams::value -attribute_name "invoice_specialities" -object_id $revision_id] 
} else {
    set invoice_specialities ""
}

set context [list [list "invoice-list" "[_ invoices.iv_invoice_2]"] [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_Add]"] $page_title]
array set container_objects [iv::util::get_default_objects -package_id $package_id]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

if {$_invoice_id} {
    set project_id [db_list projects {}]
}

set language [lang::conn::language]
set currency_options [db_list_of_lists currencies {}]

if {[exists_and_not_null parent_invoice_id]} {
    # cancellation: get recipients from parent invoice
    set contact_options [db_list_of_lists cancellation_contacts {}]
    set recipient_options {}
    db_foreach cancellation_recipients {} {
	lappend recipient_options [list [contact::name -party_id $rec_id -reverse_order] $rec_id]
    }
    set recipient_options [lsort -dictionary $recipient_options]
} elseif {$cur_total_amount < 0 || [empty_string_p $project_id]} {
    # credit: get recipients from organization
    set recipient_options [contact::util::get_employees_list_of_lists -organization_id $organization_id]
    set contact_options $recipient_options
} else {
    # normal invoice: get recipients from projects
    # We want to mark invoice recipients that have actually been assigned in the project
    set project_contacts [db_list contacts {}]
    set contact_id [lindex $project_contacts 0]
    set contact_options {}

    # add all invoice-recipients of customer to recipient list
    # mark project recipients as bold
    set project_recipients [db_list recipients {}]
    set recipient_id [lindex $project_recipients 0]
    set recipients [db_list invoice_recipients {}]
    set recipient_options {}

    foreach recipient $recipients {
	set recipient_name [contact::name -party_id $recipient -reverse_order]
	contact::employee::get -employee_id $recipient -array recipient_data
	if {![info exists recipient_data(first_names)]} {
	    # if recipient is company, add client_id to name
	    append recipient_name " ($recipient_data(client_id))"
	}
	if {[lsearch -exact $project_recipients $recipient] == -1 || $mode == "display"} {
	    lappend recipient_options [list $recipient_name $recipient]
	} else {
	    lappend recipient_options [list "* $recipient_name *" $recipient]
	}
    }
    set recipient_options [lsort -dictionary $recipient_options]

    set recipient_options2 {}
    # add all employees of customer to recipient-list
    foreach employee_id [contact::util::get_employees -organization_id $organization_id] {
	if {[lsearch -exact $recipients $employee_id] == -1} {
	    set employee_name [contact::name -party_id $employee_id -reverse_order]
	    if {[lsearch -exact $project_recipients $employee_id] == -1 || $mode == "display"} {
		lappend recipient_options2 [list $employee_name $employee_id]
	    } else {
		lappend recipient_options2 [list "* $employee_name *" $employee_id]
	    }
	}

	if {[lsearch -exact $project_contacts $employee_id] == -1 || $mode == "display"} {
	    lappend contact_options [list $employee_name $employee_id]
	} else {
	    lappend contact_options [list "* $employee_name *" $employee_id]
	}
    }

    set contact_options [lsort -dictionary $contact_options]
    set recipient_options [concat $recipient_options [lsort -dictionary $recipient_options2]]
}

# Get the recipient_organization_id
# set rec_organization_id [contact::util::get_employee_organization -employee_id [lindex [lindex $recipient_options 0] 1]]
# lappend recipient_options [list [organizations::name -organization_id $rec_organization_id] $rec_organization_id]


ad_form -name iv_invoice_form -action invoice-ae -mode $mode -has_submit $has_submit -has_edit $has_edit -export {organization_id project_id return_url} -form {
    {invoice_id:key}
    {organization_name:text(inform) {label "[_ invoices.iv_invoice_organization]"} {value $organization_name} {help_text "[_ invoices.iv_invoice_organization_help]"}}
    {invoice_specialities:text(inform) {label "[_ invoices.iv_invoice_specialities]"} {value $invoice_specialities} {help_text "[_ invoices.iv_invoice_specialities_help]"}}
    {contact_id:integer(select),optional {label "[_ invoices.iv_invoice_contact]"} {options $contact_options} {help_text "[_ invoices.iv_invoice_contact_help]"}}
    {recipient_id:integer(select),optional {label "[_ invoices.iv_invoice_recipient]"} {options $recipient_options} {help_text "[_ invoices.iv_invoice_recipient_help]"}}
    {title:text(inform) {label "[_ invoices.iv_invoice_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_invoice_Title_help]"}}
    {description:text(inform),optional {label "[_ invoices.iv_invoice_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_invoice_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(invoice_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(invoice_id) -categorized_object_id $_invoice_id -form_name iv_invoice_form
}

ad_form -extend -name iv_invoice_form -form {
    {invoice_nr:text(inform) {label "[_ invoices.iv_invoice_invoice_nr]"} {help_text "[_ invoices.iv_invoice_invoice_nr_help]"}}
}

# display link to cancelled invoice
if {[exists_and_not_null parent_invoice_id]} {
    db_1row check_cancelled_invoice {}
    set cancel_link [export_vars -base invoice-ae {{invoice_id $cancel_id} {mode display}}]
    set cancelled_invoice "<a href=\"$cancel_link\">$cancel_title</a>"

    ad_form -extend -name iv_invoice_form -form {
	{cancelled_invoice:text(inform) {label "[_ invoices.iv_invoice_cancelled_invoice]"} {help_text "[_ invoices.iv_invoice_cancelled_help]"}}
    }
}

# display link to cancellation
if {[exists_and_not_null invoice_id] && [db_0or1row check_cancellation {}]} {

    set cancel_link [export_vars -base invoice-ae {{invoice_id $cancel_id} {mode display}}]
    set cancellation "<a href=\"$cancel_link\">$cancel_title</a>"

    ad_form -extend -name iv_invoice_form -form {
	{cancellation:text(inform) {label "[_ invoices.iv_invoice_cancellation]"} {help_text "[_ invoices.iv_invoice_cancellation_help]"}}
    }
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
    {payment_days:integer(inform),optional {label "[_ invoices.iv_invoice_payment_days]"} {html {size 5 maxlength 5}} {help_text "[_ invoices.iv_invoice_payment_days_help]"}}
}

if {!$has_submit} {
    # we are adding/editing data
    ad_form -extend -name iv_invoice_form -form {
	{vat_percent:float {mode display} {label "[_ invoices.iv_invoice_vat_percent]"} {html {size 5 maxlength 10}} {help_text "[_ invoices.iv_invoice_vat_percent_help]"} {after_html {%}}}
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

    set boolean_options [list [list "[_ invoices.yes]" 1] [list "[_ invoices.no]" 0]]
#    set email_options [list [list "[_ invoices.invoice_email]" t] [list "[_ invoices.invoice_display]" f] [list "[_ invoices.invoice_for_join]" j]]
    set email_options [list [list "[_ invoices.invoice_email]" t] [list "[_ invoices.invoice_display]" f]]

    ad_form -extend -name iv_invoice_form -form {
	{opening_p:text(radio) {label "[_ invoices.iv_invoice_opening_p]"} {options $boolean_options}}
	{invoice_p:text(radio) {label "[_ invoices.iv_invoice_p]"} {options $boolean_options}}
	{copy_p:text(radio) {label "[_ invoices.iv_invoice_copy_p]"} {options $boolean_options}}
	{email_p:text(radio) {label "[_ invoices.iv_invoice_email_p]"} {options $email_options}}
    }
}

if {!$_invoice_id} {
    # adding a new invoice
    if {![empty_string_p $project_id]} {

	# get all subprojects marked for no invoice to display warning
	foreach main_project_id $project_id {
	    set subprojects [pm::project::subprojects -project_item_id $main_project_id]

	    db_foreach not_invoiceable_subprojects {} {
		set offer_url [export_vars -base offer-ae {offer_id {mode display}}]
		lappend no_invoice($main_project_id) "<a href=\"$offer_url\">$offer_title</a>"
	    }
	}

	set project_title 0
	db_foreach offer_items {} -column_array offer {

	    # check if project changed in loop over offer-items
	    # show warning of subprojects without invoice if necessary
	    if {$project_title != $offer(project_title) && $project_title != "0" && [exists_and_not_null no_invoice($old_project_id)]} {
		ad_form -extend -name iv_invoice_form -form \
		    [list [list "no_invoice.${old_project_id}:text(inform),optional" \
			       [list label "<font color=red>\#invoices.iv_invoice_no_invoice\#</font>"] \
			       [list value "<ul><li>[join $no_invoice($old_project_id) "</li><li>"]</li></ul>"] \
			       [list section "<a href=\"$offer_url\">[_ invoices.iv_invoice_project_title] $project_title</a>"] ] ]
	    }

	    set offer(price_per_unit) [format "%.2f" $offer(price_per_unit)]
	    set offer(amount_sum) [format "%.2f" [expr $offer(item_units) * $offer(price_per_unit)]]
	    set offer(amount) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(amount_sum)]]
	    set offer(rebate) [format "%.1f" $offer(rebate)]
	    set offer(category) [lang::util::localize [category::get_name $offer(category_id)]]

	    if {[empty_string_p $offer(credit_percent)]} {
		set offer(credit_percent) 0.
	    }
	    if {$offer(price_per_unit) > 1.} {
		set offer(credit_units) [expr $offer(item_units) * (($offer(credit_percent) + 100.) / 100.)]
	    } else {
		# do not add credit to items with price of 1 or less
		set offer(credit_units) $offer(item_units)
	    }
	    set offer(credit) [format "%.2f" [expr $offer(credit_units) * $offer(price_per_unit)]]
	    ns_log Debug "Granted credit:: $offer(credit)"
	    set offer(credit) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(credit)]]
	    set offer(credit) [format "%.2f" [expr $offer(credit) - $offer(amount)]]
	    ns_log Debug "Total credit:: $offer(credit)"

	    set offer_name ""
	    if {![empty_string_p $offer(category)]} {
		set offer_name "$offer(category): "
	    }
	    append offer_name "$offer(item_units) x $offer(price_per_unit) $currency = $offer(amount_sum) $currency"
	    if {$offer(rebate) > 0} {
		append offer_name " - $offer(rebate)% [_ invoices.iv_offer_item_rebate] = $offer(amount) $currency"
	    }
	    if {![empty_string_p $offer(description)]} {
		append offer_name " ($offer(description))"
	    }

	    set offers($offer(offer_item_id)) [array get offer]
	    set offer_url [export_vars -base offer-ae {{offer_id $offer(offer_cr_item_id)} {mode display} {return_url $current_url}}]
	    set project_title $offer(project_title)
	    set old_project_id $offer(project_id)

	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(offer_item_id)}:text(checkbox),optional" \
			   [list label "$offer(item_nr), $offer(title)"] \
			   [list options [list [list "$offer_name" t]]] \
			   [list values [list t]] \
			   [list section "<a href=\"$offer_url\">[_ invoices.iv_invoice_project_title] $project_title</a>"] ] ]
	}

	# check if project changed in loop over offer-items
	# show warning of subprojects without invoice if necessary
	if {[exists_and_not_null offer(project_title)] && [exists_and_not_null no_invoice($old_project_id)]} {
	    ad_form -extend -name iv_invoice_form -form \
		[list [list "no_invoice.${old_project_id}:text(inform),optional" \
			   [list label "<font color=red>\#invoices.iv_invoice_no_invoice\#</font>"] \
			   [list value "<ul><li>[join $no_invoice($old_project_id) "</li><li>"]</li></ul>"] \
			   [list section "<a href=\"$offer_url\">[_ invoices.iv_invoice_project_title] $project_title</a>"] ] ]
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

	# Do not round the credit given.
	if {$offer(price_per_unit) > 1.} {
	    set offer(credit) [expr $offer(item_units) * (($offer(credit_percent) + 100.) / 100.)]
	} else {
	    # do not add credit to items with price of 1 or less
	    set offer(credit) $offer(item_units)
	}
	set offer(credit) [format "%.2f" [expr $offer(credit) * $offer(price_per_unit)]]
	set offer(credit) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(credit)]]
	set offer(credit) [format "%.2f" [expr $offer(credit) - $offer(amount)]]

	set offer_name ""
	if {![empty_string_p $offer(category)]} {
	    set offer_name "$offer(category): "
	}
	append offer_name "$offer(item_units) x $offer(price_per_unit) $currency = $offer(amount_sum) $currency"
	if {$offer(rebate) > 0} {
	    append offer_name " - $offer(rebate)% [_ invoices.iv_offer_item_rebate] = $offer(amount) $currency"
	}
	if {![empty_string_p $offer(description)]} {
	    append offer_name " ($offer(description))"
	}

	set offers($offer(iv_item_id)) [array get offer]
	set offer_url [export_vars -base offer-ae {{offer_id $offer(offer_cr_item_id)} {mode display} {return_url $current_url}}]

	if {$mode == "edit"} {
	    # edit: use checkboxes
	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(iv_item_id)}:text(checkbox)" \
			   [list label "$offer(item_nr), $offer(title)"] \
			   [list options [list [list "$offer_name" t]]] \
			   [list values [list t]] \
			   [list section "<a href=\"$offer_url\">[_ invoices.iv_invoice_project_title] $offer(project_title)</a>"] ] ]
	} else {
	    # display: no checkboxes
	    ad_form -extend -name iv_invoice_form -form \
		[list [list "offer_item_ids.${offer(iv_item_id)}:text(inform)" \
			   [list label "$offer(title), $offer(item_nr)"] \
			   [list value "$offer_name"] \
			   [list section "<a href=\"$offer_url\">[_ invoices.iv_invoice_project_title] $offer(project_title)</a>"] ] ]
	}
    }
}

if {$mode == "display"} {
    ad_form -extend -name iv_invoice_form -form {
	{send:text(submit) {label "[_ invoices.iv_invoice_send]"} {value t}}
    }
}


ad_form -extend -name iv_invoice_form -new_request {
    set opening_p 0
    set invoice_p 1
    set copy_p 0
    set email_p j

    if {[exists_and_not_null project_id]} {
	set description [lang::util::localize [join [db_list project_titles {}] ",\n"]]
    } else {
	set description ""
    }

    set due_date [db_string today {}]
    set title "[_ invoices.iv_invoice_1] $organization_name $due_date"

    db_1row offer_data {}

    set invoice_rebate $open_rebate

    set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]

    set project_recipients [db_list recipients {}]
    set recipient_id [lindex $project_recipients 0]

    if {$recipient_id eq ""} {
	set rec_organization_id $organization_id
    } else {
	if {[person::person_p -party_id $recipient_id]} {
	    set rec_organization_id [lindex [contact::util::get_employee_organization -employee_id $recipient_id] 0]
	} else {
	    set rec_organization_id $recipient_id
	}
    }

    array set org_data [contacts::get_values \
			    -group_name "Customers" \
			    -object_type "organization" \
			    -party_id $rec_organization_id \
			    -contacts_package_id $contacts_package_id]
    if {[info exists org_data(vat_percent)]} {
	set vat_percent [format "%.1f" $org_data(vat_percent)]
    } else {
	set vat_percent [format "%.1f" 0]
    }
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
	set total_amount [expr $total_amount + $offer(amount) + $offer(credit)]
	set total_credit [expr $total_credit + $offer(credit)]
    }
    set credit_category_id [parameter::get -parameter "CreditCategory"]
    set total_amount [format "%.2f" $total_amount]
    set amount_sum $total_amount
    if {[exists_and_not_null invoice_rebate]} {
	set total_amount [expr $total_amount - $invoice_rebate]
    }
    set total_amount [format "%.2f" $total_amount]


    # Get the VAT percent from the recieving company
    if {[person::person_p -party_id $recipient_id]} {
	set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]
	set rec_organization_id [contact::util::get_employee_organization -employee_id $recipient_id -package_id $contacts_package_id]
    } else {
	set rec_organization_id $recipient_id
    }

    if {$rec_organization_id eq ""} {
	ad_return_error "[_ invoices.no_organization_for_invoice]" "[_ invoices.lt_no_org_for_invoice]"
    }
    set rec_orga_rev_id [content::item::get_best_revision -item_id $rec_organization_id]
    set vat_percent [ams::value -object_id $rec_orga_rev_id -attribute_name vat_percent]

    if {$vat_percent eq ""} {
	set vat_percent [format "%.1f" 0]
    } else {
	set vat_percent [format "%.1f" $vat_percent]
    }

    set vat [format "%.2f" [expr $total_amount * $vat_percent / 100.]]

} -new_data {

    db_transaction {
	set new_invoice_rev_id [iv::invoice::new  \
				    -title $title \
				    -description $description  \
				    -contact_id $contact_id \
				    -recipient_id $recipient_id \
				    -invoice_nr $invoice_nr \
				    -organization_id $rec_organization_id \
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
	    if {![string is double -strict $offer(vat)]} {
		set offer(vat) 0
	    }

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
				       -item_units -$total_credit \
				       -price_per_unit 1 \
				       -rebate 0 \
				       -sort_order $invoice_id \
				       -vat $vat_credit]

	    category::map_object -object_id $offer_item_rev_id $credit_category_id
	}
    }
} -edit_data {
    db_transaction {
	set new_invoice_rev_id [iv::invoice::edit \
				    -invoice_item_id $invoice_id \
				    -title $title \
				    -description $description  \
				    -contact_id $contact_id \
				    -recipient_id $recipient_id \
				    -invoice_nr $invoice_nr \
				    -organization_id $rec_organization_id \
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
	    if {![string is double -strict $offer(vat_old)]} {
		set offer(vat_old) 0
	    }
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
				       -item_units -$total_credit \
				       -price_per_unit 1 \
				       -rebate 0 \
				       -sort_order $invoice_id \
				       -vat $vat_credit]

	    category::map_object -object_id $offer_item_rev_id $credit_category_id
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

    # Force opening if different recipient
    if {![string eq $recipient_id $contact_id]} {
	set opening_p 1
    }

    if {[empty_string_p $return_url]} {
	set return_url "/contacts/$organization_id/"
    }

    switch $email_p {
	t { ad_returnredirect [export_vars -base "invoice-send" {invoice_id opening_p invoice_p copy_p return_url}] }
	f { ad_returnredirect [export_vars -base "invoice-documents" {invoice_id opening_p invoice_p copy_p return_url}] }
	j { ad_returnredirect [export_vars -base "invoice-documents" {invoice_id opening_p invoice_p copy_p {display_p 0} return_url}] }
    }

    ad_script_abort
}

ad_return_template
