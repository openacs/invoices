<?xml version="1.0"?>
<queryset>

<fullquery name="get_organization_and_currencies">
      <querytext>

	select t.organization_id, t.currency, t.paid_currency,
	       t.vat_percent as cur_vat_percent, t.cancelled_p,
               t.invoice_id as invoice_rev_id, t.parent_invoice_id,
               t.total_amount as cur_total_amount, t.status,
               t.amount_sum as cur_amount_sum
	from iv_invoices t, cr_items i
	where i.latest_revision = t.invoice_id
	and i.item_id = :invoice_id

      </querytext>
</fullquery>

<fullquery name="projects">
      <querytext>

	    select cp.item_id
	    from cr_items ci, cr_items co, cr_items cp, iv_invoice_items ii,
	         iv_offer_items oi, pm_projects p, acs_rels r
	    where ci.item_id = :invoice_id
	    and ii.invoice_id = ci.latest_revision
	    and oi.offer_item_id = ii.offer_item_id
	    and oi.offer_id = co.latest_revision
	    and r.object_id_one = co.item_id
	    and r.object_id_two = cp.item_id
	    and r.rel_type = 'application_data_link'
	    and p.project_id = cp.latest_revision

      </querytext>
</fullquery>

<fullquery name="cancellation_recipients">
      <querytext>

	select p.first_names || ' ' || p.last_name, p.person_id
	from persons p, iv_invoices i
	where i.invoice_id = :parent_invoice_id
	and p.person_id = i.recipient_id
	order by lower(p.last_name), lower(p.first_names)

      </querytext>
</fullquery>

<fullquery name="credit_recipients">
      <querytext>

	select p.first_names || ' ' || p.last_name, p.person_id
	from persons p, acs_rels r
	where r.object_id_one = p.person_id
	and r.object_id_two = :organization_id
	and r.rel_type = 'contact_rels_ir'
	order by lower(p.last_name), lower(p.first_names)

      </querytext>
</fullquery>

<fullquery name="recipients">
      <querytext>

    select p.first_names || ' ' || p.last_name, p.person_id
    from persons p, pm_projects pj, cr_items i
    where i.item_id in ([join $project_id ,])
    and i.latest_revision = pj.project_id
    and p.person_id in ( select party_id from pm_project_assignment where project_id in ([join $project_id ,]))
    order by lower(p.last_name), lower(p.first_names)

      </querytext>
</fullquery>

<fullquery name="offer_items">
      <querytext>

    select cr.title, cr.description, ofi.offer_item_id, ofi.item_units, ofi.offer_id,
           ofi.price_per_unit, ofi.item_nr, pi.item_id as project_id, of.credit_percent,
           pr.title as project_title, ofi.vat, ofi.rebate, m.category_id
    from cr_items oi, cr_revisions cr, cr_items pi, cr_revisions pr,
         acs_objects o, acs_rels r, iv_offers of, iv_offer_items ofi
    left outer join category_object_map m on (m.object_id = ofi.offer_item_id)
    where o.object_id = ofi.offer_id
    and o.package_id = :package_id
    and oi.latest_revision = ofi.offer_id
    and r.object_id_one = pi.item_id
    and r.object_id_two = oi.item_id
    and r.rel_type = 'application_data_link'
    and pr.revision_id = pi.latest_revision
    and pi.item_id in ([join $project_id ,])
    and cr.revision_id = ofi.offer_item_id
    and of.offer_id = ofi.offer_id
    and not exists (select 1
		    from iv_invoice_items ii, iv_invoices i
		    where ii.offer_item_id = ofi.offer_item_id
                    and i.invoice_id = ii.invoice_id
                    and i.cancelled_p = 'f')
    order by pi.item_id, ofi.item_nr

      </querytext>
</fullquery>

<fullquery name="invoice_items">
      <querytext>

	select ir.title, ir.description, ir.item_id as iv_item_id,
               i.item_units, i.price_per_unit, i.item_nr, ofi.offer_id,
               pi.item_id as project_id, pr.title as project_title,
               i.vat as old_vat, i.rebate, m.category_id, i.offer_item_id,
               of.credit_percent
	from cr_items oi, iv_invoice_items i, cr_revisions ir, cr_items pi,
	     cr_revisions pr, iv_offers of, cr_items vi, cr_items ii, acs_rels r,
	     iv_offer_items ofi
	left outer join category_object_map m on (m.object_id = ofi.offer_item_id)
	where oi.latest_revision = ofi.offer_id
	and i.offer_item_id = ofi.offer_item_id
	and i.iv_item_id = ir.revision_id
	and ir.revision_id = ii.latest_revision
	and i.invoice_id = vi.latest_revision
	and vi.item_id = :invoice_id
        and r.object_id_one = pi.item_id
        and r.object_id_two = oi.item_id
        and r.rel_type = 'application_data_link'
	and pr.revision_id = pi.latest_revision
        and of.offer_id = ofi.offer_id
	order by pi.item_id, i.item_nr

      </querytext>
