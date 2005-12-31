<?xml version="1.0"?>
<queryset>

<fullquery name="offer_data">
      <querytext>

    select o.offer_nr, o.organization_id, o.accepted_date, oi.latest_revision as offer_rev_id
    from iv_offers o, cr_items oi
    where oi.latest_revision = o.offer_id
    and oi.item_id = :offer_id

      </querytext>
</fullquery>

<fullquery name="project_data">
      <querytext>

    select p.title as project_title, p.project_code, contact_id
    from pm_projectsx p, cr_items oi
    where oi.latest_revision = p.project_id
    and oi.item_id = :project_id

      </querytext>
</fullquery>

<fullquery name="set_publish_status">
      <querytext>

    update cr_items
    set publish_status = 'expired'
    where item_id = :file_ids

      </querytext>
</fullquery>

</queryset>
