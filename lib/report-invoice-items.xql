<?xml version="1.0"?>
<queryset>

<fullquery name="get_iv_items">
    <querytext>
	select
		ii.iv_item_id,
		ii.title as item_title,
		to_char(ii.creation_date, 'YYYY-MM-DD') as creation_date,
		ii.amount_total,
		ii.offer_item_id,	
		com.category_id
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		category_object_map com,
		cr_items i
	where
		iv.item_id = i.item_id
		and ii.invoice_id = iv.invoice_id
		and ii.invoice_id = i.latest_revision
		and ii.offer_item_id = com.object_id
		$extra_query
		[template::list::filter_where_clauses -and -name "reports"]
    </querytext>
</fullquery>

<fullquery name="get_final_amount">
    <querytext>
	select
		sum(ii.amount_total)
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		category_object_map com,
		cr_items i
	where
		iv.item_id = i.item_id
		and ii.invoice_id = iv.invoice_id
		and ii.invoice_id = i.latest_revision
		and ii.offer_item_id = com.object_id
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

</queryset>