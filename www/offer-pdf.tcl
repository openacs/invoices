ad_page_contract {
    add offer-pdf to offer / accepted offer folder

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-05
} {
    offer_id:integer
    file_id:integer
}

set user_id [auth::require_login]
db_1row offer_data {}

set project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]
    set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
} else {
    set return_url [export_vars -base offer-list {organization_id}]
}

set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]

if {$status == "new"} {
    # this is an unaccepted offer
    set offer_folder_id [fs::get_folder -name "offers_${root_folder_id}" -parent_id $root_folder_id]
} else {
    # this is an accapted offer
    set offer_folder_id [fs::get_folder -name "accepted_${root_folder_id}" -parent_id $root_folder_id]
}

db_transaction {
    # move file to offer /accepted offer folder
    set file_item_id [content::revision::item_id -revision_id $file_id]
    content::item::move -item_id $file_item_id -target_folder_id $offer_folder_id
    application_data_link::new -this_object_id $offer_id -target_object_id $file_id
}

ad_returnredirect $return_url
