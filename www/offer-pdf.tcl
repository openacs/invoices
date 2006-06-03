ad_page_contract {
    add offer-pdf to offer / accepted offer folder
    and create task to call customer again

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-05
} {
    offer_id:integer
    file_id:integer
    {return_url ""}
}

set user_id [auth::require_login]
db_1row offer_data {}

set project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
    if {[empty_string_p $return_url]} {
	set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
    }
    db_1row project_data {}
} elseif {[empty_string_p $return_url]} {
    set return_url [export_vars -base offer-list {organization_id}]
}

set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]

if {$status == "new"} {
    # this is an unaccepted offer
    set offer_folder_id [fs::get_folder -name "offers_${root_folder_id}" -parent_id $root_folder_id]
} else {
    # this is an accepted offer
    set offer_folder_id [fs::get_folder -name "accepted_${root_folder_id}" -parent_id $root_folder_id]
}

db_transaction {
    # move file to offer /accepted offer folder
    if {![string eq "" $offer_folder_id]} {
	content::item::move -item_id $file_id -target_folder_id $offer_folder_id
    } else {
	ns_log Error "No folder for status $status for customer $organization_id in root_folder $root_folder_id"
    }

    application_data_link::new -this_object_id $offer_id -target_object_id $file_id
    db_dml set_publish_status {}
    db_dml set_context_id {}

    # Set the task by default to phone three days later.
    set due_date [clock format [clock scan "3 days" -base [clock scan [dt_systime]]] -format "%Y-%m-%d"]

    # Make sure to set the task only once
    set task_generated_p [db_string task_generated "select count(*) from t_tasks where object_id=:offer_id and status_id <> 2"]
    
    # Set the assignee to the account manager of the organization
    # Otherwise use user_id

    set assignee_ids [contacts::util::get_account_manager -organization_id $organization_id]
    
    if {$assignee_ids eq ""} {
	set assignee_ids $user_id
    }
			      

    if {!$task_generated_p && [apm_package_installed_p "tasks"] && [string eq $status "new"]} {

	foreach assignee_id $assignee_ids {
	    # Create a task for the saved offer

	    # the apm_package_id_from_key for the package_id is not a permanent fix
            # and will break this feature on servers with multiple contacts instances
            # we need some way of figuring out what what package_id of a contacts
            # instance this task should be assigned to for this invoices instance.

	    set task_id [tasks::task::new \
			     -title "Nachfassen Angebot" \
			     -description "Angebot Nr. <a href=\"[export_vars -base "[ad_url][ad_conn package_url]offer-ae" -url {offer_id {mode display}}]\">$offer_nr</a>" \
			     -mime_type "text/html" \
			     -object_id $contact_id \
			     -due_date ${due_date} \
			     -priority "1" \
			     -assignee_id $assignee_id \
                             -package_id [apm_package_id_from_key contacts] \
			    ]

	    # tasks doesn't do anything with this data link but its probably worth
            # keeping just in case it does something with it in the future.
	    application_data_link::new -this_object_id $offer_id -target_object_id $task_id
	}
    }
}

ad_returnredirect $return_url
