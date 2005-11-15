ad_page_contract {
    Billable Projects

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-16
} {
    {organization_id:integer ""}
    {orderby ""}
} 

set iv_package_id [ad_conn package_id]
set iv_base_url [apm_package_url_from_id $iv_package_id]
set page_title "[_ invoices.Billable_Projects]"
set context [list]
