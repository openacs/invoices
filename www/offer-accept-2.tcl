ad_page_contract {
    Form to send an accepted offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    offer_id:integer
    {file_ids ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_send]"

db_1row offer_data {}

set party_ids [contact::util::get_employees -organization_id $organization_id]
set project_id [lindex [application_data_link::get_linked -from_object_id $offer_id -to_object_type content_item] 0]

db_1row project_data {}

set context [list [list [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]"] [list [export_vars -base offer-ae {offer_id}] "[_ invoices.iv_offer_View]"] $page_title]

# set offer_text [iv::offer::text -offer_id $offer_id]

set offer_text [iv::offer::parse_data -offer_id $offer_id -recipient_id [lindex $party_ids 0]]

if {[empty_string_p $file_ids]} {
    set pdf_file [text_templates::create_pdf_from_html -html_content "$offer_text"]
    if {![empty_string_p $pdf_file]} {
	set file_size [file size $pdf_file]
	set file_ids [cr_import_content -title "Offer $offer_id" -description "PDF version of <a href=[export_vars -base "/invoices/offer-ae" -url {{mode display} organization_id}]>this offer</a>" $offer_id $pdf_file $file_size application/pdf "Offer $offer_id"]
    }
}

set offer_text "{[_ invoices.iv_offer_accepted_email]}"


set parties_new [list]
foreach party_id $party_ids {
    
    # Check if the party has a valid e-mail address
    if {![empty_string_p [cc_email_from_party $party_id]]} {
	lappend parties_new $party_id
    }
}

if {[empty_string_p $parties_new]} {
    ad_return_error "No Recipient" "None of the recipients has a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
} else {
    set party_ids $parties_new
}

set cancel_url [export_vars -base offer-list {organization_id}]
set invoice_url [site_node::get_package_url -package_key invoices]
set return_url [export_vars -base "${invoice_url}offer-ae" {offer_id {mode display}}]
set extra_data [list offer_id $offer_id]

ad_return_template
