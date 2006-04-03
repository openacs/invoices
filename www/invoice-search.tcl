ad_page_contract {
    Page to redirect to invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_nr
    {return_url ""}
}

set match_invoices [db_list get_invoices {}]
set match_length [llength $match_invoices]

if { [string equal $match_length 0] } {
    # No Match just redirect
    # ad_returnredirect $return_url
    ad_return_error "[_ invoices.no_such_invoice_no]" "[_ invoices.lt_no_such_invoice_no]"

} else {
    set invoice_id [lindex [lindex $match_invoices 0] 0]
	
    # Just redirect to the invoice
    ad_returnredirect [export_vars -base invoice-ae {invoice_id {mode display}}]
}
