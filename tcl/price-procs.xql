<?xml version="1.0"?>

<queryset>

<fullquery name="iv::price::get.check_customer_price">
      <querytext>
      
	select p.amount, l.currency
	from iv_prices p, cr_items pi, acs_objects o, acs_data_links r,
	     iv_price_lists l, cr_items li, category_object_map cm
	where p.price_id = pi.latest_revision
	and cm.category_id = p.category_id
	and cm.object_id = :object_id
	and o.object_id = p.price_id
	and o.package_id = :package_id
	and p.list_id = li.item_id
	and l.list_id = li.latest_revision
	and r.object_id_one = li.item_id
	and r.object_id_two = :organization_id
	
      </querytext>
</fullquery>

<fullquery name="iv::price::get.check_default_price">
      <querytext>
      
	select p.amount, l.currency
	from iv_prices p, cr_items pi, acs_objects o, iv_price_lists l,
	     category_object_map cm, cr_items li
	where p.price_id = pi.latest_revision
	and cm.category_id = p.category_id
	and cm.object_id = :object_id
	and o.object_id = p.price_id
	and o.package_id = :package_id
	and p.list_id = li.item_id
	and l.list_id = li.latest_revision
	and not exists (select 1
		       from acs_data_links r, acs_objects o
		       where r.object_id_one = li.item_id
		       and r.object_id_two = o.object_id
		       and o.object_type = 'organization')
	
      </querytext>
</fullquery>

</queryset>
