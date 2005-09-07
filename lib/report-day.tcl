if {![info exists format]} {
    set format "normal"
}

if {![info exists orderby]} {
    set orderby ""
}

if {![info exists page_size]} {
    set page_size 25
}

if {![info exists package_id]} {
    set package_id [ad_conn package_id]
}

if {![info exists base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

foreach optional_param {organization_id row_list} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach unset_param {new_clients_p account_manager_p} {
    if {[info exists $unset_param]} {
	if {[empty_string_p [set $unset_param]]} {
	    unset $unset_param
	}
    }
}

set actions [list "[_ invoices.back_to_year]" \
		 [export_vars -base invoice-reports {organization_id year new_clients_p account_manager_p}]]

# Filter to show only resulst for clients in less than 1 year
set new_clients_where_clause "o.creation_date > now() - '1 year' :: interval"

if { [string equal $month "08"] || [string equal $month "09"]  } {
    set short_month [template::util::date::monthName [string range $month 1 1] short]
    set long_month [template::util::date::monthName [string range $month 1 1] long]
} else {
    set short_month [template::util::date::monthName $month short]
    set long_month [template::util::date::monthName $month long]
}


template::list::create \
    -name iv_days \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	iv_day {
	    label "[_ invoices.day]:"
	}
	invoice_nr {
            label {[_ invoices.iv_invoice_invoice_nr]}
        }
        title {
            label {[_ invoices.iv_invoice_1]}
            link_url_eval {[export_vars -base "invoice-ae" { {invoice_id $item_id} {mode display}}]}
        }
        description {
            label {[_ invoices.iv_invoice_Description]}
        }
	iv_total_amount {
	    label {[_ invoices.Amount_total] } 
	}
    } \
    -actions $actions \
    -sub_class narrow \
    -orderby {
	default_value invoice_nr
	invoice_nr {
	    label {[_ invoices.iv_invoice_invoice_nr]}
	    orderby {i.item_id}
	    default_direction asc
	}
	title {
	    label {[_ invoices.iv_invoice_1]}
	    orderby_desc {lower(r.title) desc}
	    orderby_asc {lower(r.title) asc}
	    default_direction asc
	}
	description {
	    label {[_ invoices.iv_invoice_Description]}
	    orderby_desc {lower(r.description) desc}
	    orderby_asc {lower(r.description) asc}
	    default_direction asc
	}
	iv_total_amount {
	    label {[_ invoices.iv_invoice_total_amount]}
	    orderby_desc {iv.total_amount desc}
	    orderby_asc {iv.total_amount asc}
	    default_direction desc
	}
    } \
    -filters {
	organization_id {
	}
	year {
	}
	month {
	}
	new_clients_p {
	    label "[_ invoices.New_clients]"
	    values {{"[_ invoices.New]" 1}}
	    where_clause { $new_clients_where_clause}
	}
	account_manager_p {
	    label "[_ invoices.Client_Account_Man]"
	    values { {Filter 1} } 
	    where_clause { iv.recipient_id = iv.recipient_id }
	}
    } \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
	csv {
	    label "[_ invoices.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }

db_multirow -extend { iv_total_amount } iv_days iv_invoice_days " " {
    set iv_total_amount [db_string get_iv_total_amount { }]
}

set iv_count [db_string get_iv_count { }]