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
		o.item_id
	from
		iv_offer_itemsx oi,
		iv_offersx o,
		cr_items i
	where
		i.item_id = o.item_id
		and o.offer_id = i.latest_revision
		and o.offer_id = oi.offer_id
		and [template::list::page_where_clause -name "offer_items"]	
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

</queryset>
    
