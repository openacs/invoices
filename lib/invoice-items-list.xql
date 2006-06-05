<?xml version="1.0"?>
<queryset>

<fullquery name="iv_items">
    <querytext>
	select
		ii.iv_item_id,
		ii.title as item_title,
		iv.title as invoice_title,
		ii.rebate,
		ii.amount_total as final_amount,
		com.category_id as cat_id,
		iv.organization_id,
		to_char(ii.creation_date,'yy-mm-dd') as creation_date,
		to_char(ii.creation_date,'mm') as month,
		ii.offer_item_id,
		iv.organization_id,
		org.name as org_name,
		ob.title as cat_name,
		i.item_id
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		category_object_map com,
		cr_items i,
		organizations org,
		acs_objects ob
	where
		iv.item_id = i.item_id
		and ii.invoice_id = i.latest_revision
		and iv.invoice_id = ii.invoice_id
		and com.object_id = ii.offer_item_id
		and org.organization_id = iv.organization_id
		and ob.object_id = com.category_id
		$category_filter_clause
		and [template::list::page_where_clause -name "iv_items"]	
		[template::list::filter_where_clauses -and -name "iv_items"]
		[template::list::orderby_clause -orderby -name "iv_items"]
    </querytext>
</fullquery>

<fullquery name="iv_items_paginated">
    <querytext>
	select
		ii.iv_item_id
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		category_object_map com,
		cr_items i,
		organizations org,
		acs_objects ob
	where
		iv.item_id = i.item_id
		and ii.invoice_id = i.latest_revision
		and iv.invoice_id = ii.invoice_id
		and com.object_id = ii.offer_item_id
		and org.organization_id = iv.organization_id
		and ob.object_id = com.category_id
		$category_filter_clause
		[template::list::filter_where_clauses -and -name "iv_items"]
		[template::list::orderby_clause -orderby -name "iv_items"]
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

<fullquery name="get_amount">
    <querytext>
	select 
		sum(ii.amount_total)
	from
		iv_invoicesx iv,
		iv_invoice_itemsx ii,
		cr_items i,
		category_object_map com
	where
		iv.item_id = i.item_id
		and ii.invoice_id = i.latest_revision
		and iv.invoice_id = ii.invoice_id
		and ii.offer_item_id = com.object_id
		and com.category_id = :c_id
		[template::list::filter_where_clauses -and -name "iv_items"]
    </querytext>
</fullquery>


</queryset>
    
