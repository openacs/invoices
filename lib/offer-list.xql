<?xml version="1.0"?>
<queryset>

<fullquery name="iv_offer">
      <querytext>
      
    select cr.item_id as offer_id, cr.title, cr.description,
           t.offer_nr, t.amount_total, t.amount_sum, t.currency,
	   p.first_names, p.last_name, o.creation_user,
	   to_char(o.creation_date, :timestamp_format) as creation_date,
	   to_char(t.accepted_date, :timestamp_format) as accepted_date,
	   to_char(t.finish_date, :timestamp_format) as finish_date
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_offers t,
         acs_objects o, persons p
    where cr.revision_id = ci.latest_revision
    and t.offer_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.offer_id
    and p.person_id = o.creation_user
    [template::list::filter_where_clauses -and -name iv_offer]
    [template::list::orderby_clause -name iv_offer -orderby]
    
      </querytext>
</fullquery>

<fullquery name="iv_offer_paginated">
      <querytext>
      
    select cr.item_id as offer_id
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_offers t,
         acs_objects o, persons p
    where cr.revision_id = ci.latest_revision
    and t.offer_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.offer_id
    and p.person_id = o.creation_user
    [template::list::filter_where_clauses -and -name iv_offer]
    [template::list::orderby_clause -name iv_offer -orderby]
    
      </querytext>
</fullquery>

</queryset>
    
