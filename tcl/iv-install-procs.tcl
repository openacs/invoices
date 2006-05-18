ad_library {
    Invoices Package install callbacks
    
    Procedures that deal with installing.
    
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
}

namespace eval iv::install {}

ad_proc -public iv::install::create_install {
} {
    Creates the content types and adds the attributes.
} {
    content::type::new -content_type {iv_price_list} -supertype {content_revision} -pretty_name {[_ invoices.Price_List]} -pretty_plural {[_ invoices.Price_Lists]} -table_name {iv_price_lists} -id_column {list_id}
    content::type::new -content_type {iv_price} -supertype {content_revision} -pretty_name {[_ invoices.Price]} -pretty_plural {[_ invoices.Prices]} -table_name {iv_prices} -id_column {price_id}
    content::type::new -content_type {iv_cost} -supertype {content_revision} -pretty_name {[_ invoices.Cost]} -pretty_plural {[_ invoices.Costs]} -table_name {iv_costs} -id_column {cost_id}
    content::type::new -content_type {iv_offer} -supertype {content_revision} -pretty_name {[_ invoices.Offer]} -pretty_plural {[_ invoices.Offers]} -table_name {iv_offers} -id_column {offer_id}
    content::type::new -content_type {iv_offer_item} -supertype {content_revision} -pretty_name {[_ invoices.Offer_Item]} -pretty_plural {[_ invoices.Offer_Items]} -table_name {iv_offer_items} -id_column {offer_item_id}
    content::type::new -content_type {iv_invoice} -supertype {content_revision} -pretty_name {[_ invoices.Invoice]} -pretty_plural {[_ invoices.Invoices]} -table_name {iv_invoices} -id_column {invoice_id}
    content::type::new -content_type {iv_invoice_item} -supertype {content_revision} -pretty_name {[_ invoices.Invoice_Item]} -pretty_plural {[_ invoices.Invoice_Items]} -table_name {iv_invoice_items} -id_column {iv_item_id}
    content::type::new -content_type {iv_payment} -supertype {content_revision} -pretty_name {[_ invoices.Payment]} -pretty_plural {[_ invoices.Payments]} -table_name {iv_payments} -id_column {payment_id}

    # Price List
    content::type::attribute::new -content_type {iv_price_list} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
    content::type::attribute::new -content_type {iv_price_list} -attribute_name {credit_percent} -datatype {number} -pretty_name {[_ invoices.Credit]} -column_spec {numeric(12,5)}

    # Price
    content::type::attribute::new -content_type {iv_price} -attribute_name {list_id} -datatype {number} -pretty_name {[_ invoices.Price_list]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_price} -attribute_name {category_id} -datatype {number} -pretty_name {[_ invoices.Price_category]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_price} -attribute_name {amount} -datatype {number} -pretty_name {[_ invoices.Amount]} -column_spec {numeric(12,3)}

    # Cost
    content::type::attribute::new -content_type {iv_cost} -attribute_name {cost_nr} -datatype {string} -pretty_name {[_ invoices.Cost_number]} -column_spec {varchar(400)}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {organization_id} -datatype {number} -pretty_name {[_ invoices.Customer]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {cost_object_id} -datatype {number} -pretty_name {[_ invoices.Cost_cause]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {item_units} -datatype {number} -pretty_name {[_ invoices.Number_of_units]} -column_spec {numeric(12,1)}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {price_per_unit} -datatype {number} -pretty_name {[_ invoices.Price_per_unit]} -column_spec {numeric(12,3)}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {apply_vat_p} -datatype {boolean} -pretty_name {[_ invoices.Apply_VAT]} -column_spec {char(1)}
    content::type::attribute::new -content_type {iv_cost} -attribute_name {variable_cost_p} -datatype {boolean} -pretty_name {[_ invoices.Fixed_cost]} -column_spec {char(1)}

    # Offer
    content::type::attribute::new -content_type {iv_offer} -attribute_name {offer_nr} -datatype {string} -pretty_name {[_ invoices.Offer_number]} -column_spec {varchar(80)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {organization_id} -datatype {number} -pretty_name {[_ invoices.Customer]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {comment} -datatype {text} -pretty_name {[_ invoices.Comment]} -column_spec {text}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {reservation} -datatype {text} -pretty_name {[_ invoices.Reservation]} -column_spec {text}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {amount_total} -datatype {number} -pretty_name {[_ invoices.Amount_total]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {amount_sum} -datatype {number} -pretty_name {[_ invoices.Amount_sum]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {finish_date} -datatype {date} -pretty_name {[_ invoices.Finish_date]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {date_comment} -datatype {string} -pretty_name {[_ invoices.Date_comment]} -column_spec {varchar(1000)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {payment_days} -datatype {number} -pretty_name {[_ invoices.Payment_after__days]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {vat_percent} -datatype {number} -pretty_name {[_ invoices.VAT]} -column_spec {numeric(12,5)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {credit_percent} -datatype {number} -pretty_name {[_ invoices.Credit]} -column_spec {numeric(12,5)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {status} -datatype {string} -pretty_name {[_ invoices.Status]} -column_spec {varchar(10)}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {accepted_date} -datatype {date} -pretty_name {[_ invoices.Accepted_date]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {iv_offer} -attribute_name {show_sum_p} -datatype {boolean} -pretty_name {[_ invoices.Show_Sum]} -column_spec {char(1)}

    # Offer Item
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {item_nr} -datatype {string} -pretty_name {[_ invoices.Offer_item_number]} -column_spec {varchar(200)}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {offer_id} -datatype {number} -pretty_name {[_ invoices.Offer]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {comment} -datatype {text} -pretty_name {[_ invoices.Comment]} -column_spec {text}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {item_units} -datatype {number} -pretty_name {[_ invoices.Number_of_units]} -column_spec {numeric(12,1)}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {price_per_unit} -datatype {number} -pretty_name {[_ invoices.Price_per_unit]} -column_spec {numeric(12,3)}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {rebate} -datatype {number} -pretty_name {[_ invoices.Rebate]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {file_count} -datatype {number} -pretty_name {[_ invoices.File_count]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {page_count} -datatype {number} -pretty_name {[_ invoices.Page_count]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {sort_order} -datatype {number} -pretty_name {[_ invoices.Sort_order]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,3)}
    content::type::attribute::new -content_type {iv_offer_item} -attribute_name {parent_item_id} -datatype {number} -pretty_name {[_ invoices.Parent_offer_item]} -column_spec {integer}

    # Invoice
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {invoice_nr} -datatype {string} -pretty_name {[_ invoices.Invoice_number]} -column_spec {varchar(80)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {parent_invoice_id} -datatype {number} -pretty_name {[_ invoices.Invoice_reference]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {organization_id} -datatype {number} -pretty_name {[_ invoices.Customer]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {contact_id} -datatype {number} -pretty_name {[_ invoices.Contact]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {recipient_id} -datatype {number} -pretty_name {[_ invoices.Recipient]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {total_amount} -datatype {number} -pretty_name {[_ invoices.Total_amount]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {amount_sum} -datatype {number} -pretty_name {[_ invoices.Amount_sum]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {paid_amount} -datatype {number} -pretty_name {[_ invoices.Amount_paid]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {paid_currency} -datatype {string} -pretty_name {[_ invoices.Currency_paid]} -column_spec {char(3)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {due_date} -datatype {date} -pretty_name {[_ invoices.Due_date]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {payment_days} -datatype {number} -pretty_name {[_ invoices.Payment_after__days]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {vat_percent} -datatype {number} -pretty_name {[_ invoices.VAT]} -column_spec {numeric(12,5)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {status} -datatype {string} -pretty_name {[_ invoices.Status]} -column_spec {varchar(10)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {cancelled_p} -datatype {boolean} -pretty_name {[_ invoices.Cancelled]} -column_spec {char(1)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {pdf_status} -datatype {string} -pretty_name {[_ invoices.PDF_Status]} -column_spec {varchar(10)}
    content::type::attribute::new -content_type {iv_invoice} -attribute_name {pdf_file_id} -datatype {number} -pretty_name {[_ invoices.PDF_File]} -column_spec {integer}

    # Invoice Item
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {item_nr} -datatype {string} -pretty_name {[_ invoices.Invoice_item_number]} -column_spec {varchar(200)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {invoice_id} -datatype {number} -pretty_name {[_ invoices.Invoice]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {offer_item_id} -datatype {number} -pretty_name {[_ invoices.Offer_item]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {item_units} -datatype {number} -pretty_name {[_ invoices.Number_of_units]} -column_spec {numeric(12,1)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {price_per_unit} -datatype {number} -pretty_name {[_ invoices.Price_per_unit]} -column_spec {numeric(12,3)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {rebate} -datatype {number} -pretty_name {[_ invoices.Rebate]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {amount_total} -datatype {number} -pretty_name {[_ invoices.Amount_total]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {sort_order} -datatype {number} -pretty_name {[_ invoices.Sort_order]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,3)}
    content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {parent_item_id} -datatype {number} -pretty_name {[_ invoices.Parent_invoice_item]} -column_spec {integer}

    # Payment
    content::type::attribute::new -content_type {iv_payment} -attribute_name {invoice_id} -datatype {number} -pretty_name {[_ invoices.Invoice]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_payment} -attribute_name {organization_id} -datatype {number} -pretty_name {[_ invoices.Customer]} -column_spec {integer}
    content::type::attribute::new -content_type {iv_payment} -attribute_name {received_date} -datatype {date} -pretty_name {[_ invoices.Received_on]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {iv_payment} -attribute_name {amount} -datatype {number} -pretty_name {[_ invoices.Amount]} -column_spec {numeric(12,2)}
    content::type::attribute::new -content_type {iv_payment} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
}

ad_proc -public iv::install::package_instantiate {
    -package_id:required
} {
    Define folders
} {
    # create a content folder
    set folder_id [content::folder::new -name "invoices_$package_id" -package_id $package_id]
    # register the allowed content types for a folder
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_price_list} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_price} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_cost} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_offer} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_offer_item} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_invoice} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_invoice_item} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {iv_payment} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {content_revision} -include_subtypes f

    set list_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Price Lists Default Object"]] acs_object]
    set price_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Prices Default Object"]] acs_object]
    set cost_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Costs Default Object"]] acs_object]
    set offer_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offers Default Object"]] acs_object]
    set offer_item_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offer Items Default Object"]] acs_object]
    set offer_item_title_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offer Items Title Default Object"]] acs_object]
    set invoice_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Invoices Default Object"]] acs_object]
    set invoice_item_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Invoice Items Default Object"]] acs_object]
    set payment_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Payments Default Object"]] acs_object]

    iv::util::set_default_objects \
	-package_id $package_id \
	-list_id $list_id \
	-price_id $price_id \
	-cost_id $cost_id \
	-offer_id $offer_id \
	-offer_item_id $offer_item_id \
	-offer_item_title_id $offer_item_title_id \
	-invoice_id $invoice_id \
	-invoice_item_id $invoice_item_id \
	-payment_id $payment_id
}

ad_proc -public iv::install::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
	    0.01d1 0.01d2 {
		content::type::new -content_type {iv_offer} -supertype {content_revision} -pretty_name {[_ invoices.Offer]} -pretty_plural {[_ invoices.Offers]} -table_name {iv_offers} -id_column {offer_id}
		content::type::new -content_type {iv_offer_item} -supertype {content_revision} -pretty_name {[_ invoices.Offer_Item]} -pretty_plural {[_ invoices.Offer_Items]} -table_name {iv_offer_items} -id_column {offer_item_id}

		# Offer
		content::type::attribute::new -content_type {iv_offer} -attribute_name {offer_nr} -datatype {string} -pretty_name {[_ invoices.Offer_number]} -column_spec {varchar(80)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {organization_id} -datatype {number} -pretty_name {[_ invoices.Customer]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {amount_total} -datatype {number} -pretty_name {[_ invoices.Amount_total]} -column_spec {numeric(12,2)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {amount_sum} -datatype {number} -pretty_name {[_ invoices.Amount_sum]} -column_spec {numeric(12,2)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {currency} -datatype {string} -pretty_name {[_ invoices.Currency]} -column_spec {char(3)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {finish_date} -datatype {date} -pretty_name {[_ invoices.Finish_date]} -column_spec {timestamptz}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {payment_days} -datatype {number} -pretty_name {[_ invoices.Payment_after__days]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {vat_percent} -datatype {number} -pretty_name {[_ invoices.VAT]} -column_spec {numeric(12,5)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,2)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {accepted_p} -datatype {boolean} -pretty_name {[_ invoices.Accepted]} -column_spec {char(1)}

		# Offer Item
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {item_nr} -datatype {string} -pretty_name {[_ invoices.Offer_item_number]} -column_spec {varchar(200)}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {offer_id} -datatype {number} -pretty_name {[_ invoices.Offer]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {item_units} -datatype {number} -pretty_name {[_ invoices.Number_of_units]} -column_spec {numeric(12,1)}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {price_per_unit} -datatype {number} -pretty_name {[_ invoices.Price_per_unit]} -column_spec {numeric(12,3)}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {sort_order} -datatype {number} -pretty_name {[_ invoices.Sort_order]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {vat} -datatype {number} -pretty_name {[_ invoices.VAT_amount]} -column_spec {numeric(12,3)}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {parent_item_id} -datatype {number} -pretty_name {[_ invoices.Parent_offer_item]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {rebate} -datatype {number} -pretty_name {[_ invoices.Rebate]} -column_spec {numeric(12,2)}

		# Invoice Item
		content::type::attribute::delete -content_type {iv_invoice_item} -attribute_name {cost_id} -drop_column t
		content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {offer_item_id} -datatype {number} -pretty_name {[_ invoices.Offer_item]} -column_spec {integer}

		foreach package_id [apm_package_id_from_key invoices] {
		    set folder_id [content::folder::get_folder_from_package -package_id $package_id]
		    content::folder::register_content_type -folder_id $folder_id -content_type {iv_offer} -include_subtypes t
		    content::folder::register_content_type -folder_id $folder_id -content_type {iv_offer_item} -include_subtypes t

		    set offer_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offers Default Object"]] acs_object]
		    set offer_item_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offer Items Default Object"]] acs_object]

		    db_dml update_default_objects {}
		}
	    }
	    0.01d2 0.01d3 {
		content::type::attribute::delete -content_type {iv_offer} -attribute_name {accepted_p} -drop_column t
		content::type::attribute::new -content_type {iv_offer} -attribute_name {accepted_date} -datatype {date} -pretty_name {[_ invoices.Accepted_date]} -column_spec {timestamptz}
	    }
	    0.01d3 0.01d4 {
		content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {rebate} -datatype {number} -pretty_name {[_ invoices.Rebate]} -column_spec {numeric(12,2)}
		content::type::attribute::new -content_type {iv_invoice_item} -attribute_name {amount_total} -datatype {number} -pretty_name {[_ invoices.Amount_total]} -column_spec {numeric(12,2)}
	    }
	    0.01d4 0.01d5 {
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {file_count} -datatype {number} -pretty_name {[_ invoices.File_count]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {page_count} -datatype {number} -pretty_name {[_ invoices.Page_count]} -column_spec {integer}
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {cancelled_p} -datatype {boolean} -pretty_name {[_ invoices.Cancelled]} -column_spec {char(1)}
	    }
	    0.01d5 0.01d6 {
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {amount_sum} -datatype {number} -pretty_name {[_ invoices.Amount_sum]} -column_spec {numeric(12,2)}
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {recipient_id} -datatype {number} -pretty_name {[_ invoices.Recipient]} -column_spec {integer}
	    }
	    0.01d6 0.01d7 {
		content::type::attribute::new -content_type {iv_offer} -attribute_name {comment} -datatype {text} -pretty_name {[_ invoices.Comment]} -column_spec {text}
		content::type::attribute::new -content_type {iv_offer_item} -attribute_name {comment} -datatype {text} -pretty_name {[_ invoices.Comment]} -column_spec {text}
	    }
	    0.01d7 0.01d8 {
		content::type::attribute::new -content_type {iv_offer} -attribute_name {date_comment} -datatype {string} -pretty_name {[_ invoices.Date_comment]} -column_spec {varchar(1000)}
	    }
	    0.01d8 0.01d9 {
		apm_parameter_register "MailSendBoxFileP" "Location of the file for prefilling the mail send box." "invoices" "" "string"
	    }
	    0.01d10 0.01d11 {
		content::type::attribute::new -content_type {iv_price_list} -attribute_name {credit_percent} -datatype {number} -pretty_name {[_ invoices.Credit]} -column_spec {numeric(12,5)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {credit_percent} -datatype {number} -pretty_name {[_ invoices.Credit]} -column_spec {numeric(12,5)}
		content::type::attribute::new -content_type {iv_offer} -attribute_name {status} -datatype {string} -pretty_name {[_ invoices.Status]} -column_spec {varchar(10)}
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {status} -datatype {string} -pretty_name {[_ invoices.Status]} -column_spec {varchar(10)}
	    }
	    0.01d14 0.01d15 {
		db_transaction {
		    set organization_ids [db_list all_organizations {
			select m.member_id
			from groups g, organizations o, group_member_map m
			where g.group_name = 'Customers'
			and g.group_id = m.group_id
			and o.organization_id = m.member_id
		    }]

		    set package_ids [apm_package_id_from_key invoices]
		    foreach organization_id $organization_ids {
			foreach package_id $package_ids {
			    iv::offer::new_credit -organization_id $organization_id -package_id $package_id
			    iv::offer::pdf_folders -organization_id $organization_id -package_id $package_id
			}
		    }
		}
	    }
	    0.01d19 0.01d20 {
		foreach package_id [apm_package_id_from_key invoices] {
		    set offer_item_title_id [package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "Offer Items Title Default Object"]] acs_object]

		    db_dml set_offer_item_title_id {
			update iv_default_objects
			set offer_item_title_id = :offer_item_title_id
			where package_id = :package_id
		    }
		}
	    }
	    0.01d21 0.01d22 {
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {contact_id} -datatype {number} -pretty_name {[_ invoices.Contact]} -column_spec {integer}
	    }
	    1.0d2 1.0d3 {
		content::type::attribute::new -content_type {iv_offer} -attribute_name {reservation} -datatype {text} -pretty_name {[_ invoices.Reservation]} -column_spec {text}
	    }
	    1.0d6 1.0d7 {
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {pdf_status} -datatype {string} -pretty_name {[_ invoices.PDF_Status]} -column_spec {varchar(10)}
		content::type::attribute::new -content_type {iv_invoice} -attribute_name {pdf_file_id} -datatype {number} -pretty_name {[_ invoices.PDF_File]} -column_spec {integer}
	    }
	    1.0d7 1.0d8 {
		content::type::attribute::new -content_type {iv_offer} -attribute_name {show_sum_p} -datatype {boolean} -pretty_name {[_ invoices.Show_Sum]} -column_spec {char(1)}
	    }
	}
}

ad_proc -public -callback pm::task_close -impl invoices {
    {-package_id:required}
    {-task_id:required}
} {
    Create new cost every time a project task is closed
} {
    set task_rev_id [pm::task::get_revision_id -task_item_id $task_id]
    set project_rev_id [pm::project::get_project_id -project_item_id [pm::task::project_item_id -task_item_id $task_id]]

    db_1row task_data {
	select r.title as task_title, r.description as task_description,
	       t.actual_hours_worked as amount, p.customer_id
	from cr_revisions r, pm_tasks_revisions t, pm_projects p
	where r.revision_id = :task_rev_id
	and t.task_revision_id = r.revision_id
	and p.project_id = :project_rev_id
    }

    foreach iv_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "invoices"] {

	array set price [iv::price::get -organization_id $customer_id -object_id $task_rev_id -package_id $iv_package_id]

	if {![info exists price(currency)]} {
	    # no price entry found
	    set price(amount) 1
	    set price(currency) [parameter::get -parameter "DefaultCurrency" -default "EUR" -package_id $iv_package_id]
	}

	if {![empty_string_p $amount]} {

	    db_1row check_cost_exists {
		select max(cr.item_id) as cost_id
		from iv_costs c, cr_revisions cr, cr_revisions tr,
		acs_objects o
		where tr.item_id = :task_id
		and tr.revision_id = c.cost_object_id
		and c.cost_id = cr.revision_id
		and o.object_id = c.cost_id
		and o.package_id = :iv_package_id
	    }

	    if {[empty_string_p $cost_id]} {
		# no cost entry found for this task
		set new_cost_id [iv::cost::new  \
				     -package_id $iv_package_id \
				     -title $task_title \
				     -description $task_description  \
				     -cost_nr $task_id \
				     -organization_id $customer_id \
				     -cost_object_id $task_rev_id \
				     -item_units $amount \
				     -price_per_unit $price(amount) \
				     -currency $price(currency) ]
	    } else {
		# create new revision of existing cost entry
		set new_cost_id [iv::cost::edit \
				     -cost_item_id $cost_id \
				     -title $task_title \
				     -description $task_description  \
				     -cost_nr $task_id \
				     -organization_id $customer_id \
				     -cost_object_id $task_rev_id \
				     -item_units $amount \
				     -price_per_unit $price(amount) \
				     -currency $price(currency) ]
	    }
	}

	array unset price
    }
}

