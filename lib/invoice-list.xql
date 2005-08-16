<?xml version="1.0"?>
<queryset>

<fullquery name="iv_invoice">
      <querytext>
      
    select cr.item_id as invoice_id, cr.title, cr.description,
           t.invoice_nr, t.total_amount, t.currency, t.paid_amount,
	   t.paid_currency, p.first_names, p.last_name, o.creation_user,
	   to_char(o.creation_date, :timestamp_format) as creation_date,
	   to_char(t.due_date, :date_format) as due_date, t.parent_invoice_id,
           t.invoice_id as invoice_rev_id, t.cancelled_p
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_invoices t,
         acs_objects o, persons p
    where cr.revision_id = ci.latest_revision
    and t.invoice_id = cr.revision_id
    and t.organization_id = :organization_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.invoice_id
    and p.person_id = o.creation_user
    [template::list::filter_where_clauses -and -name iv_invoice]
    [template::list::orderby_clause -name iv_invoice -orderby]
    
      </querytext>
</fullquery>

<fullquery name="iv_invoice_paginated">
      <querytext>
      
    select cr.item_id as invoice_id
    from cr_folders cf, cr_items ci, cr_revisions cr, iv_invoices t,
         acs_objects o, persons p
    where cr.revision_id = ci.latest_revision
    and t.invoice_id = cr.revision_id
    and t.organization_id = :organization_id
    and ci.parent_id = cf.folder_id
    and cf.package_id = :package_id
    and o.object_id = t.invoice_id
    and p.person_id = o.creation_user
    [template::list::filter_where_clauses -and -name iv_invoice]
    [template::list::orderby_clause -name iv_invoice -orderby]
    
      </querytext>
</fullquery>

</queryset>
    
