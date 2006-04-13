<?xml version="1.0"?>
<queryset>

<fullquery name="new_customer_with_orders">
    <querytext>
    select oo.organization_id as customer_id, oo.name as customer_name, o.amount_total,
           to_char(ao.creation_date, 'YYYY-MM-DD') as creation_date
    from organizations oo, iv_offers o, cr_items i, acs_objects ao, acs_objects oao,
         (select min(o2.offer_id) as offer_id, o2.organization_id
	  from iv_offers o2, cr_items i2
	  where o2.offer_id = i2.latest_revision
	  and o2.accepted_date is not null
	  and o2.amount_total > 1
	  group by o2.organization_id) sub
    where o.organization_id = oo.organization_id
    and ao.object_id = i.item_id
    and o.offer_id = i.latest_revision
    and o.organization_id = sub.organization_id
    and o.offer_id = sub.offer_id
    and oao.object_id = oo.organization_id
    and oao.creation_date > to_timestamp(:first_date, 'YYYY-MM-DD')
    [template::list::filter_where_clauses -and -name "reports"]
    [template::list::orderby_clause -name reports -orderby]
    </querytext>
</fullquery>

</queryset>
