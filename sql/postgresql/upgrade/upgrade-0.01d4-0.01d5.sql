alter table iv_invoice_items add column file_count integer;
alter table iv_invoice_items add column page_count integer;
alter table iv_invoices add column cancelled_p char(1) constraint iv_invoices_cancelled_p check (cancelled_p in ('t','f'));
alter table iv_invoices alter column cancelled_p set default 'f';
update iv_invoices set cancelled_p = 'f';

create sequence iv_offer_seq start with 1000;
create sequence iv_invoice_seq start with 1000;
