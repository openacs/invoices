alter table iv_invoices add column contact_id integer constraint iv_invoices_contact_fk references parties;
