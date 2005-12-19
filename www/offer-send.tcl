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
    # set offer_text "{[_ invoices.iv_offer_email]}"
    set subject [lang::util::localize "#invoices.iv_offer_email_subject#" $locale]
    set template "OfferTemplate"
    set file_title [lang::util::localize "#invoices.file_offer#_${offer_nr}.pdf" $locale]
} else {
    # send accepted offer
    # set offer_text "{[_ invoices.iv_offer_accepted_email]}"
    set subject [lang::util::localize "#invoices.iv_offer_accepted_email_subject#" $locale]
    set template "OfferAcceptedTemplate"
    set file_title [lang::util::localize "#invoices.file_offer_accepted#_${offer_nr}.pdf" $locale]
}

set offer_text [iv::offer::parse_data -offer_id $offer_id -recipient_id $contact_id -template $template -locale $locale -accept_link $accept_link]

set pdf_file [text_templates::create_pdf_from_html -html_content "$offer_text"]
if {![empty_string_p $pdf_file]} {
    set file_size [file size $pdf_file]
    set file_ids [cr_import_content -title $file_title -description "PDF version of <a href=[export_vars -base "/invoices/offer-ae" -url {{mode display} offer_id}]>this offer</a>" $offer_id $pdf_file $file_size application/pdf "[clock seconds]-[expr round([ns_rand]*100000)]"]
    set return_url [export_vars -base offer-pdf {offer_id {file_id $file_ids}}]
} else {
    set file_ids ""
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

# Set the task by default to phone three days later.
set due_date [clock format [clock scan "3 days" -base [clock scan [dt_systime]]] -format "%Y-%m-%d"]

# Make sure to set the task only once
set task_generated_p [db_string task_generated "select count(*) from t_tasks where object_id=:offer_id and status_id <> 2"]

if {!$task_generated_p && [apm_package_installed_p "tasks"]} {

    # Create a task for the saved offer
    set task_id [tasks::task::new \
		     -title "Nachfassen Angebot" \
		     -description "Angebot Nr. <a href=\"[export_vars -base "[ad_url][ad_conn package_url]offer-ae" -url {offer_id {mode display}}]\">$offer_nr" \
		     -mime_type "text/plain" \
		     -party_id $contact_id \
		     -due_date ${due_date} \
		     -object_id $offer_id \
		     -mime_type "text/html" \
		     -priority "1"]
}

ad_return_template
