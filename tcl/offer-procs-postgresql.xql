<?xml version="1.0"?>

<queryset>
	<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="iv::offer::accept.accept">
      <querytext>
      
	update iv_offers
	set accepted_date = now(),
            status = 'accepted'
	where offer_id = (select latest_revision
			  from cr_items
			  where item_id = :offer_id)
	
      </querytext>
</fullquery>

</queryset>
