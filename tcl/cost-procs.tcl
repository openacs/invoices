ad_library {
    Cost procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::cost {}

ad_proc -public iv::cost::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-cost_nr ""}
    {-organization_id ""}
    {-cost_object_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-currency ""}
    {-apply_vat_p "t"}
    {-variable_cost_p "t"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Cost
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval t_acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_cost_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_cost} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_cost} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list cost_nr $cost_nr] \
					 [list organization_id $organization_id] \
					 [list cost_object_id $cost_object_id] \
					 [list item_units $item_units] \
					 [list price_per_unit $price_per_unit] \
					 [list currency $currency] \
					 [list apply_vat_p $apply_vat_p] \
					 [list variable_cost_p $variable_cost_p] ] ]
    }

    return $new_id
}

ad_proc -public iv::cost::edit {
    -cost_item_id:required
    {-title ""}
    {-description ""}
    {-cost_nr ""}
    {-organization_id ""}
    {-cost_object_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-currency ""}
    {-apply_vat_p "t"}
    {-variable_cost_p "t"}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Cost
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $cost_item_id \
			    -content_type {iv_cost} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list cost_nr $cost_nr] \
					     [list organization_id $organization_id] \
					     [list cost_object_id $cost_object_id] \
					     [list item_units $item_units] \
					     [list price_per_unit $price_per_unit] \
					     [list currency $currency] \
					     [list apply_vat_p $apply_vat_p] \
					     [list variable_cost_p $variable_cost_p] ] ]
    }

    return $new_rev_id
}
    
