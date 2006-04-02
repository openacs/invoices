ad_page_contract {
    Index page.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]

set page_title "[_ invoices.invoices]"
set context [list]

set folder_id [parameter::get -parameter "JournalFolderID"]
acs_object::get -object_id $folder_id -array folder
set fs_package_id $folder(package_id)
set fs_package_url [site_node::get_url_from_object_id -object_id $fs_package_id]
set fs_folder_url [export_vars -base "${fs_package_url}index" {folder_id {orderby name,desc}}]

ad_return_template
