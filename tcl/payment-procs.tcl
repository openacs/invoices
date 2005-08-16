ad_library {
    Payment procs
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::payment {}

ad_proc -public iv::payment::new {
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-invoice_id ""}
    {-organization_id ""}
    {-received_date ""}
    {-amount ""}
    {-currency ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    New Payment
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    db_transaction {
	set item_id [db_nextval acs_object_id_seq]
	if {[empty_string_p $name]} {
	    set name "iv_payment_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {iv_payment} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {iv_payment} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list invoice_id $invoice_id] \
					 [list organization_id $organization_id] \
					 [list received_date $received_date] \
					 [list amount $amount] \
					 [list currency $currency] ] ]
    }

    return $new_id
}

ad_proc -public iv::payment::edit {
    -payment_item_id:required
    {-title ""}
    {-description ""}
    {-invoice_id ""}
    {-organization_id ""}
    {-received_date ""}
    {-amount ""}
    {-currency ""}
} {
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06

    Edit Payment
} {
    db_transaction {
	set new_rev_id [content::revision::new \
			    -item_id $payment_item_id \
			    -content_type {iv_payment} \
			    -title $title \
			    -description $description \
			    -attributes [list \
					     [list invoice_id $invoice_id] \
					     [list organization_id $organization_id] \
					     [list received_date $received_date] \
					     [list amount $amount] \
					     [list currency $currency] ] ]
    }

    return $new_rev_id
}
    
