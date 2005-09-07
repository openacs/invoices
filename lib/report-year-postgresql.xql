<?xml version="1.0"?>
<queryset>

<fullquery name="iv_invoice_years">
    <querytext>
	select
		distinct to_char(iv.due_date, 'YYYY') as iv_year
	from 
		iv_invoices iv,
		acs_objects o
	where 
		iv.due_date > now() - '$last_years years' :: interval
		and iv.recipient_id = o.object_id
		$extra_query
		[template::list::filter_where_clauses -and -name iv_years]
    </querytext>
</fullquery>

<fullquery name="get_iv_total_amount">
    <querytext>
	select
		sum(total_amount) 
	from 
		iv_invoices 
	where 
		to_char(due_date, 'YYYY') = :iv_year
		$extra_query
    </querytext>
</fullquery>

<fullquery name="get_iv_count">
    <querytext>
	select 
		count(invoice_id) 
	from 
		iv_invoices 
	where 
		to_char(due_date, 'YYYY') = :iv_year
		$extra_query
    </querytext>
</fullquery>
</queryset>
