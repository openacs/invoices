set optional_param_list [list]
set optional_unset_list [list]

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


set first_date "2006-02-01"
set customer_group_id [group::get_id -group_name "Customers"]
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
	creation_date {
	    label "[_ invoices.first_order_Creation_Date]"
	}
	amount_total {
	    label "[_ invoices.first_order_Amount_total]"
	    aggregate sum
	    aggregate_label "[_ invoices.Total]:"
	}
    } -orderby {
	default_value creation_date
        customer_name {
	    label {[_ invoices.Customer]}
	    orderby {lower(oo.name)}
	    default_direction asc
        }
        creation_date {
	    label "[_ invoices.first_order_Creation_Date]"
	    orderby {ao.creation_date}
	    default_direction desc
        }
        amount_total {
	    label "[_ invoices.first_order_Amount_total]"
	    orderby {o.amount_total}
	    default_direction desc
        }
    } -filters {
	start_date {
	    where_clause $start_date_sql
	}
	end_date {
	    where_clause $end_date_sql
	}
    }


set contacts_url [apm_package_url_from_key contacts]

db_multirow -extend {customer_url} reports new_customer_with_orders {} {
    set customer_url "${contacts_url}$customer_id"
}
