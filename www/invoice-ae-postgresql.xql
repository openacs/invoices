<?xml version="1.0"?>
<queryset>
	<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="currencies">
      <querytext>
      
    select cc.curname, cc.codeA
    from (select coalesce(n.name, c.default_name) as curname, c.codeA
	  from currencies c
	  left outer join currency_names n
	  on (c.codeA = n.codeA
	      and language_code = :language)) cc
    order by lower(cc.curname)
    
      </querytext>
</fullquery>

<fullquery name="get_open_rebate">
      <querytext>
      
	select sum(o.amount_sum - o.amount_total) as open_rebate
	from iv_offers o, acs_rels r, cr_items co
	where r.object_id_one in ([join $project_id ,])
	and r.object_id_two = co.item_id
	and r.rel_type = 'application_data_link'
	and co.latest_revision = o.offer_id
    
      </querytext>
</fullquery>

<fullquery name="get_given_rebate">
      <querytext>
      
	select i.invoice_id, i.amount_sum - i.total_amount as given_rebate
	from acs_rels r, cr_items co, iv_offer_items oi,
	     iv_invoice_items ii, iv_invoices i, cr_items ci
	where i.invoice_id <> :invoice_rev_id
	and i.parent_invoice_id is null
	and ci.latest_revision = i.invoice_id
	and i.invoice_id in (select ii.invoice_id
	                     from iv_invoice_items ii, iv_offer_items oi,
	                          cr_items co, acs_rels r
	                     where oi.offer_id = co.latest_revision
	                     and r.object_id_one in ([join $project_id ,])
	                     and r.object_id_two = co.item_id
	                     and r.rel_type = 'application_data_link'
	                     and oi.offer_item_id = ii.offer_item_id)

      </querytext>
</fullquery>

<fullquery name="today">
      <querytext>
      
      select to_char(now(),'YYYY-MM-DD') from dual
    
      </querytext>
</fullquery>

</queryset>
