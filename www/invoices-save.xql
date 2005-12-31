<?xml version="1.0"?>
<queryset>

<fullquery name="invoice_data">
      <querytext>

    select max(i.organization_id) as organization_id
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

<fullquery name="set_publish_status">
      <querytext>

    update cr_items
    set publish_status = 'live'
    where item_id = :file_item_id

      </querytext>
</fullquery>

</queryset>
