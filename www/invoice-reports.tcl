# packages/invoices/www/invoice-report.tcl
ad_page_contract {
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    
} {
    {format:optional "normal"}
    organization_id
    {last_years:optional "5"}
    {year:optional ""}
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

set year_p  0
set month_p 0
set day_p   0

if { ![empty_string_p $year] && ![empty_string_p $month]} {
    set day_p 1
} elseif { ![empty_string_p $year] } {
    set month_p 1
} else {
    set year_p 1
}


ad_return_template