</fullquery>

<fullquery name="project_titles">
      <querytext>

	select r.title
	from cr_revisions r, cr_items i
	where r.revision_id = i.latest_revision
	and i.item_id in ([join $project_id ,])

      </querytext>
</fullquery>

<fullquery name="offer_data">
      <querytext>

	select min(o.payment_days) as payment_days,
	       max(o.vat_percent) as vat_percent,
	       sum(o.vat) as vat,
	       sum(o.amount_total) as amount_total,
	       sum(o.amount_sum) as amount_sum
	from iv_offers o, cr_items i, acs_rels r
	where o.offer_id = i.latest_revision
	and r.object_id_one in ([join $project_id ,])
	and r.object_id_two = i.item_id
	and r.rel_type = 'application_data_link'

      </querytext>
</fullquery>

<fullquery name="get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.parent_invoice_id, t.total_amount,
	       t.paid_amount, t.payment_days, t.vat, t.vat_percent,
	       to_char(t.due_date, :date_format) as due_date, t.amount_sum,
	       o.creation_user, p.first_names, p.last_name, t.recipient_id,
	       to_char(o.creation_date, :timestamp_format) as creation_date
	from iv_invoices t, cr_revisions r, cr_items i, acs_objects o,
	     persons p
	where r.revision_id = t.invoice_id
	and i.latest_revision = r.revision_id
	and i.item_id = :invoice_id
	and o.object_id = t.invoice_id
	and p.person_id = o.creation_user

      </querytext>
</fullquery>

<fullquery name="check_offer_status">
      <querytext>

		select count(*) as unbilled_items
		from iv_offers o, iv_offer_items ofi
		where o.offer_id = :offer_id
		and ofi.offer_id = o.offer_id
		and not exists (select 1
				from iv_invoice_items ii
				where ii.offer_item_id = ofi.offer_item_id)
		group by o.offer_id

      </querytext>
</fullquery>

<fullquery name="get_credit_offer">
      <querytext>

		select of.offer_id as credit_offer_rev_id
		from iv_offers of, cr_items oi, acs_rels r,
		     acs_objects o, pm_projects p, cr_items pi
		where r.object_id_one = pi.item_id
		and r.object_id_two = oi.item_id
		and r.rel_type = 'application_data_link'
		and oi.latest_revision = of.offer_id
		and of.status = 'credit'
		and o.object_id = of.offer_id
		and o.package_id = :package_id
		and pi.latest_revision = p.project_id
		and p.status_id = 2
		and p.customer_id = :organization_id

      </querytext>
</fullquery>

<fullquery name="get_credit_offer_item">
      <querytext>

		select ofi.offer_id as credit_offer_rev_id,
                       oi.item_id as credit_offer_item_id
		from iv_offers of, cr_items i, acs_objects o, acs_rels r,
                     iv_offer_items ofi, cr_items oi, pm_projects p, cr_items pi
		where r.object_id_one = pi.item_id
		and r.object_id_two = i.item_id
		and r.rel_type = 'application_data_link'
		and o.object_id = of.offer_id
		and o.package_id = :package_id
		and of.offer_id = ofi.offer_id
		and of.status = 'credit'
		and i.latest_revision = of.offer_id
		and oi.latest_revision = ofi.offer_item_id
		and ofi.item_nr = :invoice_id
		and pi.latest_revision = p.project_id
		and p.status_id = 2
		and p.customer_id = :organization_id

      </querytext>
</fullquery>

<fullquery name="set_status">
      <querytext>
		update iv_offers
		set status = :status
		where offer_id = :offer_id
      </querytext>
</fullquery>

<fullquery name="get_organizations">
    <querytext>
	select 
		distinct 
		customer_id 
	from 
		pm_projectsx 
	where 
		item_id in ([join $project_id ","])
    </querytext>
</fullquery>

</queryset>
