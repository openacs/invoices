ad_page_contract {
    Page to automatically create an offer from a given project.

    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    @creation-date 2005-06-06
} {
    organization_id:integer
    project_item_id:integer
    {return_url ""}
} 

# Figure out if an offer already exists

set offer_id [db_string select_offer_id "select o.offer_id from acs_data_links r, iv_offers o, cr_items i
where r.object_id_one = :project_item_id
and r.object_id_two = i.item_id
and o.offer_id = i.latest_revision
order by i.item_id
limit 1" -default ""]

if {$offer_id eq ""} {

    # Create new offer

    set package_id [ad_conn package_id]

    # First get the basic organization date
    set list_id [iv::price_list::get_list_id -organization_id $organization_id]
    if {[empty_string_p $list_id]} {
	set currency [parameter::get -parameter "DefaultCurrency" -default "EUR" -package_id $package_id]
	set credit_percent 0
    } else {
	db_1row get_currency_and_credit_percent {}
    }
    
    set payment_days "0"
    set vat_percent "0.0"
    set contacts_package_id [lindex [application_link::get_linked -from_package_id $package_id -to_package_key contacts] 0]
    array set org_data [contacts::get_values \
			    -group_name "Customers" \
			    -object_type "organization" \
			    -party_id $organization_id \
			    -contacts_package_id $contacts_package_id]
    if {[info exists org_data(payment_days)]} {
	set payment_days $org_data(payment_days)
    }
    if {[info exists org_data(vat_percent)]} {
	set vat_percent [format "%.1f" $org_data(vat_percent)]
    }
    
    # Get the information from the project
    
    db_1row get_project {}
    
    # The PA name should be the same as the project
    set title "PA $project_name"
    set offer_nr $project_name
    regexp {^([0-9\-]+)} $offer_nr match offer_nr

    # Create the new offer
    set new_offer_rev_id [iv::offer::new  \
			      -title $title \
			      -offer_nr $offer_nr \
			      -comment $comment  \
			      -organization_id $organization_id \
			      -amount_total 0 \
			      -amount_sum 0 \
			      -currency $currency \
			      -payment_days $payment_days \
			      -vat_percent $vat_percent \
			      -vat 0 \
			      -credit_percent $credit_percent]
    
    set offer_id [content::revision::item_id -revision_id $new_offer_rev_id]
    
    application_data_link::new -this_object_id $offer_id -target_object_id $project_item_id
    
    
    
    # now it is time to create the offer-items.
    # This is basically a copy of the project_new callback and should be kept in sync.
    # Byte the way: Everything below this line is most likely custom code
    
    callback iv::offer_create_items -offer_id $new_offer_rev_id -project_item_id $project_item_id -organization_id $organization_id
}

if {$return_url eq ""} {
    set invoice_base_url [site_node::get_package_url -package_key invoices]
    set return_url [export_vars -base "${invoice_base_url}offer-ae" -url {{mode display} offer_id}]
    set return_url [export_vars -base "${invoice_base_url}offer-ae" -url {{mode display} offer_id return_url}]
}

ad_returnredirect $return_url