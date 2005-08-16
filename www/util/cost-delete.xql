<?xml version="1.0"?>
<queryset>

<fullquery name="title">
      <querytext>

	select r.title
	from cr_revisions r, cr_items i
	where i.latest_revision = r.revision_id
	and i.item_id = :cost_id

      </querytext>
</fullquery>

<fullquery name="mark_deleted">
      <querytext>

	update cr_items
	set latest_revision = null,
	    live_revision = null
	where item_id = :cost_id

      </querytext>
</fullquery>

</queryset>
    
