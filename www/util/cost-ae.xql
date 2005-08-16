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

	select t.cost_id as cost_rev_id, r.title, r.description,
	       t.cost_nr, t.organization_id, t.cost_object_id,
	       t.item_units, t.price_per_unit, t.currency,
	       t.apply_vat_p, t.variable_cost_p
	from iv_costs t, cr_revisions r, cr_items i
	where r.revision_id = t.cost_id
	and i.latest_revision = r.revision_id
	and i.item_id = :cost_id

      </querytext>
</fullquery>

</queryset>
    
