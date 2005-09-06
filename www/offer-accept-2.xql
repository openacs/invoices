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

<fullquery name="project_data">
      <querytext>

    select p.title as project_title, p.project_code
    from pm_projectsx p, cr_items oi
    where oi.latest_revision = p.project_id
    and oi.item_id = :project_id
    

      </querytext>
</fullquery>

</queryset>
