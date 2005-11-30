ad_library {
    Price procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::price {}

ad_proc -public iv::price::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-list_id ""}
    {-category_id ""}
    {-amount ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Price
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_price_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_price} -name $name -package_id $package_id -item_id $item_id]
	
	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_price} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list list_id $list_id] \
					 [list category_id $category_id] \
					 [list amount $amount] ] ]
    }

    return $new_id
}

ad_proc -public iv::price::edit {
    -price_item_id:required
    {-title ""}
    {-description ""}
    {-list_id ""}
    {-category_id ""}
    {-amount ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Price
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $price_item_id \
			    -content_type {iv_price} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list list_id $list_id] \
					     [list category_id $category_id] \
					     [list amount $amount] ] ]
    }

    return $new_rev_id
}
    
ad_proc -public iv::price::get {
    {-organization_id:required}
    {-object_id:required}
    {-package_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-07
    @return array of amount and currency if price found

    Get price for categories mapped to given object.
    Use customer price list if available.
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    if {(![empty_string_p $organization_id] && [db_0or1row check_customer_price {} -column_array price]) || [db_0or1row check_default_price {} -column_array price]} {
	return [array get price]
    }
}
