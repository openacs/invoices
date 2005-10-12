<?xml version="1.0"?>
<queryset>

<fullquery name="invoice_data">
      <querytext>

    select i.organization_id
    from iv_invoices i, cr_items ii
    where ii.latest_revision = i.invoice_id
    and ii.item_id = :invoice_id

      </querytext>
</fullquery>

</queryset>
