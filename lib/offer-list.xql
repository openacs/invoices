<?xml version="1.0"?>
<queryset>

<fullquery name="get_offer_status_id">
      <querytext>
      
	select status_id
	from pm_project_status
	where description = '#acs-translations.project_manager_status_offer#'
    
      </querytext>
</fullquery>

<fullquery name="iv_offer">
      <querytext>
      
    select cr.item_id as offer_id, cr.title, cr.description,
           t.offer_nr, t.amount_total, t.amount_sum, t.currency,
	   p.first_names, p.last_name, o.creation_user, t.comment,
	   to_char(o.creation_date, :timestamp_format) as creation_date,
	   to_char(t.accepted_date, :timestamp_format) as accepted_date,
	   to_char(t.finish_date, :timestamp_format) as finish_date,
           pi.item_id as project_id, pr.title as project_title
    from cr_folders cf, cr_revisions cr, iv_offers t,
         acs_objects o, persons p, cr_items ci, acs_rels r,
         cr_items pi, cr_revisions pr, pm_projects pp
    where cr.revision_id = ci.latest_revision
    and t.offer_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.offer_id
    and p.person_id = o.creation_user
    and r.object_id_one = ci.item_id
    and r.object_id_two = pi.item_id
    and pr.revision_id = pi.latest_revision
    and pp.project_id = pr.revision_id
    [template::list::filter_where_clauses -and -name iv_offer]
    [template::list::orderby_clause -name iv_offer -orderby]
    
      </querytext>
</fullquery>

<fullquery name="iv_offer_paginated">
      <querytext>
      
    select cr.item_id as offer_id
    from cr_folders cf, cr_revisions cr, iv_offers t,
         acs_objects o, persons p, cr_items ci, acs_rels r,
         cr_items pi, cr_revisions pr, pm_projects pp
    where cr.revision_id = ci.latest_revision
    and t.offer_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.offer_id
    and p.person_id = o.creation_user
    and r.object_id_one = ci.item_id
    and r.object_id_two = pi.item_id
    and pr.revision_id = pi.latest_revision
    and pp.project_id = pr.revision_id
    [template::list::filter_where_clauses -and -name iv_offer]
    [template::list::orderby_clause -name iv_offer -orderby]
    
      </querytext>
</fullquery>

</queryset>
