<?xml version="1.0"?>
<queryset>

<fullquery name="get_data">
      <querytext>

	select t.payment_id as payment_rev_id, r.title, r.description,
	       t.invoice_id, t.organization_id, t.received_date,
	       t.amount, t.currency
	from iv_payments t, cr_revisions r, cr_items i
	where r.revision_id = t.payment_id
	and i.latest_revision = r.revision_id
	and i.item_id = :payment_id

      </querytext>
</fullquery>

</queryset>
    
