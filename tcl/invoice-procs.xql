<?xml version="1.0"?>
<queryset>

<fullquery name="iv::invoice::data.get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.total_amount, t.vat, t.vat_percent,
	       o.creation_user, p.first_names, p.last_name, t.amount_sum,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.due_date, :timestamp_format) as due_date,
	       t.payment_days, t.currency, t.organization_id, t.recipient_id
	from iv_invoices t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.invoice_id
	and i.latest_revision = r.revision_id
	and i.item_id = :invoice_id
	and o.object_id = t.invoice_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

<fullquery name="iv::invoice::data.invoice_items">
      <querytext>

    select r.title, r.description, r.item_id, ii.offer_item_id,
           ii.item_units, ii.price_per_unit, ii.item_nr,
           ii.rebate, ii.vat, m.category_id, ofi.file_count, ofi.page_count
    from iv_offer_items ofi, cr_items oi, cr_revisions r,
         category_object_map m, iv_invoice_items ii
    where oi.latest_revision = ii.invoice_id
    and r.revision_id = ii.iv_item_id
    and oi.item_id = :invoice_id
    and m.object_id = ofi.offer_item_id
    and ofi.offer_item_id = ii.offer_item_id
    order by ii.sort_order

      </querytext>
</fullquery>

<fullquery name="iv::invoice::parse_data.get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.total_amount, t.vat, t.vat_percent,
	       o.creation_user, p.first_names, p.last_name, t.amount_sum,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.due_date, :timestamp_format) as due_date,
	       t.payment_days, t.currency, t.organization_id, t.recipient_id
	from iv_invoices t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.invoice_id
	and i.latest_revision = r.revision_id
	and i.item_id = :invoice_id
	and o.object_id = t.invoice_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

<fullquery name="iv::invoice::parse_data.invoice_items">
      <querytext>

    select r.title, r.description, r.item_id, ii.offer_item_id,
           ii.item_units, ii.price_per_unit, ii.item_nr,
           ii.rebate, ii.vat, m.category_id, ofi.file_count, ofi.page_count
    from iv_offer_items ofi, cr_items oi, cr_revisions r,
         category_object_map m, iv_invoice_items ii
    where oi.latest_revision = ii.invoice_id
    and r.revision_id = ii.iv_item_id
    and oi.item_id = :invoice_id
    and m.object_id = ofi.offer_item_id
    and ofi.offer_item_id = ii.offer_item_id
    order by ii.sort_order

      </querytext>
</fullquery>

</queryset>
