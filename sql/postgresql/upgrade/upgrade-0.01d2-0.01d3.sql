alter table iv_offers add column accepted_date timestamptz;

create index iv_offers_finish_idx on iv_offers(finish_date);
create index iv_offers_accepted_idx on iv_offers(accepted_date);

create index iv_invoices_due_idx on iv_invoices(due_date);
