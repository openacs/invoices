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

set extra_query ""
if { [empty_string_p $organization_id] } {
    set exrta_query "and iv.organization_id = $organization_id"
}

set actions [list "[_ invoices.back_to_years]" \
		 [export_vars -base invoice-reports {organization_id new_clients_p account_manager_p}]]

set extra_url ""
# Filter to show only resulst for clients in less than 1 year
if {[exists_and_not_null new_clients_p] } {
    append extra_url "&new_clients_p=$new_clients_p"
}
set new_clients_where_clause "o.creation_date > now() - '1 year' :: interval"

# Account Manager Filter
if {[exists_and_not_null account_manager_p] } {
    append extra_url "&account_manager_p=$account_manager_p"
}

template::list::create \
    -name iv_months \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	iv_month {
	    label "[_ invoices.month]:"
	    display_template {
		<a href="?year=$year&month=@iv_months.iv_month@&organization_id=$organization_id$extra_url">@iv_months.short_month@</a>
	    }
	}
	iv_count {
            label {[_ invoices.count]}
        }
	iv_total_amount {
	    label {[_ invoices.Amount_total] } 
	}
    } \
    -actions $actions \
    -sub_class narrow \
    -filters {
	organization_id {
	}
	year {
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

db_multirow -extend { short_month iv_total_amount iv_count } iv_months iv_invoice_months " " {
    if { [string equal $iv_month "08"] || [string equal $iv_month "09"]  } {
	set short_month [template::util::date::monthName [string range $iv_month 1 1] short]
    } else {
	set short_month [template::util::date::monthName $iv_month short]
    }
    set iv_total_amount [db_string get_iv_total_amount " "]
    set iv_count [db_string get_iv_count " "]
}

