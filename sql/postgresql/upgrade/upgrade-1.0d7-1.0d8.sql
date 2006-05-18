alter table iv_offers add column show_sum_p char(1) constraint iv_offers_show_sum_p check (show_sum_p in ('t','f'));
alter table iv_offers alter column show_sum_p set default 't';
update iv_offers set show_sum_p = 't';
