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

</queryset>
