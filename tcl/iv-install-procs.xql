<?xml version="1.0"?>

<queryset>

<fullquery name="iv::install::after_upgrade.update_default_objects">
      <querytext>
      
			update iv_default_objects
			set offer_id = :offer_id,
		        offer_item_id = :offer_item_id
			where package_id = :package_id
	
      </querytext>
</fullquery>

</queryset>
