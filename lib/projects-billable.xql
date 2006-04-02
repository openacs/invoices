<?xml version="1.0"?>
<queryset>

<fullquery name="projects_to_bill">
    <querytext>
	select 
		r.item_id as project_id, 
		r.title, 
		r.description, 
		sub.amount_open,
           	sub.creation_date,  
		total.count_total, 
		billed.count_billed, 
		name, 
		sub.recipient_id,
		sub.customer_id as org_id
    	from (
    		select 
			oi.item_id as offer_id, 
			pr.revision_id, 
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
         		acs_objects oo, 
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
    			and oo.object_id = oi.item_id
    			and oo.package_id = :package_id
    			and p.customer_id = oz.organization_id		
    			and not exists (select 1
                    			from iv_invoice_items ii, iv_invoices i, cr_items ci
                    			where ii.offer_item_id = ofi.offer_item_id
                    			and i.invoice_id = ii.invoice_id
                    			and ci.latest_revision = i.invoice_id
                    			and i.cancelled_p = 'f')
    		group by 
			oi.item_id, pr.revision_id, o.creation_date, p.customer_id, oz.name, p.recipient_id
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
    	    ) billed, 
		cr_revisions r
    	where 
		r.revision_id = sub.revision_id
		and total.item_id = sub.offer_id
    		and billed.item_id = sub.offer_id
    		[template::list::filter_where_clauses -and -name projects]	
    		[template::list::orderby_clause -name projects -orderby]
      </querytext>
</fullquery>

</queryset>
