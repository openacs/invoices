<?xml version="1.0"?>
<queryset>

<fullquery name="invoice_data">
      <querytext>

    select i.organization_id, i.invoice_id as invoice_rev_id
    from iv_invoices i, cr_items ii
    where ii.latest_revision = i.invoice_id
    and ii.item_id = :invoice_id
    and ii.status = 'new'

      </querytext>
</fullquery>

<fullquery name="pay_invoice">
      <querytext>

    update iv_invoices
    set status = 'paid',
        paid_currency = currency,
        paid_amount = total_amount
    where invoice_id = (select latest_revision
                        from cr_items
                        where item_id = :inv_id)

      </querytext>
</fullquery>

</queryset>
