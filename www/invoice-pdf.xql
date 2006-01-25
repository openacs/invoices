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

<fullquery name="set_publish_status">
      <querytext>

    update cr_items
    set publish_status = 'live'
    where item_id = :one_file

      </querytext>
</fullquery>

<fullquery name="set_context_id">
      <querytext>

    update acs_objects
    set context_id = :invoice_folder_id
    where object_id = :one_file

      </querytext>
</fullquery>

</queryset>
