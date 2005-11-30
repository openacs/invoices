<?xml version="1.0"?>
<queryset>

<fullquery name="check_offer_id">
      <querytext>

    select i.item_id as offer_id, o.offer_id as offer_rev_id
    from iv_offers o, cr_items i
    where i.live_revision = o.offer_id
    and o.offer_id = :offer_id

      </querytext>
</fullquery>

</queryset>
