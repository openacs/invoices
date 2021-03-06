<?xml version="1.0"?>
<queryset>

<fullquery name="invoice_data">
      <querytext>

    select i.invoice_nr, i.organization_id, i.parent_invoice_id, i.invoice_nr,
           i.total_amount, i.recipient_id, i.contact_id, i.pdf_status, i.status
    from iv_invoices i, cr_items ii
    where ii.latest_revision = i.invoice_id
    and ii.item_id = :invoice_id

      </querytext>
</fullquery>

</queryset>
