ad_page_contract {
    Form to send an offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    offer_id:integer
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_send]"

db_1row offer_data {}

set context [list [list [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]"] [list [export_vars -base offer-ae {offer_id}] "[_ invoices.iv_offer_View]"] $page_title]

set offer_text [iv::offer::text -offer_id $offer_id]

if {[empty_string_p $accepted_date]} {
    # send pending offer
    set offer_text "{[_ invoices.iv_offer_email]}"
} else {
    # send accepted offer
    set offer_text "{[_ invoices.iv_offer_accepted_email]}"
}

set party_ids [contact::util::get_employees -organization_id $organization_id]
set return_url [export_vars -base offer-list {organization_id}]
set file_ids [db_string get_files {} -default ""]
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
ad_return_template
