<?xml version="1.0"?>

<queryset>

<fullquery name="iv::util::get_default_objects_not_cached.default_object">
      <querytext>
      
	select list_id, price_id, cost_id, offer_id, offer_item_id, offer_item_title_id,
	       invoice_id, invoice_item_id, payment_id
	from iv_default_objects
	where package_id = :package_id
	
      </querytext>
</fullquery>

<fullquery name="iv::util::set_default_objects.set_default_objects">
      <querytext>
      
	insert into iv_default_objects
	(package_id, list_id, price_id, cost_id, offer_id, offer_item_title_id,
	 offer_item_id, invoice_id, invoice_item_id, payment_id)
	values
	(:package_id, :list_id, :price_id, :cost_id, :offer_id, :offer_item_title_id,
	 :offer_item_id, :invoice_id, :invoice_item_id, :payment_id)
	
      </querytext>
</fullquery>

<fullquery name="iv::util::get_x_field.get_offer_creator_data">
      <querytext>
      
	select u.password as user_password, u.salt as user_salt
	from users u, acs_objects o
	where u.user_id = o.creation_user
	and o.object_id = :offer_id
	
      </querytext>
</fullquery>

</queryset>
