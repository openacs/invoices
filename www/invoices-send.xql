<?xml version="1.0"?>
<queryset>

<fullquery name="count_contacts">
      <querytext>

    select count(distinct i.contact_id)
    from iv_invoices i, cr_items ii, cr_items fi
    where ii.latest_revision = i.invoice_id
    and ii.item_id = fi.parent_id
    and fi.item_id in ([join $file_id ,])

      </querytext>
</fullquery>

<fullquery name="invoice_data">
      <querytext>

    select max(i.contact_id) as contact_id, max(i.organization_id) as organization_id
    from iv_invoices i, cr_items ii, cr_items fi
    where ii.latest_revision = i.invoice_id
    and ii.item_id = fi.parent_id
    and fi.item_id in ([join $file_id ,])

      </querytext>
</fullquery>

<fullquery name="invoice_nrs">
      <querytext>

    select i.invoice_nr
    from iv_invoices i, cr_items ii, cr_items fi
    where ii.latest_revision = i.invoice_id
    and ii.item_id = fi.parent_id
    and fi.item_id in ([join $file_id ,])

      </querytext>
</fullquery>

</queryset>
