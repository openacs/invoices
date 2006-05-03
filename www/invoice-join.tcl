ad_page_contract {
    Joins all invoice-pdfs since last join and returns big pdf.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2006-05-02
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set package_id [ad_conn package_id]
set user_id [auth::require_login]

set page_title "[_ invoices.iv_invoice_join]"
set context [list [list [export_vars -base invoice-list {organization_id}] "[_ invoices.iv_invoice_2]"] $page_title]

db_1row today {}

set root_dir [cr_fs_path]
set root_folder_id [content::folder::get_folder_from_package -package_id $package_id]
set invoice_title [lang::util::localize "#invoices.file_joined_invoice#_${today}.pdf"]

db_transaction {
    db_1row last_checkout {}

    set tmpdir [ns_tmpnam]
    ns_mkdir $tmpdir
    set files {}
    db_foreach pdfs_to_join {} {
	ns_cp "${root_dir}$content" "${tmpdir}/[file tail $content].pdf"
	lappend files "${tmpdir}/[file tail $content].pdf"
    }

    set file_id [contact::oo::join_pdf -filenames $files -title $invoice_title -parent_id $root_folder_id]
    db_1row get_file_location {}

    db_dml mark_join_creation {}
    db_dml mark_invoices_billed {}

    # delete old files
    foreach one_file $files {
	ns_unlink $one_file
    }
    ns_rmdir $tmpdir
}

ns_returnfile 200 "application/pdf" "${root_dir}$file_location"
