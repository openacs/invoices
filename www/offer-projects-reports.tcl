ad_page_contract {
    Generates reports about the projects

    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-21
    @creation-date 2006-08-22
} {
    {start_date "YYYY-MM-DD"}
    {end_date "YYYY-MM-DD"}
    {orderby ""}
    {format "normal"}
}

set page_title "[_ invoices.Report_Projects]"
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
