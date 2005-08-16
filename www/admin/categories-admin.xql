<?xml version="1.0"?>

<queryset>

<fullquery name="get_category_node_id">
      <querytext>
      
	    select n.node_id
	    from site_nodes n, site_nodes top, apm_packages p
	    where top.parent_id is null
	    and n.parent_id = top.node_id
	    and p.package_id = n.object_id
	    and p.package_key = 'categories'
	
      </querytext>
</fullquery>

</queryset>
    
