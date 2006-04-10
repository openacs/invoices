set optional_param_list [list]
set optional_unset_list [list category_f]

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


# Procedure that manages the date filter
set date_filter [iv::invoice::year_month_day_filter \
		     -base $base_url \
		     -year $year \
		     -month $month \
		     -day $day \
		     -last_years $last_years \
		     -extra_vars ""]

set return_url [ad_return_url]
set extra_query ""

if { [exists_and_not_null year] } {
    # We get the projects for this year
    append extra_query " and to_char(ao.creation_date, 'YYYY') = :year"
}

if { [exists_and_not_null month] } {
    # We get the projects for this specific month
    append extra_query " and to_char(ao.creation_date, 'MM') = :month"
}

if { [exists_and_not_null day] } {
    # We get the projects for this specific day
    append extra_query " and to_char(ao.creation_date, 'DD') = :day"
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
    }


set contacts_url [apm_package_url_from_key contacts]

db_multirow -extend {customer_url} reports new_customer_with_orders {} {
    set customer_url "${contacts_url}$customer_id"
}
