<?xml version="1.0"?>
<queryset>
	<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="currency_name">
      <querytext>
      
    select coalesce(cn.name, cc.default_name) as currency_name
    from cr_revisions r, cr_items i, iv_price_lists l, currencies cc
    left outer join currency_names cn on (cc.codeA = cn.codeA
					 and cn.language_code = :language)
    where r.revision_id = i.latest_revision
    and i.item_id = :list_id
    and l.list_id = r.revision_id
    and cc.codeA = l.currency
    
      </querytext>
</fullquery>

</queryset>
