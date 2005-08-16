ad_page_contract {
    Accept Offer.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-21
} {
    offer_id
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_offer_accept]"
set context [list [list "offer-list" "[_ invoices.iv_offer_2]"] $page_title]

set confirm_options [list [list "[_ invoices.continue_with_accept]" t] [list "[_ invoices.cancel_and_return]" f]]

ad_form -name accept_confirm -action offer-accept -form {
    {offer_id:key}
    {title:text(inform) {label "[_ invoices.iv_offer_accept]"}}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value f}}
} -select_query_name {title} \
-on_submit {
    if {$confirmation} {
	iv::offer::accept -offer_id $offer_id
    }
} -after_submit {
    if {$confirmation} {
	ad_returnredirect [export_vars -base offer-accept-2 {offer_id}]
	ad_script_abort
    } else {
	ad_returnredirect [export_vars -base offer-ae {offer_id {mode display}}]
	ad_script_abort
    }
}

ad_return_template
