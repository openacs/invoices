<?xml version="1.0"?>
<queryset>

<fullquery name="offer_data">
      <querytext>

    select o.offer_nr, o.organization_id, o.accepted_date, oi.live_revision as offer_rev_id
    from iv_offers o, cr_items oi
    where oi.latest_revision = o.offer_id
    and oi.item_id = :offer_id

      </querytext>
</fullquery>

<fullquery name="get_files">
      <querytext>

      select max(item_id) as file_ids
      from cr_items ci
      where parent_id = :offer_id
      and ci.storage_type = 'file'
      </querytext>
</fullquery>

</queryset>
