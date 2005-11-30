<?xml version="1.0"?>
<queryset>

<fullquery name="all_prices">
      <querytext>

    select p.category_id, p.amount
    from iv_prices p, cr_items i
    where p.list_id = :list_id
    and p.price_id = i.latest_revision

      </querytext>
</fullquery>

<fullquery name="old_prices">
      <querytext>

	    select price_id, item_id, category_id
	    from iv_pricesi
	    where list_id = :list_id

      </querytext>
</fullquery>

<fullquery name="invalidate_prices">
      <querytext>

	    update cr_items
	    set latest_revision = null,
	        live_revision = null
	    where item_id in (select item_id
			      from iv_pricesi
			      where list_id = :list_id)

      </querytext>
</fullquery>

</queryset>
