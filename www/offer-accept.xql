<?xml version="1.0"?>
<queryset>

<fullquery name="title">
      <querytext>

	select r.title
	from cr_revisions r, cr_items i
	where i.latest_revision = r.revision_id
	and i.item_id = :offer_id

      </querytext>
</fullquery>

</queryset>
