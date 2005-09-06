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

<fullquery name="today">
      <querytext>
      
      select to_char(now(),'YYYY-MM-DD') from dual
    
      </querytext>
</fullquery>

<fullquery name="set_finish_date">
      <querytext>
      
	    update iv_offers
	    set finish_date = to_timestamp(:finish_date_list,'YYYY MM DD HH24 MI SS')
	    where offer_id = :new_offer_rev_id
    
      </querytext>
</fullquery>

<fullquery name="set_accepted_date">
      <querytext>
      
	    update iv_offers
	    set accepted_date = now()
	    where offer_id = :new_offer_rev_id
	    and accepted_date is null
    
      </querytext>
</fullquery>

<fullquery name="set_project_deadline">
      <querytext>
      
		update pm_projects
		set planned_end_date = to_timestamp(:finish_date_list,'YYYY MM DD HH24 MI SS')
		where project_id = :project_rev_id
    
      </querytext>
</fullquery>

</queryset>
