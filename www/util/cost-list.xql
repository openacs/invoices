<?xml version="1.0"?>
<queryset>

<fullquery name="iv_cost">
      <querytext>
      
    select cr.item_id as cost_id, cr.title
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_costs t
    where cr.revision_id = ci.latest_revision
    and t.cost_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    order by cr.title, cr.item_id
    
      </querytext>
</fullquery>

</queryset>
    
