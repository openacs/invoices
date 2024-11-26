ad_page_contract {
    Joins all invoice-pdfs since last join and returns big pdf.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2006-05-02
} {
    return_url
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

    set tmpdir [ns_mktemp]
    file mkdir $tmpdir
    set files {}
    db_foreach pdfs_to_join {} {
	file copy "${root_dir}$content" "${tmpdir}/[file tail $content].pdf"
	lappend files "${tmpdir}/[file tail $content].pdf"
    }

    if {[llength $files] > 0} {
	set file_id [contact::oo::join_pdf -filenames $files -title $invoice_title -parent_id $root_folder_id]
	db_1row get_file_location {}

	db_dml mark_join_creation {}
	db_dml mark_invoices_billed {}

	# delete old files
	foreach one_file $files {
	    file delete $one_file
	}
    }
    file delete $tmpdir
}

set actions [list "[_ invoices.ok]" $return_url "[_ invoices.ok]"]
multirow create documents file_id file_title file_url

if {[llength $files] > 0} {
    multirow append documents $file_id $invoice_title [export_vars -base "/tracking/download/$invoice_title" {file_id}]
}

template::list::create \
    -name documents \
    -key file_id \
    -no_data "[_ invoices.None]" \
    -elements {
	file_id {
	    label {[_ invoices.iv_invoice_file]}
	    display_template {<a href="@documents.file_url@">@documents.file_title@</a>}
	}
    } -actions $actions -sub_class narrow

ad_return_template
