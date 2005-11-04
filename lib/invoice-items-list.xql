<?xml version="1.0"?>
<queryset>

<fullquery name="iv_items">
    <querytext>
	select
		ii.iv_item_id,
		ii.title as item_title,
		iv.title as invoice_title,
		ii.price_per_unit,
		ii.rebate,
		ii.item_units,
		com.category_id,
		iv.organization_id,
		to_char(ii.creation_date,'yy-mm-dd') as creation_date,
		to_char(ii.creation_date,'mm') as month,
		ii.offer_item_id,
		i.item_id
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		category_object_map com,
		cr_items i
	where
		iv.item_id = i.item_id
		and ii.invoice_id = i.latest_revision
		and iv.invoice_id = ii.invoice_id
		and com.object_id = ii.offer_item_id
		$category_filter_clause
		and [template::list::page_where_clause -name "iv_items"]	
		[template::list::filter_where_clauses -and -name "iv_items"]
		[template::list::orderby_clause -orderby -name "iv_items"]
    </querytext>
</fullquery>

<fullquery name="iv_items_paginated">
    <querytext>
	select
		iv_item_id,
		title as item_title,
		price_per_unit,
		rebate,
		item_units
	from
		iv_invoice_itemsx
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
    		iv_invoice_items ii,
    		acs_objects o
    	where 
    		com.object_id = ii.offer_item_id
    		and com.category_id = o.object_id
		$category_filter_clause
	order by 
		o.title asc
    </querytext>
</fullquery>

<fullquery name="get_offer_item_id">
    <querytext>
	select 
		o.item_id
	from 
		iv_offersx o,
		iv_offer_items oi
	where
		oi.offer_item_id = :offer_item_id
		and oi.offer_id = o.offer_id
    </querytext>
</fullquery>

</queryset>
    
