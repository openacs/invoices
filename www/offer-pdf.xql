<?xml version="1.0"?>
<queryset>

<fullquery name="offer_data">
      <querytext>

    select o.organization_id, o.status, o.offer_nr
    from iv_offers o, cr_items oi
    where oi.latest_revision = o.offer_id
    and oi.item_id = :offer_id

      </querytext>
</fullquery>

<fullquery name="project_data">
      <querytext>

    select p.contact_id
    from pm_projectsx p, cr_items pi
    where pi.latest_revision = p.project_id
    and pi.item_id = :project_id

      </querytext>
</fullquery>

<fullquery name="set_publish_status">
      <querytext>

    update cr_items
    set publish_status = 'live'
    where item_id = :file_item_id

      </querytext>
</fullquery>

<fullquery name="set_context_id">
      <querytext>

    update acs_objects
    set context_id = :offer_folder_id
    where object_id = :file_item_id

      </querytext>
</fullquery>

</queryset>
