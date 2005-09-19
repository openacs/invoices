<?xml version="1.0"?>
<queryset>

<fullquery name="iv::offer::edit.set_accepted_date">
      <querytext>

	update iv_offers
	set accepted_date = (select accepted_date
			from iv_offers
			where offer_id = :old_rev_id)
	where offer_id = :new_rev_id

      </querytext>
</fullquery>

<fullquery name="iv::offer::data.get_data">
      <querytext>

	select t.offer_id as offer_rev_id, r.title, r.description,
	       t.offer_nr, t.amount_total, t.vat, t.vat_percent, t.comment,
	       to_char(t.finish_date, 'YYYY-MM-DD HH24:MI:SS') as finish_ansi,
	       to_char(t.finish_date, :timestamp_format) as finish_date,
	       o.creation_user, p.first_names, p.last_name,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.accepted_date, :timestamp_format) as accepted_date,
	       t.amount_sum as amount_sum_, t.payment_days, t.date_comment,
	       t.currency, t.organization_id, t.amount_sum
	from iv_offers t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.offer_id
	and i.latest_revision = r.revision_id
	and i.item_id = :offer_id
	and o.object_id = t.offer_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

<fullquery name="iv::offer::parse_data.get_data">
      <querytext>

	select t.offer_id as offer_rev_id, r.title, r.description,
	       t.offer_nr, t.amount_total, t.vat, t.vat_percent, t.comment,
	       to_char(t.finish_date, 'YYYY-MM-DD HH24:MI:SS') as finish_ansi,
	       to_char(t.finish_date, :timestamp_format) as finish_date,
	       o.creation_user, p.first_names, p.last_name,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.accepted_date, :timestamp_format) as accepted_date,
	       t.amount_sum as amount_sum_, t.payment_days, t.date_comment,
	       t.currency, t.organization_id, t.amount_sum
	from iv_offers t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.offer_id
	and i.latest_revision = r.revision_id
	and i.item_id = :offer_id
	and o.object_id = t.offer_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

<fullquery name="iv::offer::data.offer_items">
      <querytext>

    select r.title, r.description, r.item_id, ofi.offer_item_id,
           ofi.item_units, ofi.price_per_unit, ofi.item_nr, ofi.comment,
           ofi.rebate, ofi.vat, m.category_id, ofi.file_count, ofi.page_count
    from iv_offer_items ofi, cr_items oi, acs_objects o, cr_revisions r,
         category_object_map m
    where o.object_id = ofi.offer_id
    and o.package_id = :package_id
    and oi.latest_revision = ofi.offer_id
    and r.revision_id = ofi.offer_item_id
    and oi.item_id = :offer_id
    and m.object_id = ofi.offer_item_id
    order by ofi.sort_order

      </querytext>
</fullquery>

<fullquery name="iv::offer::parse_data.offer_items">
      <querytext>

    select r.title, r.description, r.item_id, ofi.offer_item_id,
           ofi.item_units, ofi.price_per_unit, ofi.item_nr, ofi.comment,
           ofi.rebate, ofi.vat, m.category_id, ofi.file_count, ofi.page_count
    from iv_offer_items ofi, cr_items oi, acs_objects o, cr_revisions r,
         category_object_map m
    where o.object_id = ofi.offer_id
    and o.package_id = :package_id
    and oi.latest_revision = ofi.offer_id
    and r.revision_id = ofi.offer_item_id
    and oi.item_id = :offer_id
    and m.object_id = ofi.offer_item_id
    order by ofi.sort_order

      </querytext>
</fullquery>

<fullquery name="iv::offer::billed_p_not_cached.get_items_count">
      <querytext>
	select 
		count(offer_item_id) 
	from 	
		iv_offer_items 
	where 
		offer_id = :offer_id
      </querytext>
</fullquery>

<fullquery name="iv::offer::billed_p_not_cached.get_billed_items_count">
      <querytext>
	select
		count(i.offer_item_id)
	from 
		iv_invoice_items i,
		iv_offer_items o
	where
		i.offer_item_id = o.offer_item_id
		and o.offer_id = :offer_id
      </querytext>
</fullquery>

</queryset>
