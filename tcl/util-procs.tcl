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
