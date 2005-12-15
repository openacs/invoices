ad_library {
    Util procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::util {}

ad_proc -public iv::util::get_default_objects {
    -package_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Returns the cached array list of default objects to map category trees to.
} {
    return [util_memoize [list iv::util::get_default_objects_not_cached -package_id $package_id]]
}

ad_proc -private iv::util::get_default_objects_not_cached {
    -package_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Returns the array list of default objects to map category trees to.
} {
    db_1row default_object {} -column_array objects

    return [array get objects]
}

ad_proc -private iv::util::set_default_objects {
    -package_id:required
    -list_id:required
    -price_id:required
    -cost_id:required
    -offer_id:required
    -offer_item_id:required
    -offer_item_title_id:required
    -invoice_id:required
    -invoice_item_id:required
    -payment_id:required
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Inserts default objects to map category trees to.
} {
    db_dml set_default_objects {}
}

ad_proc -public iv::util::get_x_field {
    -offer_id:required
} {
    Creates the x-field for the email (for authentification)
} {
    db_1row get_offer_creator_data {}
    return [ns_sha1 "$offer_id $user_password $user_salt"]
}

ad_proc -public iv::util::valid_x_field_p {
    -offer_id:required
    -x_field:required
} {
    Verifies the x-field in the email
} {
    # generate the expected x-variable
    set expected_x [iv::util::get_x_field -offer_id $offer_id]
    
    # Check if both values are the same and return t or f
    return [string equal $x_field $expected_x]
}
