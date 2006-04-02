<?xml version="1.0"?>
<queryset>

<fullquery name="get_invoices">
    <querytext>
	select ii.item_id
	from iv_invoices i, cr_items ii
	where i.invoice_id = ii.latest_revision
        and i.invoice_nr = :invoice_nr
    </querytext>
</fullquery>

</queryset>
