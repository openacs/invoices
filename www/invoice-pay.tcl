ad_page_contract {
    mark invoice as paid

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-10-05
} {
    invoice_id:integer,multiple
}

set user_id [auth::require_login]

db_transaction {
    foreach inv_id $invoice_id {
	db_dml pay_invoice {}
    }
}

set invoice_id [lindex $invoice_id 0]
db_1row invoice_data {}

ad_returnredirect [export_vars -base invoice-list {organization_id}]
