!<?xml version="1.0"?>
<queryset>

<fullquery name="iv_pricelist_list">
      <querytext>

    select cr.item_id as list_id, cr.title
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_price_lists t
    where cr.revision_id = ci.latest_revision
    and t.list_id = cr.revision_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    order by cr.title

      </querytext>
</fullquery>

<fullquery name="iv_delete_application_data_link">
    <querytext>
	    delete from acs_data_links
	    where (
	          (object_id_one = :object_id1
		   and object_id_two = :object_id2)
              or (object_id_one = :object_id2
                   and object_id_two = :object_id1)
                 )  
    </querytext>
</fullquery>

</queryset>
