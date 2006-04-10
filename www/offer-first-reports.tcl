ad_page_contract {
    Generates reports about the customers who first ordered
    by year, month and day

    @author Timo Hentschel (timo@timohentschel.de)
} {
    {year ""}
    {month ""}
    {day ""}
    {orderby ""}
    {last_years "5"}
}

set page_title "[_ invoices.First_Order_Reports]"
set context [list $page_title]

set base_url [ad_conn url]

ad_return_template
