ad_library {
    Invoice Item procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::invoice_item {}

ad_proc -public iv::invoice_item::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-item_nr ""}
    {-invoice_id ""}
    {-offer_item_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-rebate ""}
    {-amount_total ""}
    {-sort_order ""}
    {-vat ""}
    {-parent_item_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Invoice Item
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_invoice_item_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_invoice_item} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_invoice_item} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list item_nr $item_nr] \
					 [list invoice_id $invoice_id] \
					 [list offer_item_id $offer_item_id] \
					 [list item_units $item_units] \
					 [list price_per_unit $price_per_unit] \
					 [list rebate $rebate] \
					 [list amount_total $amount_total] \
					 [list sort_order $sort_order] \
					 [list vat $vat] \
					 [list parent_item_id $parent_item_id] ] ]
    }

    return $new_id
}

ad_proc -public iv::invoice_item::edit {
    -iv_item_item_id:required
    {-title ""}
    {-description ""}
    {-item_nr ""}
    {-invoice_id ""}
    {-offer_item_id ""}
    {-item_units ""}
    {-price_per_unit ""}
    {-rebate ""}
    {-amount_total ""}
    {-sort_order ""}
    {-vat ""}
    {-parent_item_id ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Invoice Item
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $iv_item_item_id \
			    -content_type {iv_invoice_item} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list item_nr $item_nr] \
					     [list invoice_id $invoice_id] \
					     [list offer_item_id $offer_item_id] \
					     [list item_units $item_units] \
					     [list price_per_unit $price_per_unit] \
					     [list rebate $rebate] \
					     [list amount_total $amount_total] \
					     [list sort_order $sort_order] \
					     [list vat $vat] \
					     [list parent_item_id $parent_item_id] ] ]
    }

    return $new_rev_id
}
