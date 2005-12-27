ad_page_contract {
    add invoice-pdfs to invoice folder

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-05
} {
    invoice_id:integer
    file_id:integer,multiple
}

set user_id [auth::require_login]
db_1row invoice_data {}

set project_id [lindex [application_data_link::get_linked -from_object_id $invoice_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
    set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
} else {
    set return_url [export_vars -base invoice-list {organization_id}]
}

set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]
set invoice_folder_id [fs::get_folder -name "invoices_${root_folder_id}" -parent_id $root_folder_id]
db_transaction {
    # move files to invoice_folder
    foreach one_file $file_id {
	set file_item_id [content::revision::item_id -revision_id $one_file]
	content::item::move -item_id $file_item_id -target_folder_id $invoice_folder_id
	db_dml set_publish_status {}
	application_data_link::new -this_object_id $invoice_id -target_object_id $one_file
    }
    iv::invoice::set_status -invoice_id $invoice_id -status "billed"
}

ad_returnredirect $return_url
