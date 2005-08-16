ad_library {
    Offer Item procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-19
}

namespace eval iv::offer_item {}

ad_proc -public iv::offer_item::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-comment ""}
    {-item_nr ""}
    {-offer_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-rebate ""}
    {-file_count ""}
    {-page_count ""}
    {-sort_order ""}
    {-vat ""}
    {-parent_item_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-19

    New Offer Item
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_offer_item_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_offer_item} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_offer_item} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list comment $comment] \
					 [list item_nr $item_nr] \
					 [list offer_id $offer_id] \
					 [list item_units $item_units] \
					 [list price_per_unit $price_per_unit] \
					 [list rebate $rebate] \
					 [list file_count $file_count] \
					 [list page_count $page_count] \
					 [list sort_order $sort_order] \
					 [list vat $vat] \
					 [list parent_item_id $parent_item_id] ] ]
    }

    return $new_id
}

ad_proc -public iv::offer_item::edit {
    -offer_item_id:required
    {-title ""}
    {-description ""}
    {-comment ""}
    {-item_nr ""}
    {-offer_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-rebate ""}
    {-file_count ""}
    {-page_count ""}
    {-sort_order ""}
    {-vat ""}
    {-parent_item_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-19

    Edit Offer Item
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $offer_item_id \
			    -content_type {iv_offer_item} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list comment $comment] \
					     [list item_nr $item_nr] \
					     [list offer_id $offer_id] \
					     [list item_units $item_units] \
					     [list price_per_unit $price_per_unit] \
					     [list rebate $rebate] \
					     [list file_count $file_count] \
					     [list page_count $page_count] \
					     [list sort_order $sort_order] \
					     [list vat $vat] \
					     [list parent_item_id $parent_item_id] ] ]
    }

    return $new_rev_id
}
