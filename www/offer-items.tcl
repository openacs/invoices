# /packages/invoices/www/offer-items.tcl

ad_page_contract {
    Show all offer items

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    {page "1"}
    {offer_items_orderby ""}
}

set page_title "[_ invoices.Offers_items]"
set context [list $page_title]

set elements [list item_title final_amount offer_title rebate]
set filters_p 1