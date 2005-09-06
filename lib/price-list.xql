<?xml version="1.0"?>
<queryset>

<fullquery name="currency">
      <querytext>
      
    select l.currency
    from cr_items i, iv_price_lists l
    where l.list_id = i.latest_revision
    and i.item_id = :list_id
    
      </querytext>
</fullquery>

<fullquery name="all_prices">
      <querytext>

    select p.category_id, p.amount
    from iv_prices p, cr_items i
    where p.list_id = :list_id
    and p.price_id = i.latest_revision

      </querytext>
</fullquery>

</queryset>
