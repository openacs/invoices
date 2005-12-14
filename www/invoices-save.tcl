ad_page_contract {
    add invoice-pdfs to invoice folder

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-12-10
} {
    file_id:integer,multiple
}

set user_id [auth::require_login]
db_1row invoice_data {}

set return_url [export_vars -base invoice-list {organization_id}]
set root_folder_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type content_folder] 0]
set invoice_folder_id [fs::get_folder -name "invoices" -parent_id $root_folder_id]

db_transaction {
    # move files to invoice_folder
    foreach one_file_id $file_id {
	db_1row get_parent_invoice_id {}
	set file_item_id [content::revision::item_id -revision_id $one_file_id]
	content::item::move -item_id $file_item_id -target_folder_id $invoice_folder_id
	application_data_link::new -this_object_id $invoice_id -target_object_id $one_file_id
	iv::invoice::set_status -invoice_id $invoice_id -status "billed"
    }
}

ad_returnredirect $return_url
