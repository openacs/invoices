<?xml version="1.0"?>
<queryset>

<fullquery name="iv_payment">
      <querytext>
      
    select cr.item_id as payment_id, cr.title
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_payments t
    where cr.revision_id = ci.latest_revision
    and t.payment_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    order by cr.title
    
      </querytext>
</fullquery>

</queryset>
    
