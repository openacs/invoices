ad_page_contract {

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

set elements [list]