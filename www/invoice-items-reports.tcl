# packages/invoices/www/invoice-items-reports.tcl
ad_page_contract {
    Generates reports about the invoice items
    by year, month and day

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    {year ""}
    {month ""}
    {day ""}
    {last_years "5"}
    {show_p "f"}
    {category_f:multiple ""}
}

set page_title "[_ invoices.Invoice_Items_Reports]"
set context [list $page_title]

set base_url [ad_conn url]

set elements {}