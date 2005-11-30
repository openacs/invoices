ad_page_contract {
    Accepts offer by customer
} {
    offer_id:integer,notnull
    x:notnull
}

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

set package_id [ad_conn package_id]

if {$valid_x_p} {
    db_transaction {
	iv::offer::accept -offer_id $offer_id
	callback iv::offer_accept -offer_id $offer_id
	callback iv::offer_accepted -offer_id $offer_id
    }
} else {
    ns_log notice "Invalid secret key when accepting offer $offer_id"
}

ad_return_template
