<?xml version="1.0"?>
<queryset>

<fullquery name="iv::invoice::set_status.update_status">
      <querytext>

	update iv_invoices
	set status = :status
	where invoice_id = (select latest_revision
                          from cr_items
                          where item_id = :invoice_id)

      </querytext>
</fullquery>

<fullquery name="iv::invoice::data.get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.total_amount, t.vat, t.vat_percent,
	       o.creation_user, p.first_names, p.last_name, t.amount_sum,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.due_date, :timestamp_format) as due_date,
	       t.payment_days, t.currency, t.organization_id, t.recipient_id,
	       t.contact_id
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

    select cr.title, cr.description, cr.item_id, ii.offer_item_id,
           ii.item_units, ii.price_per_unit, ii.item_nr,
           ii.rebate, ii.vat, m.category_id, ofi.file_count,
           ofi.page_count, pr.title as project_title, p.project_code,
           pi.item_id as project_id
    from iv_offer_items ofi, cr_items ci, cr_revisions cr,
         category_object_map m, iv_invoice_items ii, cr_revisions oor,
         acs_data_links r, cr_items pi, cr_revisions pr, pm_projects p
    where ci.latest_revision = ii.invoice_id
    and cr.revision_id = ii.iv_item_id
    and ci.item_id = :invoice_id
    and m.object_id = ofi.offer_item_id
    and ofi.offer_item_id = ii.offer_item_id
    and oor.revision_id = ofi.offer_id
    and r.object_id_two = oor.item_id
    and r.object_id_one = pi.item_id
    and pi.latest_revision = pr.revision_id
    and pr.revision_id = p.project_id
    order by ii.sort_order

      </querytext>
</fullquery>

<fullquery name="iv::invoice::parse_data.get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.total_amount, t.vat, t.vat_percent,
	       o.creation_user, p.first_names, p.last_name, t.amount_sum,
	       to_char(o.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date,
	       to_char(t.due_date, 'YYYY-MM-DD HH24:MI:SS') as due_date,
	       t.payment_days, t.currency, t.organization_id, t.recipient_id,
	       t.contact_id
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

    select cr.title, cr.description, cr.item_id, ii.offer_item_id,
           ii.item_units, ii.price_per_unit, ii.item_nr,
           ii.rebate, ii.vat, m.category_id, ofi.file_count,
           ofi.page_count, pr.title as project_title, p.project_code,
           pi.item_id as project_id, o.credit_percent
    from cr_items ci, cr_revisions cr, iv_invoice_items ii, cr_revisions oor,
         acs_data_links r, cr_items pi, cr_revisions pr, pm_projects p, iv_offers o,
         iv_offer_items ofi
    left outer join category_object_map m on (m.object_id = ofi.offer_item_id)
    where ci.latest_revision = ii.invoice_id
    and cr.revision_id = ii.iv_item_id
    and ci.item_id = :invoice_id
    and ofi.offer_item_id = ii.offer_item_id
    and oor.revision_id = ofi.offer_id
    and r.object_id_two = oor.item_id
    and r.object_id_one = pi.item_id
    and pi.latest_revision = pr.revision_id
    and pr.revision_id = p.project_id
    and o.offer_id = ofi.offer_id
    order by ii.sort_order

      </querytext>
</fullquery>

</queryset>
