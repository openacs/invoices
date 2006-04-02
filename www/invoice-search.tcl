ad_page_contract {
    Page to redirect to invoice.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    invoice_nr
}

set match_invoices [db_list get_invoices {}]
set match_length [llength $match_invoices]

if { [string equal $match_length 0] } {
    # No Match just redirect
    ad_returnredirect $return_url

} else {
    set invoice_id [lindex [lindex $match_invoices 0] 0]
	
    # Just redirect to the invoice
    ad_returnredirect [export_vars -base invoice-ae {invoice_id {mode display}}]
}
