<?xml version="1.0"?>
<queryset>

<fullquery name="offer_items">
    <querytext>
	select
		oi.offer_item_id,
		oi.title as item_title,
		cro.title as offer_title,
		oi.price_per_unit,
		oi.rebate,
		oi.item_units,
		com.category_id as cat_id,
		o.organization_id,
		org.name as org_name,
		to_char(oi.creation_date,'yy-mm-dd') as creation_date,
		to_char(oi.creation_date,'mm') as month,
		i.item_id,
		ob.title as cat_name
	from
		iv_offer_itemsx oi,
		iv_offers o,
		cr_revisions cro,
		organizations org,
		category_object_map com,
		cr_items i,
		acs_objects ob
	where
		o.offer_id = i.latest_revision
		and o.offer_id = oi.offer_id
		and cro.revision_id = o.offer_id
		and com.object_id = oi.offer_item_id
		and org.organization_id = o.organization_id
                and com.category_id = ob.object_id
		$category_filter_clause
		and [template::list::page_where_clause -name "offer_items"]	
 		[template::list::filter_where_clauses -and -name "offer_items"]
		[template::list::orderby_clause -orderby -name "offer_items"]
    </querytext>
</fullquery>

<fullquery name="offer_items_paginated">
    <querytext>
	select
		oi.offer_item_id
	from
		iv_offer_items oi,
		iv_offers o,
		cr_items i,
                category_object_map com,
                acs_objects ob
	where
		-- get latest revision from the offer
		o.offer_id = i.latest_revision
		and o.offer_id = oi.offer_id
                and com.object_id = oi.offer_item_id
                and com.category_id = ob.object_id
		$category_filter_clause 
		$project_pag_query
		[template::list::filter_where_clauses -and -name "offer_items"]
		[template::list::orderby_clause -orderby -name "offer_items"]
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

<fullquery name="get_amount_values">
    <querytext>
        select	
		price_per_unit,
		item_units,
		rebate
        from
		iv_offer_items oi,
		category_object_map com,
		iv_offers o,
		cr_items i
		
        where
		-- get latest revision from the offer
		o.offer_id = i.latest_revision
		and o.offer_id = oi.offer_id
                and com.object_id = oi.offer_item_id
		$project_pag_query
		and com.category_id = :c_id
		[template::list::filter_where_clauses -and -name "offer_items"]
    </querytext>
</fullquery>

</queryset>
    
