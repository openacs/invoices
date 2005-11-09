<?xml version="1.0"?>
<queryset>

<fullquery name="get_iv_items">
    <querytext>
	select
		ii.iv_item_id,
		ii.title as item_title,
		to_char(ii.creation_date, 'YYYY-MM-DD') as creation_date,
		ii.amount_total
	from
		iv_invoice_itemsx ii,
		iv_invoicesx iv,
		cr_items i
	where
		iv.item_id = i.item_id
		and ii.invoice_id = iv.invoice_id
		and ii.invoice_id = i.latest_revision
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
		cr_items i
	where
		iv.item_id = i.item_id
		and ii.invoice_id = iv.invoice_id
		and ii.invoice_id = i.latest_revision
		$extra_query
    </querytext>
</fullquery>

</queryset>