ad_page_contract {
    Generates reports about the customers and their billed amount
    by year, month and day

    @author Timo Hentschel (timo@timohentschel.de)
} {
    {start_date "YYYY-MM-DD"}
    {end_date "YYYY-MM-DD"}
    {orderby ""}
    {country_code:multiple ""}
    {sector:multiple ""}
    {category_id:multiple ""}
    {manager_id ""}
    {type ""}
    {amount_limit ""}
}

set user_id [auth::require_login]
set package_id [ad_conn package_id]

set manager_p [group::member_p -group_name "Account Manager"]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# redirect if not admin and not account manager
if {!$admin_p && !$manager_p} {
    ad_returnredirect "/"
    ad_script_abort
}

set page_title "[_ invoices.Customer_Invoices_Reports]"
set context [list $page_title]

set base_url [ad_conn url]
set current_url [ad_conn url]
set clear_link [export_vars -base $current_url {page orderby organization_id}]
set export_vars [export_vars -form {orderby country_code:multiple sector:multiple category_id:multiple manager_id type}]

set clear_p 1
if {$start_date == "YYYY-MM-DD" && $end_date == "YYYY-MM-DD"} {
    set clear_p 0
}

ad_return_template
