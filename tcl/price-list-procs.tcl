ad_library {
    Price List procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::price_list {}

ad_proc -public iv::price_list::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-currency ""}
    {-credit_percent "0"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Price List
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval t_acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_price_list_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_price_list} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_price_list} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list currency $currency] \
					 [list credit_percent $credit_percent] ] ]
    }

    return $new_id
}

ad_proc -public iv::price_list::edit {
    -list_item_id:required
    {-title ""}
    {-description ""}
    {-currency ""}
    {-credit_percent "0"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Price List
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $list_item_id \
			    -content_type {iv_price_list} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list currency $currency] \
					     [list credit_percent $credit_percent] ] ]
    }

    return $new_rev_id
}
    
ad_proc -public iv::price_list::get_currency {
    -organization_id:required
    {-package_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-09

    Get currency of customer
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    if {[db_0or1row check_customer_price_list {}] || [db_0or1row check_default_price_list {}]} {
	return $currency
    } else {
	return [parameter::get -parameter "DefaultCurrency" -default "EUR" -package_id $package_id]
    }
}

# modified 2006/08/04 by cognovis/nfl: new logic related to the default price list id
ad_proc -public iv::price_list::get_list_id {
    -organization_id:required
    {-package_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @author Nils Lohse (nils.lohse@cognovis.de) 
    @creation-date 2005-07-01

    Get id of customer price list (or default)
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    # --- 1) look, if there is a customer price list
    if {[db_0or1row check_customer_price_list {}]} {
        return $list_id
    } else {      
        # --- 2) deliver default price list
	set dpl_id [iv::price_list::get_default_list_id -package_id $package_id]
        return $dpl_id
    }

# old code - used until 2006/08/04:
#    if {[db_0or1row check_customer_price_list {}] || [db_0or1row check_default_price_list {}]} {
#	return $list_id
#    } else {
#	return ""
#    }
}

# created 2006/08/04 by cognovis/nfl
ad_proc -public iv::price_list::get_default_list_id {
    {-package_id ""}
} {
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-04

    Get id of default price list 
} {
    if {[empty_string_p $package_id]} {
        set package_id [ad_conn package_id]
    }

    # --- 1) try to get the parameter DefaultPriceListID out of the .info file
    set dpl_id [parameter::get -package_id $package_id -parameter DefaultPriceListID]
    if {$dpl_id != ""} {
	return $dpl_id
    } else {
        # --- 2) get lowest (= oldest) item_id of the pricelists
	if {[db_0or1row get_oldest_price_list {}]} {
	    parameter::set_value -package_id $package_id -parameter DefaultPriceListID -value $list_id
            return $list_id
	} else {
            return ""
	}
    }        
}


ad_proc -public iv::price_list::get_price {
    -organization_id:required
    -category_id:required
    {-package_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-07-01

    Get id of customer price for a certain category
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }

    set list_id [iv::price_list::get_list_id -organization_id $organization_id -package_id $package_id]
    if {$list_id eq ""} {
	return ""
    } else {
	return [db_string get_price "select amount from iv_prices p, cr_items i where i.latest_revision = p.price_id and p.list_id = :list_id and category_id = :category_id" -default ""]
    } 
}

# created 2006/08/04 by cognovis/nfl
ad_proc -public iv::price_list::get_name_of_list {
    -item_id:required
} {
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-04

    Get name of given price list
} {
    set pricelist_name [content::item::get_title -item_id $item_id]
    return $pricelist_name
}