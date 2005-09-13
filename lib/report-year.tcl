if {![info exists format]} {
    set format "normal"
}

if {![info exists orderby]} {
    set orderby ""
}

if {![info exists package_id]} {
    set package_id [ad_conn package_id]
}

if {![info exists base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

foreach optional_param {row_list organization_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set extra_query ""
if { ![empty_string_p $organization_id] } {
    set extra_query "and iv.organization_id = $organization_id"
}

if { ![empty_string_p $month] } {
    append extra_query " and to_char(iv.due_date, 'MM') = :month"
}

if { ![empty_string_p $day] } {
    append extra_query " and to_char(iv.due_date, 'DD') = :day"
}

#ad_return_complaint 1 "$extra_query $day"
foreach unset_param {new_clients_p account_manager_p} {
    if {[info exists $unset_param]} {
	if {[empty_string_p [set $unset_param]]} {
	    unset $unset_param
	}
    }
}

set extra_url ""
# Filter to show only resulst for clients in less than 1 year
if {[exists_and_not_null new_clients_p] } {
    append extra_url "&new_clients_p=$new_clients_p"
}
set new_clients_where_clause "o.creation_date > now() - '1 year' :: interval"

if {[exists_and_not_null account_manager_p] } {
    append extra_url "&account_manager_p=$account_manager_p"
}

append extra_url "&day=$day&month=$month&last_years=$last_years"

# Calculating from_year to use in the query 
# according of the number of years in last_years
set act_date [dt_sysdate]
set act_year [string range $act_date 0 3]
set from_year [expr $act_year - $last_years]
regsub "${act_year}-" $act_date "${from_year}-" from_date

template::list::create \
    -name iv_years \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	iv_year {
	    label "[_ invoices.year]:"
	    display_template {
		<a href="?year=@iv_years.iv_year@&organization_id=$organization_id$extra_url">@iv_years.iv_year@</a>
	    }
	}
	iv_count {
	    label "[_ invoices.count]:"
	}
	iv_total_amount {
	    label "[_ invoices.Amount_total]"
	}
    } \
    -sub_class narrow \
    -filters {
	organization_id {
	}
	last_years {
	}
	day {
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
    }

db_multirow -extend { iv_count iv_total_amount } iv_years iv_invoice_years " " {
    set iv_count [db_string get_iv_count " "]
    set iv_total_amount [db_string get_iv_total_amount " "]
}