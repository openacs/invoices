ad_page_contract {
    Generates reports about the customers who first ordered
    by year, month and day

    @author Timo Hentschel (timo@timohentschel.de)
} {
    {start_date "YYYY-MM-DD"}
    {end_date "YYYY-MM-DD"}
    {orderby ""}
}

set page_title "[_ invoices.First_Order_Reports]"
set context [list $page_title]

set base_url [ad_conn url]
set current_url [ad_conn url]
set clear_link [export_vars -base $current_url {page orderby organization_id}]
set export_vars [export_vars -form {page orderby organization_id}]

set clear_p 1
if {$start_date == "YYYY-MM-DD" && $end_date == "YYYY-MM-DD"} {
    set clear_p 0
}

ad_return_template
