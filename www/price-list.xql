<?xml version="1.0"?>
<queryset>

<fullquery name="list_title">
      <querytext>

    select r.title as list_title
    from cr_revisions r, cr_items i
    where r.revision_id = i.latest_revision
    and i.item_id = :list_id

      </querytext>
</fullquery>

</queryset>
