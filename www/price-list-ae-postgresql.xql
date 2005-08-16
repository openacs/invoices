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

</queryset>
