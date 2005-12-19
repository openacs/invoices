<?xml version="1.0"?>
<queryset>

<fullquery name="offer_data">
      <querytext>

    select o.organization_id, o.status
    from iv_offers o, cr_items oi
    where oi.latest_revision = o.offer_id
    and oi.item_id = :offer_id

      </querytext>
</fullquery>

</queryset>
