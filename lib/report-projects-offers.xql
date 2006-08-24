<?xml version="1.0"?>
<queryset>

<fullquery name="main_projects">
    <querytext>
	select 
		p.project_id,
		i.item_id,
		cr.title,
		p.latest_finish_date,
		p.customer_id,
		org.name as customer_name
	from
		pm_projects p, cr_revisions cr, cr_items i, cr_items i2, organizations org
	where 
		p.project_id = i.latest_revision
		and p.project_id = cr.revision_id
		$date_range_clause
		and i.parent_id = i2.item_id
		and i2.content_type = 'content_folder'
		and p.customer_id = org.organization_id
	order by
		latest_finish_date
    </querytext>
</fullquery>

<fullquery name="get_project_amount_values">
    <querytext>
        select  
		amount_total
        from
                iv_offers o,
          	cr_items i,
		acs_data_links r,
		cr_items i2
                
        where
                o.offer_id = i.latest_revision
		and r.object_id_one = i.item_id
		and r.object_id_two = i2.item_id
		and i2.item_id = :project_item_id
    </querytext>
</fullquery>         

</queryset>
