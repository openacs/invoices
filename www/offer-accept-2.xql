<?xml version="1.0"?>
<queryset>

<fullquery name="offer_data">
      <querytext>

    select o.offer_nr, o.organization_id
    from iv_offers o, cr_items oi
    where oi.latest_revision = o.offer_id
    and oi.item_id = :offer_id

      </querytext>
</fullquery>

</queryset>
