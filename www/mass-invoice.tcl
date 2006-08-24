ad_page_contract {
    Page to mass generate inoices, one for each project

    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    @creation-date 2006-06-18
} {
    project_id:multiple
    {return_url:optional ""}
    {__new_p 0}
    {mode edit}
    {send:optional}
} -properties {
    context:onevalue
    page_title:onevalue
}

set current_url "[ad_conn url]?[ad_conn query]"
set package_id [ad_conn package_id]
set user_id [auth::require_login]
set date_format "YYYY-MM-DD"
set has_submit 0
set has_edit 0
set offer_ids [list]
set files [list]
set failed_project_ids [list]
set failed_project_id2 [list]

if {$__new_p} {
    set project_id [string trim $project_id "{}"]
}
set page_title "[_ invoices.iv_invoice_Add2]"
set _invoice_id 0
set invoice_rev_id 0
set cur_total_amount 0

array set container_objects [iv::util::get_default_objects -package_id $package_id]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

set language [lang::conn::language]

ad_progress_bar_begin -title [_ invoices.Create_mass_invoices] -message_1 "[_ invoices.Create_mass_invoices2]"

# We need to catch this so the joined PDF is generated and send.
catch {
    foreach project_item_id $project_id {

    # We need to make sure the whole process runs through smoothly for invoice
    # generation. Therefore we put this in transaction. If the transaction fails
    # add the project number to a list and notify the user about it later.

    # normal invoice: get recipients from projects
    db_1row contacts {}
    
    # Reset variables
    
    set project_title 0
    set total_amount 0.
    set total_credit 0.
    set offer_ids [list]	
    
    #####  INSERT INVOICE #################
    
    set due_date [db_string today {}]
    set title "[_ invoices.iv_invoice_1] [organizations::name -organization_id $customer_id] $due_date"
    
    db_1row offer_data {}

    set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]
    
    # Get the recipient information and data.
    if {$recipient_id eq ""} {
	set rec_organization_id $customer_id
    } else {
	if {[person::person_p -party_id $recipient_id]} {
	    set rec_organization_id [contact::util::get_employee_organization -employee_id $recipient_id -package_id $contacts_package_id]
	} else {
	    set rec_organization_id $recipient_id
	}
    }
    
    # If for whatever the reason we cannot find the organization for the recipient, use the customer
    if {$rec_organization_id eq ""} {
	set rec_organization_id $customer_id
    }

    array unset org_data
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
    
    set credit_category_id [parameter::get -parameter "CreditCategory"]
    set description [lang::util::localize [pm::project::name -project_item_id $project_item_id]]	
    
    # If an invoice exists with this description 
    
    if {[db_string existing_invoice "select 1 from iv_invoicesx where description = :description and status = 'new' limit 1" -default 0]} {
	continue
	}
    
    # We are getting the invoice_nr here as we are generating the PDF now.
    set invoice_nr [db_nextval iv_invoice_seq]
    
    set currency [iv::price_list::get_currency -organization_id $rec_organization_id]	

    db_transaction {
	set new_invoice_rev_id [iv::invoice::new  \
				    -title $title \
				    -description $description  \
				    -contact_id $contact_id \
				    -recipient_id $recipient_id \
				    -invoice_nr $invoice_nr \
				    -organization_id $rec_organization_id \
				    -total_amount $amount_total \
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
	
	
	###### Prepare invoice items ###########
	
	set counter 0
	
	
	# Can't use db_foreach as we are in a transaction
	set offer_items_list [db_list_of_lists offer_items {}]
	
	foreach offer_items $offer_items_list {
	    
	    template::util::list_to_array $offer_items offer [list title description offer_item_id item_units offer_id \
								  price_per_unit item_nr project_id credit_percent \
								  project_title vat rebate category_id offer_cr_item_id
							     ]
	    
	    
	    set offer(price_per_unit) [format "%.2f" $offer(price_per_unit)]
	    set offer(amount_sum) [format "%.2f" [expr $offer(item_units) * $offer(price_per_unit)]]
	    set offer(amount) [format "%.2f" [expr (1. - ($offer(rebate) / 100.)) * $offer(amount_sum)]]
	    set offer(rebate) [format "%.1f" $offer(rebate)]
	    set offer(category) [lang::util::localize [category::get_name $offer(category_id)]]
	    
	    # Calculate the credit
	    if {[empty_string_p $offer(credit_percent)]} {
		set offer(credit_percent) 0.
	    }
	    if {$offer(price_per_unit) > 1.} {
		set offer(credit) [format "%.1f" [expr $offer(item_units) * (($offer(credit_percent) + 100.) / 100.)]]
	    } else {
		# do not add credit to items with price of 1 or less
		set offer(credit) [format "%.1f" $offer(item_units)]
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
	    
	    set total_amount [expr $total_amount + $offer(amount) + $offer(credit)]
	    set total_credit [expr $total_credit + $offer(credit)]
	    
	    # Insert the invoice item
	    incr counter
	    set offer(vat) [expr $vat_percent * $offer(vat) / 100.]
	    
	    set new_item_rev_id [iv::invoice_item::new \
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
	    
	    # Append the offer_id so we can later on decide 
	    # if the offer/project should be marked as billed.
	    if {[lsearch $offer_ids $offer(offer_id)] < 0 } {
		lappend offer_ids $offer(offer_id)
	    }
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
	
    } on_error {
	
	lappend failed_project_ids $project_item_id
	continue
    }

    ############ PDF Generation ################
    
    set locale [lang::user::site_wide_locale -user_id $recipient_id]
    
    if {$total_amount >= 0} {
	
	# send invoice
	set invoice_title [lang::util::localize "#invoices.file_invoice#_${invoice_nr}.pdf" $locale]
	set document_type invoice
	
    } elseif {[empty_string_p $parent_invoice_id]} {
	
	# send credit
	set invoice_title [lang::util::localize "#invoices.file_invoice_credit#_${invoice_nr}.pdf" $locale]
	set document_type credit
    } else {
	
	# send cancellation
	set invoice_title [lang::util::localize "#invoices.file_invoice_cancel#_${invoice_nr}.pdf" $locale]
	set document_type cancel
    }
    
    # substitute variables in invoice text
    # and return the content of all necessary document files
    # (opening, invoice/credit/cancellation, copy)
    set documents [iv::invoice::parse_data -invoice_id $invoice_id -types $document_type -email_text ""]
    
    set file_title $invoice_title
    
    set document_file [lreplace $documents 0 0]
    
    # Import the PDF
    if {![empty_string_p $document_file]} {
	set file_size [file size $document_file]
	
	# We need to keep the file in the filesystem so we can later 
	# join the files into one PDF for printout.
	# Still the single PDF needs to be stored along with the invoice.
	
	util_unlist [contact::oo::import_oo_pdf -oo_file $document_file -printer_name "pdfconv" -title $file_title -parent_id $invoice_id -return_pdf_with_id] file_item_id file_mime_type file_name
	
	lappend files $file_name
	
	# an invoice has been generated. Now move it to the folder
	
	set root_folder_id [lindex [application_data_link::get_linked -from_object_id $customer_id -to_object_type content_folder] 0]
	set invoice_folder_id [fs::get_folder -name "invoices_${root_folder_id}" -parent_id $root_folder_id]
	if {[empty_string_p $invoice_folder_id]} {
	    # use folder of party if no invoice-folder exists
	    set invoice_folder_id $organization_id
	}
	
	# move files to invoice_folder
	application_data_link::new -this_object_id $invoice_id -target_object_id $file_item_id
	
	db_transaction {
	    db_dml set_publish_status_and_parent {}
	    db_dml set_context_id {}
	} on_error {
	    lappend failed_project_id2 $project_item_id
	    continue
	}
	iv::invoice::set_status -invoice_id $invoice_id -status "billed"
    }
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

# Now it is time to join the pdf together


if {[exists_and_not_null files]} {
    util_unlist [contact::oo::join_pdf -filenames $files -title "[_ invoices.invoices].pdf" -no_import] joined_mime_type joined_pdf
    set file_p 1
} else {
    set file_p 0
}

# Deal with failed projects

if {[exists_and_not_null failed_project_ids]} {
    set failed_projects_html "[_ invoices.mass_invoice_error]<ul>"
    foreach failed_project_id $failed_project_ids {
	append failed_projects_html "<li><a href=\"[export_vars -base "[apm_package_url_from_id $package_id]/invoice-ae" -url {{project_id $failed_project_id}}]\">[pm::project::name -project_item_id $failed_project_id]</a></li>"
    }
    append failed_projects_html "</ul>"
} else {
    set failed_projects_html ""
}

if {[exists_and_not_null failed_projectid2]} {
    append failed_projects_html "[_ invoices.mass_invoice_error]<ul>"
    foreach failed_project_id $failed_projectid2 {
	append failed_projects_html "<li><a href=\"[export_vars -base "[apm_package_url_from_id $package_id]/invoice-ae" -url {{project_id $failed_project_id}}]\">[pm::project::name -project_item_id $failed_project_id]</a></li>"
    }
    append failed_projects_html "</ul>"
}

# and send out the e-mail

if {$file_p} {
    acs_mail_lite::complex_send \
	-from_addr [party::email -party_id $user_id] \
	-to_party_ids "$user_id" \
	-subject [_ invoices.mass_invoice_email_subject] \
	-body [_ invoices.mass_invoice_email_body] \
	-files [list [list "[_ invoices.invoices].pdf" "$joined_mime_type" "$joined_pdf"]] \
	-mime_type "text/html"
} else {
    acs_mail_lite::complex_send \
	-from_addr [party::email -party_id $user_id] \
	-to_party_ids "$user_id" \
	-subject [_ invoices.mass_invoice_email_subject] \
	-body [_ invoices.mass_invoice_email_body] \
	-mime_type "text/html" 
}

ad_progress_bar_end -url $return_url