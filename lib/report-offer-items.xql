<?xml version="1.0"?>
<queryset>

<fullquery name="get_iv_items">
    <querytext>
	select
		distinct	
		oi.offer_item_id,
		oi.title as item_title,
		to_char(oi.creation_date, 'YYYY-MM-DD') as creation_date,
		com.category_id,
		iv.item_id,
		oi.item_units,
		oi.price_per_unit,
		oi.rebate
	from
		iv_offer_itemsx oi,
		iv_offersx iv,
		category_object_map com,
		acs_rels rel,
		pm_projectsx p,
		cr_items i,
		cr_items i2
	where
		iv.item_id = i.item_id
		and oi.offer_id = iv.offer_id
		and oi.offer_id = i.latest_revision
		and oi.offer_item_id = com.object_id
		and rel.object_id_one = iv.item_id
		and rel.rel_type = 'application_data_link'
		and rel.object_id_two = p.item_id
		and p.item_id = i2.item_id
		and i2.latest_revision = p.project_id
		$extra_query
		[template::list::filter_where_clauses -and -name "reports"]
    </querytext>
</fullquery>

<fullquery name="get_final_amount">
    <querytext>
	select
		oi.price_per_unit,
		oi.item_units,
		oi.rebate
	from
		iv_offer_itemsx oi,
		iv_offersx iv,
		category_object_map com,
		cr_items i,
		acs_rels rel,
		pm_projectsx p,
		cr_items i2
	where
		iv.item_id = i.item_id
		and oi.offer_id = iv.offer_id
		and oi.offer_id = i.latest_revision
		and oi.offer_item_id = com.object_id
		and rel.object_id_one = iv.item_id
		and rel.rel_type = 'application_data_link'
		and rel.object_id_two = p.item_id
		and p.item_id = i2.item_id
		and i2.latest_revision = p.project_id
		$extra_query
		[template::list::filter_where_clauses -and -name "reports"]
    </querytext>
</fullquery>

<fullquery name="get_category_trees">
    <querytext>
        select
                distinct
                o.title,
                c.tree_id
        from
                category_object_map com,
                iv_offer_items io,
                acs_objects o,
                categories c
        where
                com.object_id = io.offer_item_id
                and com.category_id = c.category_id
                and c.tree_id = o.object_id
        order by
                o.title asc
    </querytext>
</fullquery>

<fullquery name="get_categories">
    <querytext>
        select
                o.title,
                c.category_id
        from
                categories c,
                acs_objects o
        where
                o.object_id = c.category_id
                and c.tree_id in ([template::util::tcl_to_sql_list $tree_ids])
    </querytext>
</fullquery>

<fullquery name="get_total_offers">
    <querytext>
	select
		distinct
		oi.offer_id
	from
		iv_offer_itemsx oi,
		iv_offersx iv,
		category_object_map com,
		cr_items i,
		acs_rels rel,
		pm_projectsx p,
		cr_items i2
	where
		iv.item_id = i.item_id
		and oi.offer_id = iv.offer_id
		and oi.offer_id = i.latest_revision
		and oi.offer_item_id = com.object_id
		and rel.object_id_one = iv.item_id
		and rel.rel_type = 'application_data_link'
		and rel.object_id_two = p.item_id
		and p.item_id = i2.item_id
		and i2.latest_revision = p.project_id
		$extra_query
		[template::list::filter_where_clauses -and -name "reports"]
    </querytext>
</fullquery>

</queryset>