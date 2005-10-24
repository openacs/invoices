ad_page_contract {
    Accept Offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    offer_id
    {return_url ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_accept]"
set context [list [list "offer-list" "[_ invoices.iv_offer_2]"] $page_title]

set confirm_options [list [list "[_ invoices.continue_with_accept]" t] [list "[_ invoices.cancel_and_return]" f]]
set accept_2_url [export_vars -base offer-accept-2 {offer_id return_url}]

ad_form -name accept_confirm -action offer-accept -form {
    {offer_id:key}
    {title:text(inform) {label "[_ invoices.iv_offer_accept]"}}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value t}}
} -select_query_name {title} \
-on_submit {
    if {$confirmation} {
	db_transaction {
	    iv::offer::accept -offer_id $offer_id
	    callback iv::offer_accept -offer_id $offer_id
	}
    }
} -after_submit {
    if {$confirmation} {
	ad_returnredirect $accept_2_url
	ad_script_abort
    } else {
	ad_returnredirect [export_vars -base offer-ae {offer_id {mode display}}]
	ad_script_abort
    }
}

ad_return_template
