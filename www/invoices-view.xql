<?xml version="1.0"?>
<queryset>

<fullquery name="invoices">
      <querytext>

    select ii.item_id as invoice_id, i.invoice_nr, i.organization_id, i.parent_invoice_id,
           i.total_amount, i.recipient_id, i.organization_id, i.invoice_nr, ir.title
    from iv_invoices i, cr_items ii, cr_revisions ir
    where ii.latest_revision = i.invoice_id
    and ir.revision_id = i.invoice_id
    and ii.item_id in ([join $invoice_id ,])

      </querytext>
</fullquery>

</queryset>
