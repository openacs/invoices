<?xml version="1.0"?>
<queryset>

<fullquery name="get_organization_and_currencies">
      <querytext>

	select t.organization_id, t.currency, t.accepted_date,
	       t.vat_percent as cur_vat_percent, t.offer_id as offer_rev_id,
	       (t.amount_total - t.amount_sum) as sum_total_diff
	from iv_offers t, cr_items i
	where i.latest_revision = t.offer_id
	and i.item_id = :offer_id

      </querytext>
</fullquery>

<fullquery name="check_invoices">
      <querytext>

	    select count(*) as invoice_count
	    from iv_invoice_items ii, iv_offer_items oi
	    where ii.offer_item_id = oi.offer_item_id
	    and oi.offer_id = :offer_rev_id

      </querytext>
</fullquery>

<fullquery name="open_projects">
      <querytext>

    select '#' || r.item_id || ' ' || r.title as title, r.item_id
    from cr_revisions r, cr_items i, pm_projects p, acs_rels ar
    where ar.object_id_one = :organization_id
    and ar.object_id_two = r.revision_id
    and ar.rel_type = 'application_data_link'
    and i.latest_revision = r.revision_id
    and p.project_id = r.revision_id
    and i.item_id not in (select ar2.object_id_one
                          from acs_rels ar2, cr_items oi, iv_offers o
                          where ar2.object_id_two = oi.item_id
                          and ar2.rel_type = 'application_data_link'
                          and oi.latest_revision = o.offer_id)
    order by r.item_id desc

      </querytext>
</fullquery>

<fullquery name="all_prices">
      <querytext>

    select p.category_id, p.amount
    from iv_prices p, cr_items i
    where p.list_id = :list_id
    and p.price_id = i.latest_revision

      </querytext>
</fullquery>

<fullquery name="get_project">
      <querytext>

	select '#' || r.item_id || ' ' || r.title as project_name, r.item_id
	from cr_revisions r, cr_items i, pm_projects p, acs_rels ar
	where ar.object_id_one = :offer_id
	and ar.object_id_two = i.item_id
	and ar.rel_type = 'application_data_link'
	and i.latest_revision = r.revision_id
	and p.project_id = r.revision_id

      </querytext>
</fullquery>

<fullquery name="offer_items">
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

<fullquery name="get_data">
      <querytext>

	select t.offer_id as offer_rev_id, r.title, r.description,
	       t.offer_nr, t.amount_total, t.vat, t.vat_percent, t.comment,
	       to_char(t.finish_date, 'YYYY-MM-DD HH24:MI:SS') as finish_ansi,
	       to_char(t.finish_date, :timestamp_format) as finish_date,
	       o.creation_user, p.first_names, p.last_name,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
	       to_char(t.accepted_date, :timestamp_format) as accepted_date,
	       t.amount_sum as amount_sum_, t.payment_days
	from iv_offers t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.offer_id
	and i.latest_revision = r.revision_id
	and i.item_id = :offer_id
	and o.object_id = t.offer_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

</queryset>
