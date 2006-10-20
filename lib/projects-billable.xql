<?xml version="1.0"?>
<queryset>

--
-- +++ READ THIS +++
--
-- Sept. 2006 cognovis/nfl
-- projects_to_bill changed (and only that one!)
-- now it's getting the information about the sum from iv_offers.amount_open
-- instead of summing iv_offer_items
-- so there is no support if more items will be added and amount_open won't be updated
-- and there is no support for credit advices (Gutschriften)
--

<fullquery name="projects_to_bill">
    <querytext>
	select 
		sub.project_id, 
		sub.title, 
		sub.description, 
		sub.amount_open,
           	sub.creation_date,  
		sub.name,
		lower(name) as name2, 
		sub.recipient_id,
		sub.customer_id as org_id
	from (select 
			oi.item_id as offer_id,
                        pi.item_id as project_id,
                        pr.title,
                        pr.description,
			o.creation_date,
	   		-- sum(ofi.item_units * ofi.price_per_unit * (1-(ofi.rebate/100))) as amount_open_old,
			io.amount_total as amount_open,
           		p.customer_id, 
			p.recipient_id,
			oz.name
	    	from 
			cr_items pi, 
			cr_revisions pr, 
			pm_projects p,
         		acs_objects o, 
			acs_data_links r, 
			-- iv_offer_items ofi,
			cr_items oi, 
			organizations oz,
			iv_offers io
    		where 
			pi.latest_revision = pr.revision_id
    			and p.project_id = pr.revision_id
    			and o.object_id = p.project_id
			and r.object_id_one = pi.item_id
    			and r.object_id_two = oi.item_id
	 	  	and p.status_id = :p_closed_id
	 	  	and p.invoice_p = true
    			-- and ofi.offer_id = oi.latest_revision
    			and p.customer_id = oz.organization_id
			and io.offer_id = oi.latest_revision
    		group by 
			oi.item_id, pi.item_id, pr.title, pr.description, o.creation_date, p.customer_id, oz.name, p.recipient_id, io.amount_total) sub
		where	1=1 [template::list::filter_where_clauses -and -name projects]	
    			[template::list::page_where_clause -and -name projects -key sub.project_id]
    		[template::list::orderby_clause -name projects -orderby]
      </querytext>
</fullquery>

<fullquery name="projects_to_bill2">
    <querytext>
	select 
		sub.project_id, 
		sub.title, 
		sub.description, 
		sub.amount_open,
           	sub.creation_date,  
		total.count_total, 
		billed.count_billed, 
		sub.name,
		lower(name) as name2, 
		sub.recipient_id,
		sub.customer_id as org_id
    	from (
    		select 
			oi.item_id as offer_id,
                        pi.item_id as project_id,
                        pr.title,
                        pr.description,
			o.creation_date,
	   		sum(ofi.item_units * ofi.price_per_unit * (1-(ofi.rebate/100))) as amount_open,
           		p.customer_id, 
			p.recipient_id,
			oz.name
	    	from 
			cr_items pi, 
			cr_revisions pr, 
			pm_projects p,
         		acs_objects o, 
			acs_data_links r, 
			iv_offer_items ofi,
			cr_items oi, 
			organizations oz
    		where 
			pi.latest_revision = pr.revision_id
    			and p.project_id = pr.revision_id
    			and o.object_id = p.project_id
			and r.object_id_one = pi.item_id
    			and r.object_id_two = oi.item_id
	 	  	and p.status_id = :p_closed_id
	 	  	and p.invoice_p = true
    			and ofi.offer_id = oi.latest_revision
    			and p.customer_id = oz.organization_id
    		group by 
			oi.item_id, pi.item_id, pr.title, pr.description, o.creation_date, p.customer_id, oz.name, p.recipient_id
	    ) sub, 
	    (
    		select 
			count(*) as count_total, oi.item_id
		from 	
			cr_items oi, iv_offer_items ofi
    		where 
			ofi.offer_id = oi.latest_revision
    		group by 
			oi.item_id
    	    ) total, 
	    (
    		select 
			count(ci.item_id) as count_billed, oi.item_id
    		from 
			cr_items oi, iv_offer_items ofi
    			left outer join iv_invoice_items ii
    			on (ii.offer_item_id = ofi.offer_item_id)
    			left outer join iv_invoices i
    			on (ii.invoice_id = i.invoice_id and i.cancelled_p = 'f')
    			left outer join cr_items ci
    			on (ci.latest_revision = i.invoice_id)
    		where 
			ofi.offer_id = oi.latest_revision
    		group by
			oi.item_id
    	    ) billed
    	where 
		total.item_id = sub.offer_id
    		and billed.item_id = sub.offer_id
    		[template::list::filter_where_clauses -and -name projects]	
    		[template::list::page_where_clause -and -name projects -key sub.project_id]
    		[template::list::orderby_clause -name projects -orderby]
      </querytext>
</fullquery>

<fullquery name="projects_to_bill_paginated">
    <querytext>
	select 
		sub.project_id
    	from (
    		select 
                        pi.item_id as project_id,
                        pr.title,
                        pr.description,
			o.creation_date,
           		p.customer_id, 
			p.recipient_id,
			oz.name
	    	from 
			cr_items pi, 
			cr_revisions pr, 
			pm_projects p,
         		acs_objects o, 
			acs_data_links r, 
			cr_items oi,
			iv_offer_items ofi,
			organizations oz
    		where 
			pi.latest_revision = pr.revision_id
    			and p.project_id = pr.revision_id
    			and o.object_id = p.project_id
			and r.object_id_one = pi.item_id
    			and r.object_id_two = oi.item_id
	 	  	and p.status_id = :p_closed_id
	 	  	and p.invoice_p = true
    			and ofi.offer_id = oi.latest_revision
    			and p.customer_id = oz.organization_id		
    			and ofi.offer_item_id not in  (select ii.offer_item_id
                    			from iv_invoice_items ii, iv_invoices i, cr_items ci
                    			where i.invoice_id = ii.invoice_id
                    			and ci.latest_revision = i.invoice_id
                    			and i.cancelled_p = 'f')
    		group by 
			pi.item_id, pr.title, pr.description, o.creation_date, p.customer_id, oz.name, p.recipient_id
	    ) sub
    	where 1=1
    		[template::list::filter_where_clauses -and -name projects]	
    		[template::list::orderby_clause -name projects -orderby]
      </querytext>
</fullquery>

</queryset>
