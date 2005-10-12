ad_library {
    Invoices Package install callbacks
    
    Procedures that deal with installing.
    
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

ad_proc -public -callback pm::project_new -impl invoices {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    Set parent_id of offer to new project
} {
    array set callback_data $data
    if {[info exists callback_data(offer_id)]} {
	set offer_id $callback_data(offer_id)
	application_data_link::new -this_object_id $offer_id -target_object_id $project_id
    }
}

ad_proc -public -callback pm::task_close -impl invoices {
    {-package_id:required}
    {-task_id:required}
} {
    Create new cost every time a project task is closed
} {
    set task_rev_id [pm::task::get_revision_id -task_item_id $task_id]
    set project_rev_id [pm::project::get_project_id -project_item_id [pm::task::project_item_id -task_item_id $task_id]]

    db_1row task_data {
	select r.title as task_title, r.description as task_description,
	       t.actual_hours_worked as amount, p.customer_id
	from cr_revisions r, pm_tasks_revisions t, pm_projects p
	where r.revision_id = :task_rev_id
	and t.task_revision_id = r.revision_id
	and p.project_id = :project_rev_id
    }

    foreach iv_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "invoices"] {

	array set price [iv::price::get -organization_id $customer_id -object_id $task_rev_id -package_id $iv_package_id]

	if {![info exists price(currency)]} {
	    # no price entry found
	    set price(amount) 1
	    set price(currency) [parameter::get -parameter "DefaultCurrency" -default "EUR" -package_id $iv_package_id]
	}

	if {[empty_string_p $amount]} {
	    set amount 0
	}

	db_1row check_cost_exists {
	    select max(cr.item_id) as cost_id
	    from iv_costs c, cr_revisions cr, cr_revisions tr,
	         acs_objects o
	    where tr.item_id = :task_id
	    and tr.revision_id = c.cost_object_id
	    and c.cost_id = cr.revision_id
	    and o.object_id = c.cost_id
	    and o.package_id = :iv_package_id
	}

	if {[empty_string_p $cost_id]} {
	    # no cost entry found for this task
	    set new_cost_id [iv::cost::new  \
				 -package_id $iv_package_id \
				 -title $task_title \
				 -description $task_description  \
				 -cost_nr $task_id \
				 -organization_id $customer_id \
				 -cost_object_id $task_rev_id \
				 -item_units $amount \
				 -price_per_unit $price(amount) \
				 -currency $price(currency) ]
	} else {
	    # create new revision of existing cost entry
	    set new_cost_id [iv::cost::edit \
				 -cost_item_id $cost_id \
				 -title $task_title \
				 -description $task_description  \
				 -cost_nr $task_id \
				 -organization_id $customer_id \
				 -cost_object_id $task_rev_id \
				 -item_units $amount \
				 -price_per_unit $price(amount) \
				 -currency $price(currency) ]
	}

	array unset price
    }
}

ad_proc -public -callback pm::project_links -impl invoices {
    {-project_id:required}
} {
} {
    if {![apm_package_installed_p translation]} {
	upvar project_links project_links
	set invoice_base_url [site_node::get_package_url -package_key invoices]
	set offer_id [lindex [application_data_link::get_linked -from_object_id $project_id -to_object_type content_item] 0]

	if {![empty_string_p $offer_id]} {
	    # link to linked offer
	    # append project_links "<li> <a href=\"[export_vars -base "${invoice_base_url}offer-ae" {offer_id {mode display}}]\">[_ invoices.iv_offer_View]</a></li>"
	} else {
	    # link to offer-list
	    db_1row get_project_organization {
		select p.customer_id as organization_id
		from pm_projects p, cr_items i
		where i.item_id = :project_id
		and p.project_id = i.latest_revision
	    }

	    append project_links "<li> <a href=\"[export_vars -base "${invoice_base_url}offer-list" {organization_id}]\">[_ invoices.iv_offer_list]</a></li>"
	}
    }
}

ad_proc -public -callback iv::offer_accept {
    {-offer_id:required}
} {
}

ad_proc -public -callback iv::offer_accepted {
    {-offer_id:required}
    {-party_id:required}
} {
}

