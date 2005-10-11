alter table iv_price_lists add column credit_percent numeric(12,5) default 0;
alter table iv_offers add column credit_percent numeric(12,5) default 0;
alter table iv_offers add column status varchar(10) default 'new';
alter table iv_invoices add column status varchar(10) default 'new';

update iv_price_lists set credit_percent = 0;
update iv_offers set status = 'new', credit_percent = 0;
update iv_invoices set status = 'new';
