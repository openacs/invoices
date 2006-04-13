set optional_param_list [list]
set optional_unset_list [list country_code]

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]]} {
            unset $optional_unset
        }
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}


set return_url [ad_return_url]
set postal_attribute_id [attribute::id -object_type "organization" -attribute_name "company_address"]

set start_date_sql ""
if { $start_date != "YYYY-MM-DD" } {
    # Get all customer invoices starting with start_date
    set start_date_sql "ao.creation_date > to_timestamp(:start_date, 'YYYY-MM-DD')"
}

set end_date_sql ""
if { $end_date != "YYYY-MM-DD" } {
    # Get all customer invoices up to and including end_date
    set end_date_sql "ao.creation_date < to_timestamp(:end_date, 'YYYY-MM-DD') + interval '1 day'"
}

set country_where_clause ""
set sql_query_name all_customer_orders
if { [exists_and_not_null country_code] } {
    set country_where_clause "p.country_code in ('[join $country_code "', '"]')"
    set sql_query_name all_customer_orders_of_country
}

set country_options [util::address::country_options]

template::list::create \
    -name reports \
    -multirow reports \
    -filters {
	year {}
	month {}
	day {}
    } -elements {
	customer_name {
	    label {[_ invoices.Customer]}
	    link_url_col customer_url
	    aggregate count
	    aggregate_label "[_ invoices.Total]:"
	}
	amount_total {
	    label "[_ invoices.Amount_total]"
	    aggregate sum
	    aggregate_label "[_ invoices.Total]:"
	}
	invoice_count {
	    label "[_ invoices.Invoice_count]"
	}
    } -orderby {
	default_value amount_total
        customer_name {
	    label {[_ invoices.Customer]}
	    orderby {lower(oo.name)}
	    default_direction asc
        }
        amount_total {
	    label "[_ invoices.Amount_total]"
	    orderby {amount_total}
	    default_direction desc
        }
        invoice_count {
	    label "[_ invoices.Invoice_count]"
	    orderby {invoice_count}
	    default_direction desc
        }
    } -filters {
	country_code {
	    label "[_ ams.country]"
	    type multival
	    values $country_options
	    where_clause $country_where_clause
	}
	start_date {
	    where_clause $start_date_sql
	}
	end_date {
	    where_clause $end_date_sql
	}
    }


set contacts_url [apm_package_url_from_key contacts]

db_multirow -extend {customer_url} reports $sql_query_name {} {
    set customer_url "${contacts_url}$customer_id"
}
