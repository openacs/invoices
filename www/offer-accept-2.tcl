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
set locale [lang::user::site_wide_locale -user_id $contact_id]

set context [list [list [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]"] [list [export_vars -base offer-ae {offer_id}] "[_ invoices.iv_offer_View]"] $page_title]

set subject [lang::util::localize "#invoices.iv_offer_accepted_email_subject#" $locale]
set template "OfferAcceptedTemplate"
set offer_text [iv::offer::parse_data -offer_id $offer_id -recipient_id $contact_id -template $template -locale $locale]

if {[empty_string_p $file_ids]} {
    set pdf_file [text_templates::create_pdf_from_html -html_content "$offer_text"]
    if {![empty_string_p $pdf_file]} {
	set file_size [file size $pdf_file]
	set file_ids [cr_import_content -title "Accepted_Offer_${offer_id}.pdf" -description "PDF version of <a href=[export_vars -base "/invoices/offer-ae" -url {{mode display} offer_id}]>this offer</a>" $offer_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
    }
}

if {[empty_string_p [cc_email_from_party $contact_id]]} {
    ad_return_error "No Recipient" "The recipient does not have a valid e-mail address. Please go back and make sure that you provide an e-mail address first."
}

set cancel_url [export_vars -base offer-list {organization_id}]
set invoice_url [site_node::get_package_url -package_key invoices]
set return_url [export_vars -base "${invoice_url}offer-ae" {offer_id {mode display}}]
set extra_data [list offer_id $offer_id]

ad_return_template
