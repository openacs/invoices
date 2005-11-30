<?xml version="1.0"?>
<queryset>

<fullquery name="credit_recipients">
      <querytext>

	select p.first_names || ' ' || p.last_name, p.person_id
	from persons p, acs_rels r
	where r.object_id_one = p.person_id
	and r.object_id_two = :organization_id
	and r.rel_type = 'contact_rels_ir'
	order by lower(p.last_name), lower(p.first_names)

      </querytext>
</fullquery>

</queryset>
