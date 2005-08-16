<?xml version="1.0"?>

<queryset>

<fullquery name="iv::price_list::get_currency.check_customer_price_list">
      <querytext>
      
	select l.currency
	from acs_objects o, acs_rels r, iv_price_lists l, cr_items li
	where o.object_id = l.list_id
	and o.package_id = :package_id
	and l.list_id = li.latest_revision
	and r.object_id_one = li.item_id
	and r.object_id_two = :organization_id
	and r.rel_type = 'application_data_link'
	
      </querytext>
</fullquery>

<fullquery name="iv::price_list::get_currency.check_default_price_list">
      <querytext>
      
	select l.currency
	from acs_objects o, iv_price_lists l, cr_items li
	where o.object_id = l.list_id
	and o.package_id = :package_id
	and l.list_id = li.latest_revision
	and not exists (select 1
		       from acs_rels r, acs_objects o
		       where r.object_id_one = li.item_id
		       and r.object_id_two = o.object_id
		       and r.rel_type = 'application_data_link'
		       and o.object_type = 'organization')
	
      </querytext>
</fullquery>

<fullquery name="iv::price_list::get_list_id.check_customer_price_list">
      <querytext>
      
	select li.item_id as list_id
	from acs_objects o, acs_rels r, iv_price_lists l, cr_items li
	where o.object_id = l.list_id
	and o.package_id = :package_id
	and l.list_id = li.latest_revision
	and r.object_id_one = li.item_id
	and r.object_id_two = :organization_id
	and r.rel_type = 'application_data_link'
	
      </querytext>
</fullquery>

<fullquery name="iv::price_list::get_list_id.check_default_price_list">
      <querytext>
      
	select li.item_id as list_id
	from acs_objects o, iv_price_lists l, cr_items li
	where o.object_id = l.list_id
	and o.package_id = :package_id
	and l.list_id = li.latest_revision
	and not exists (select 1
		       from acs_rels r, acs_objects o
		       where r.object_id_one = li.item_id
		       and r.object_id_two = o.object_id
		       and r.rel_type = 'application_data_link'
		       and o.object_type = 'organization')
	
      </querytext>
</fullquery>

</queryset>
