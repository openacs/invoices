ad_page_contract {
    Form to send an offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    offer_id:integer
    {return_url ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_send]"

db_1row offer_data {}
set project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]
db_1row project_data {}
set locale [lang::user::site_wide_locale -user_id $contact_id]

set context [list [list [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]"] [list [export_vars -base offer-ae {offer_id}] "[_ invoices.iv_offer_View]"] $page_title]

set x [iv::util::get_x_field -offer_id $offer_rev_id]
set accept_link [export_vars -base "[ad_url][ad_conn package_url]offer-accepted" {x {offer_id $offer_rev_id}}]
content::item::set_live_revision -revision_id $offer_rev_id

if {[empty_string_p $accepted_date]} {
    # send pending offer
    set offer_text "{#invoices.iv_offer_email#}"
    set subject [lang::util::localize "#invoices.iv_offer_email_subject#" $locale]
    set template "OfferTemplate"
    set document_type "offer"
    set file_title [lang::util::localize "#invoices.file_offer#_${offer_nr}.pdf" $locale]
} else {
    # send accepted offer
    set offer_text "{#invoices.iv_offer_accepted_email#}"
    set subject [lang::util::localize "#invoices.iv_offer_accepted_email_subject#" $locale]
    set template "OfferAcceptedTemplate"
    set document_type "accepted"
    set file_title [lang::util::localize "#invoices.file_offer_accepted#_${offer_nr}.pdf" $locale]
}

# substitute variables in offer text
# and return the content of the email plus the file-paths to the document file
set documents [iv::offer::parse_data -offer_id $offer_id -type $document_type -email_text $offer_text -accept_link $accept_link]

set offer_text [lindex $documents 0]

set file_ids {}
set document_file [lindex $documents 1]
if {![empty_string_p $document_file]} {
    set file_size [file size $document_file]
    set file_ids [contact::oo::import_oo_pdf -oo_file $document_file -printer_name "pdfconv" -title $file_title -parent_id $offer_id]

    # set file_ids [cr_import_content -title $file_title -description "PDF version of <a href=[export_vars -base "/invoices/offer-ae" -url {{mode display} offer_id}]>this offer</a>" $offer_id $document_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
    # content::item::set_live_revision -revision_id $file_ids

    db_dml set_publish_status {}
}

if {[llength $file_ids] > 0} {
    set return_url [export_vars -base offer-pdf {offer_id {file_id $file_ids}}]
} else {
    set return_url ""
}

set project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]
if {![empty_string_p $project_id]} {
    acs_object::get -object_id $project_id -array project
    set pm_url [lindex [site_node::get_url_from_object_id -object_id $project(package_id)] 0]

    # We might have a return_url passed in.
    if {[empty_string_p $return_url]} {
	set return_url [export_vars -base "${pm_url}one" {{project_item_id $project_id}}]
    }
} else {
    if {[empty_string_p $return_url]} {
	set return_url [export_vars -base offer-list {organization_id}]
    }
}

if {[empty_string_p [cc_email_from_party $contact_id]]} {
    ad_return_error "No Recipient" "The recipient does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
}

ad_return_template
