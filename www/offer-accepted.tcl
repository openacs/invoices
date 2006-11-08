ad_page_contract {
    Accepts offer by customer
} {
    {offer_id:integer ""}
    {x ""}
}

if {$offer_id eq "" || $x eq ""} {
    ad_return_complaint 1 [_ invoices.lt_empty_offer_id]
}

# Retrieving the value of the parameter to know wich include to call
set template_src [parameter::get -parameter "OfferAccept"]

if {![db_0or1row check_offer_id {}]} {
    ad_return_complaint 1 "This is not the latest offer."
    return
}

# user most likely clicked a link in an email
# verify the secret key
set valid_x_p [iv::util::valid_x_field_p -offer_id $offer_rev_id -x_field $x]
if {!$valid_x_p} {
    # could not verify the secret key for that user
    ad_return_complaint 1 "Invalid secret key"
    return
}

set page_title "[_ invoices.offer_accept]"

if {$valid_x_p && [empty_string_p $template_src]} {
    iv::offer::accept -offer_id $offer_id
    callback iv::offer_accept -offer_id $offer_id
    callback iv::offer_accepted -offer_id $offer_id -comment ""
}
