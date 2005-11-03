<?xml version="1.0"?>
<queryset>

<fullquery name="offer_items">
    <querytext>
	select
		oi.offer_item_id,
		oi.title as item_title,
		o.title as offer_title,
		oi.price_per_unit,
		oi.rebate,
		oi.item_units,
		com.category_id,
		o.organization_id,
		to_char(oi.creation_date,'yy-mm-dd') as creation_date,
		to_char(oi.creation_date,'mm') as month,
		o.item_id
	from
		iv_offer_itemsx oi,
		iv_offersx o,
		category_object_map com,
		cr_items i
	where
		i.item_id = o.item_id
		and o.offer_id = i.latest_revision
		and o.offer_id = oi.offer_id
		and com.object_id = oi.offer_item_id
		$category_filter_clause
		and [template::list::page_where_clause -name "offer_items"]	
		[template::list::filter_where_clauses -and -name "offer_items"]
		[template::list::orderby_clause -orderby -name "offer_items"]
    </querytext>
</fullquery>

<fullquery name="offer_items_paginated">
    <querytext>
	select
		offer_item_id,
		title as item_title,
		revision_id as offer_title,
		price_per_unit,
		rebate,
		item_units
	from
		iv_offer_itemsx
    </querytext>
</fullquery>

<fullquery name="get_categories">
    <querytext>
	select
    		distinct
   		o.title,
    		com.category_id
    	from
    		category_object_map com,
    		iv_offer_items io,
    		acs_objects o
    	where 
    		com.object_id = io.offer_item_id
    		and com.category_id = o.object_id
		$category_filter_clause
	order by 
		o.title asc
    </querytext>
</fullquery>

</queryset>
    
