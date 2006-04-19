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
    $extra_sql
    group by oo.organization_id, oo.name
    [template::list::orderby_clause -name reports -orderby]
    </querytext>
</fullquery>

<partialquery name="customers_of_country">
    <querytext>
    and oo.organization_id in (
        select o.organization_id
        from organizations o, postal_addresses p, ams_attribute_values av, cr_items i
        where i.item_id = o.organization_id
        and av.object_id = i.latest_revision
        and av.attribute_id = :postal_attribute_id
        and p.address_id = av.value_id
        and p.country_code in ('[join $country_code "', '"]')
    )
    </querytext>
</partialquery>

<partialquery name="customers_of_sector">
    <querytext>
	and oo.organization_id in (
				   select o.organization_id
				   from organizations o, ams_options ao, ams_attribute_values av, cr_items i
				   where i.item_id = o.organization_id
				   and av.object_id = i.latest_revision
				   and av.attribute_id = :sector_attribute_id
				   and ao.value_id = av.value_id
				   and ao.option_id in ([join $sector ,]))
    </querytext>
</partialquery>

<partialquery name="customers_of_account_manager">
    <querytext>
	and oo.organization_id in (
				   select object_id_two
				   from acs_rels
				   where rel_type = 'contact_rels_am'
				   and object_id_one = :manager_id)
    </querytext>
</partialquery>

<partialquery name="new_customers">
    <querytext>
	and oo.organization_id in (
				   select oo.organization_id
				   from organizations oo, iv_offers o, cr_items i, acs_objects ao, acs_objects oar,
				        group_member_map m,
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
				   and m.member_id = oo.organization_id
				   and m.container_id = :customer_group_id
				   and oar.object_id = m.rel_id
				   and oar.creation_date > to_timestamp(:first_date, 'YYYY-MM-DD')
				   $start_date_extra_sql
				   $end_date_extra_sql )
    </querytext>
</partialquery>

<partialquery name="start_date">
    <querytext>
ao.creation_date > to_timestamp(:start_date, 'YYYY-MM-DD')
    </querytext>
</partialquery>

<partialquery name="start_date_new_customer">
    <querytext>
and ao.creation_date > to_timestamp(:start_date, 'YYYY-MM-DD') - interval '1 month'
    </querytext>
</partialquery>

<partialquery name="end_date">
    <querytext>
ao.creation_date < to_timestamp(:end_date, 'YYYY-MM-DD') + interval '1 day'
    </querytext>
</partialquery>

<partialquery name="end_date_new_customer">
    <querytext>
and ao.creation_date < to_timestamp(:end_date, 'YYYY-MM-DD') + interval '1 day'
    </querytext>
</partialquery>

<partialquery name="amount_above_limit">
    <querytext>
and i.total_amount >= :amount_limit
    </querytext>
</partialquery>

<partialquery name="category_amount_above_limit">
    <querytext>
and ii.amount_total >= :amount_limit
    </querytext>
</partialquery>

<fullquery name="category_customer_orders">
    <querytext>
    select oo.organization_id as customer_id, oo.name as customer_name, sum(ii.amount_total) as amount_total,
           count(distinct i.invoice_id) as invoice_count
    from organizations oo, iv_invoices i, cr_items ci, acs_objects ao, iv_invoice_items ii, cr_items cii,
         category_object_map m
    where i.organization_id = oo.organization_id
    and ao.object_id = ci.item_id
    and i.invoice_id = ci.latest_revision
    and i.cancelled_p = 'f'
    and ii.invoice_id = i.invoice_id
    and cii.latest_revision = ii.iv_item_id
    and m.object_id = ii.offer_item_id
    and m.category_id in ([join $category_id ,])
    and not exists (select 1 from iv_invoices where parent_invoice_id = i.invoice_id and cancelled_p = 'f')
    [template::list::filter_where_clauses -and -name "reports"]
    $extra_sql
    group by oo.organization_id, oo.name
    [template::list::orderby_clause -name reports -orderby]
    </querytext>
</fullquery>

</queryset>
