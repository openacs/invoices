<?xml version="1.0"?>
<queryset>

<fullquery name="get_data">
      <querytext>

	select t.invoice_id as invoice_rev_id, r.title, r.description,
	       t.invoice_nr, t.parent_invoice_id, t.total_amount,
	       t.paid_amount, t.payment_days, t.vat, t.vat_percent,
	       to_char(t.due_date, :date_format) as due_date, t.amount_sum,
	       o.creation_user, p.first_names, p.last_name, t.recipient_id,
	       to_char(o.creation_date, :timestamp_format) as creation_date,
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
</queryset>
