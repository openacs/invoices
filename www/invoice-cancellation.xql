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

<fullquery name="mark_cancelled">
      <querytext>

	    update iv_invoices
	    set cancelled_p = 't'
	    where invoice_id in (:parent_id, :new_invoice_rev_id)

      </querytext>
</fullquery>

</queryset>
