# packages/invoices/www/invoice-report.tcl
ad_page_contract {
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    
} {
    {format:optional "normal"}
    organization_id
    {last_years:optional "5"}
    {year:optional ""}
    {day:optional ""}
    {month:optional ""}
    {new_clients_p ""}
    {account_manager_p ""}
    {orderby:optional ""}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_reports]"
set context [list $page_title]

# For to choose how many last years we want to show
ad_form -name aggregate -form {
    {organization_id:text(hidden)
        {value $organization_id}
    }
    {day:text(hidden)
        {value $day}
    }
    {month:text(hidden)
        {value $month}
    }
    {year:text(hidden)
        {value $year}
    }
    {new_clients_p:text(hidden)
	{value $new_clients_p}
    }
    {account_manager_p:text(hidden)
	{value $account_manager_p}
    }
    {last_years:text(text),optional
        {label  "[_ invoices.last_years]:"}
        {value $last_years}
        {html {size 2}}
        {help_text { [_ invoices.aggregate_iv_from] }}
    }
}

# We select which include we want according to the values present on the
# variables year and month
set include_src "/packages/invoices/lib/report-year"
if { ![empty_string_p $year] } {
    set include_src "/packages/invoices/lib/report-month"
}

if { ![empty_string_p $year] && ![empty_string_p $month]} {
    set include_src "/packages/invoices/lib/report-day"
}

# We create 3 multirows for the years, months and days
multirow create years year year_url
multirow create months month month_url
multirow create days day day_url
set actual_year [string range [dt_sysdate] 0 3]

set url [export_vars -base invoice-reports {organization_id month day last_years new_clients_p account_manager_p}]
for { set i $last_years } { $i > 0 } { set i [expr $i - 1] } {
    set myear [expr $actual_year - $i]
    set url [export_vars -base invoice-reports {organization_id {year $myear} month day last_years new_clients_p account_manager_p}]
    multirow append years $myear "<a href=\"$url\">$myear</a>"
}

# We always look for 5 years from actual year
for { set i $actual_year } { $i < [expr $actual_year + 6] } { incr i} {
    set url [export_vars -base invoice-reports {organization_id {year $i} month day last_years new_clients_p account_manager_p}]
    multirow append years $i "<a href=\"$url\">$i</a>"
} 
    
if { [exists_and_not_null year] } {
    set url [export_vars -base invoice-reports {organization_id last_years new_clients_p account_manager_p month day}]
    multirow append years "clear" "<small>(<a href=\"$url\">Clear</a>)</small>"
}

for { set i 1 } { $i < 13 } { incr i } {
    set short_month [template::util::date::monthName $i short]
    # Dates format has a 0 before the number for months that
    # are lower than 10
    if { $i < 10 } {
	set m "0$i"
    } else {
	set m $i
    }
    set url [export_vars -base invoice-reports {organization_id year {month $m} last_years new_clients_p account_manager_p day}]
    multirow append months $m "<a href=\"$url\">$short_month</a>"
}

if { [exists_and_not_null month] } {
    set url [export_vars -base invoice-reports {organization_id year last_years new_clients_p account_manager_p day}]
    multirow append months "clear" "<small>(<a href=\"$url\">Clear</a>)</small>"
}

for { set i 1 } { $i < 32 } { incr i } {
    # Dates format has a 0 before the number for days that
    # are lower than 10
    if { $i < 10 } {
	set d "0$i"
    } else {
	set d $i
    }
    set url [export_vars -base invoice-reports {organization_id year month {day $d} last_years new_clients_p account_manager_p}]
    multirow append days $d "<a href=\"$url\">$d</a>"
}

if { [exists_and_not_null day] } {
    set url [export_vars -base invoice-reports {organization_id year month last_years new_clients_p account_manager_p}]
    multirow append days "clear" "<small>(<a href=\"$url\">Clear</a>)</small>"
}

ad_return_template
