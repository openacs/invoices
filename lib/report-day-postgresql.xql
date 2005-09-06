<?xml version="1.0"?>
<queryset>

<fullquery name="iv_invoice_days">
    <querytext>
	select
		to_char(iv.due_date, 'DD') as iv_day,
		r.description,
		r.title,
		i.item_id as invoice_nr,
		invoice_id
	from 
		iv_invoices iv,
		cr_revisions r,
		cr_items i,
		acs_objects o
	where 
		to_char(iv.due_date, 'YYYY') = :year
		and to_char(due_date, 'MM') = :month
		and r.revision_id = i.latest_revision
		and iv.invoice_id = r.revision_id
		and iv.organization_id = :organization_id
		and iv.recipient_id = o.object_id
		[template::list::filter_where_clauses -and -name iv_days]
		[template::list::orderby_clause -name iv_days -orderby]	
    </querytext>
</fullquery>

<fullquery name="get_iv_count">
    <querytext>
	select 
		count(invoice_id) 
	from 
		iv_invoices 
	where 
		to_char(due_date, 'MM') = :month
		and to_char(due_date, 'YYYY') = :year
		and organization_id = :organization_id
    </querytext>
</fullquery>

<fullquery name="get_iv_total_amount">
    <querytext>
	select 
		sum(total_amount)
	from 
		iv_invoices 
	where 
		invoice_id = :invoice_id
    </querytext>
</fullquery>

</queryset>
