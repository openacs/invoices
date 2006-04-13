<?xml version="1.0"?>
<queryset>

<fullquery name="all_customer_orders">
    <querytext>
    select oo.organization_id as customer_id, oo.name as customer_name, sum(i.total_amount) as amount_total,
           count(*) as invoice_count
    from organizations oo, iv_invoices i, cr_items ci, acs_objects ao
    where i.organization_id = oo.organization_id
    and ao.object_id = ci.item_id
    and i.invoice_id = ci.latest_revision
    and i.cancelled_p = 'f'
    [template::list::filter_where_clauses -and -name "reports"]
    group by oo.organization_id, oo.name
    [template::list::orderby_clause -name reports -orderby]
    </querytext>
</fullquery>

<fullquery name="all_customer_orders_of_country">
    <querytext>
    select oo.organization_id as customer_id, oo.name as customer_name, sum(i.total_amount) as amount_total,
           count(*) as invoice_count
    from organizations oo, iv_invoices i, cr_items ci, acs_objects ao, postal_addresses p,
         ams_attribute_values av, cr_items ooi
    where i.organization_id = oo.organization_id
    and ao.object_id = ci.item_id
    and i.invoice_id = ci.latest_revision
    and i.cancelled_p = 'f'
    and ooi.item_id = oo.organization_id
    and av.object_id = ooi.latest_revision
    and av.attribute_id = :postal_attribute_id
    and p.address_id = av.value_id
    [template::list::filter_where_clauses -and -name "reports"]
    group by oo.organization_id, oo.name
    [template::list::orderby_clause -name reports -orderby]
    </querytext>
</fullquery>

</queryset>
