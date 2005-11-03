# /packages/invoices/www/invoice-items.tcl

ad_page_contract {
    Show all invoices items

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    {page "1"}
    {iv_items_orderby ""}
    {category_id ""}
    {filter_package_id ""}
    {customer_id ""}
    {date_range ""}
    {project_status_id ""}
    {groupby ""}
}

set page_title "[_ invoices.Invoices_items]"
set context [list $page_title]

set elements [list item_title final_amount invoice_title rebate categories]
set filters_p 1