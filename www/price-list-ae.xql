<?xml version="1.0"?>
<queryset>

<fullquery name="organization_list">
      <querytext>

    select o.name, o.organization_id
    from organizations o
    order by o.name

      </querytext>
</fullquery>

<fullquery name="get_data">
      <querytext>

	select r.title, r.description, t.list_id as list_rev_id,
	       t.currency
	from iv_price_lists t, cr_revisions r, cr_items i
	where r.revision_id = t.list_id
	and i.latest_revision = r.revision_id
	and i.item_id = :list_id

      </querytext>
</fullquery>

<fullquery name="new_list_id">
      <querytext>

	    select item_id as new_list_id
	    from cr_revisions
	    where revision_id = :new_list_rev_id

      </querytext>
</fullquery>

</queryset>
