ad_page_contract {
    mark invoice as paid

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-05
} {
    invoice_id:integer,multiple
    {return_url "/invoices"}
}

set user_id [auth::require_login]

# Make sure you only mark invoices as "Paid" that have the status billed

db_transaction {
    foreach inv_id $invoice_id {
	db_dml pay_invoice {}
    }
}

set invoice_id [lindex $invoice_id 0]

ad_returnredirect $return_url
