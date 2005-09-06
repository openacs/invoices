<?xml version="1.0"?>
<queryset>

<fullquery name="iv_invoice_months">
    <querytext>
	select
		distinct to_char(iv.due_date, 'MM') as iv_month
	from 
		iv_invoices iv,
		acs_objects o
	where 
		to_char(iv.due_date, 'YYYY') = :year
		and iv.organization_id = :organization_id
		and iv.recipient_id = o.object_id
		[template::list::filter_where_clauses -and -name iv_months]
    </querytext>
</fullquery>

<fullquery name="get_iv_count">
    <querytext>
	select 
		count(invoice_id) 
	from 
		iv_invoices
	where 
		to_char(due_date, 'YYYY') = :year
		and to_char(due_date, 'MM') = :iv_month
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
		to_char(due_date, 'YYYY') = :year
		and to_char(due_date, 'MM') = :iv_month
    </querytext>
</fullquery>

</queryset>
