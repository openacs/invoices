alter table iv_invoices add column amount_sum numeric(12,2);
update iv_invoices set amount_sum = total_amount;

alter table iv_invoices add column recipient_id integer constraint iv_invoices_recipient_fk references parties;
create index iv_invoices_recipient_idx on iv_invoices(recipient_id);
