<?xml version="1.0"?>
<queryset>

<fullquery name="cancellation_recipients">
      <querytext>

	select p.first_names || ' ' || p.last_name, p.person_id
	from persons p, iv_invoices i
	where i.invoice_id = :parent_id
	and p.person_id = i.recipient_id
	order by lower(p.last_name), lower(p.first_names)

      </querytext>
</fullquery>

<fullquery name="parent_invoice_data">
      <querytext>

	select vat_percent, total_amount, invoice_nr as parent_invoice_nr
	from iv_invoices
	where invoice_id = :parent_id

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

<fullquery name="get_old_credit">
      <querytext>

		select ofi.price_per_unit as old_credit
		from iv_offer_items ofi, cr_items oi
		where ofi.offer_id = :credit_offer_rev_id
		and oi.latest_revision = ofi.offer_item_id
		and ofi.item_nr = :parent_item_id

      </querytext>
</fullquery>

<fullquery name="mark_cancelled">
      <querytext>

	    update iv_invoices
	    set cancelled_p = 't',
                status = 'cancelled'
	    where invoice_id in (:parent_id, :new_invoice_rev_id)

      </querytext>
</fullquery>

</queryset>
