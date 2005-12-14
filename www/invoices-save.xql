<?xml version="1.0"?>
<queryset>

<fullquery name="invoice_data">
      <querytext>

    select max(i.recipient_id) as recipient_id, max(i.organization_id) as organization_id
    from iv_invoices i, cr_items ii, cr_items fi
    where ii.latest_revision = i.invoice_id
    and ii.item_id = fi.parent_id
    and fi.item_id in ([join $file_id ,])

      </querytext>
</fullquery>

<fullquery name="get_parent_invoice_id">
      <querytext>

    select parent_id as invoice_id
    from cr_items
    where item_id = :one_file_id

      </querytext>
</fullquery>

</queryset>