ad_proc -public -callback contacts::populate::organization::customer_attributes -impl invoices {
    {-list_id:required}
} {
    register customer attributes payment_days, vat_percent
} {
    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "payment_days" \
			  -datatype "number" \
			  -pretty_name "Payment after .. days" \
			  -pretty_plural "Payments after .. days" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "100" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "30"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "60"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "90"]

    set attribute_id [attribute::new \
			  -object_type "organization" \
			  -attribute_name "vat_percent" \
			  -datatype "number" \
			  -pretty_name "%VAT" \
			  -pretty_plural "%VAT" \
			  -if_does_not_exist]

    ams::attribute::new \
	-attribute_id $attribute_id \
	-widget "select" \
	-dynamic_p "t"

    ams::list::attribute::map \
	-list_id $list_id \
	-attribute_id $attribute_id \
	-sort_order "110" \
	-required_p "f" \
	-section_heading ""

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "7"]

    set option_id [ams::option::new \
		       -attribute_id $attribute_id \
		       -option "16"]
}

ad_proc -public -callback pm::install::after_instantiate -impl invoices {
    {-package_id:required}
} {
    link new project manager with invoices instance
} {
    if {[db_0or1row invoice_package_ids "select package_id as invoices_package_id from apm_packages where package_key = 'invoices'"]} {
	application_link::new -this_package_id $package_id -target_package_id $invoices_package_id
    }
}

ad_proc -public -callback contacts::after_instantiate -impl invoices {
    {-package_id:required}
} {
    link new contacts with invoices instance
} {
    if {[db_0or1row invoice_package_ids "select package_id as invoices_package_id from apm_packages where package_key = 'invoices'"]} {
	application_link::new -this_package_id $package_id -target_package_id $invoices_package_id
    }
}

ad_proc -public -callback acs_mail_lite::email_form_elements -impl invoices {
    -varname:required
} {
} {
    upvar elements $varname template_list template_list template_type template_type template_object template_object

    if {[exists_and_not_null template_list]} {
	append elements {
	    {template:text(select)
		{label "[_ invoices.email_template]"}
		{options $template_list}
		{section "[_ contacts.Message]"}
	    }
	    {template_type:text(hidden)
		{value $template_type}
	    }
	    {template_object:text(hidden)
		{value $template_object}
	    }
	}
    }
}

ad_proc -public -callback acs_mail_lite::files -impl invoices {
    -varname:required
    -recipient_id
} {
} {
    upvar file_ids $varname template template template_type template_type template_object template_object

    if {[exists_and_not_null template_type] && $template_type == "invoice"} {

	switch $template_type {
	    invoice        { set pdf_title "Invoice" }
	    invoice_cancel { set pdf_title "Cancellation" }
	    invoice_credit { set pdf_title "Credit" }
	    offer          { set pdf_title "Offer" }
	    offer_accpeted { set pdf_title "Accepted_Offer" }
	}

	if {$template_type == "invoice" || $template_type == "invoice_cancel" || $template_type == "invoice_credit"} {
	    set invoice_id $template_object
	    set locale [lang::user::site_wide_locale -user_id $recipient_id]
	    set invoice_text [iv::invoice::parse_data -invoice_id $invoice_id -recipient_id $recipient_id -template $template -locale $locale]

	    set pdf_file [text_templates::create_pdf_from_html -html_content "$invoice_text"]
	    if {![empty_string_p $pdf_file]} {
		set file_size [file size $pdf_file]
		lappend file_ids [cr_import_content -title "${pdf_title}_${invoice_id}.pdf" -description "PDF version of <a href=[export_vars -base "/invoices/invoice-ae" -url {{mode display} invoice_id}]>this offer</a>" $invoice_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]]
	    }
        }

	if {$template_type == "offer" || $template_type == "offer_accepted"} {
	    set offer_id $template_object
	    set offer_rev_id [content::item::get_live_revision -item_id $offer_id]
	    set locale [lang::user::site_wide_locale -user_id $recipient_id]

	    set x [iv::util::get_x_field -offer_id $offer_rev_id]
	    set accept_link [export_vars -base "[ad_url][ad_conn package_url]offer-accepted" {x {offer_id $offer_rev_id}}]
	    set offer_text [iv::offer::parse_data -offer_id $offer_id -recipient_id $recipient_id -template $template -locale $locale -accept_link $accept_link]

	    set pdf_file [text_templates::create_pdf_from_html -html_content "$offer_text"]
	    if {![empty_string_p $pdf_file]} {
		set file_size [file size $pdf_file]
		lappend file_ids [cr_import_content -title "${pdf_title}_${offer_id}.pdf" -description "PDF version of <a href=[export_vars -base "/invoices/offer-ae" -url {{mode display} offer_id}]>this offer</a>" $offer_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
	    }
        }
    }
}
