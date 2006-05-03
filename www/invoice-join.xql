<?xml version="1.0"?>
<queryset>

<fullquery name="last_checkout">
      <querytext>

    select max(to_char(creation_date, 'YYYY-MM-DD HH24:MI:SS')) as last_checkout
    from iv_joined_invoices

      </querytext>
</fullquery>

<fullquery name="today">
      <querytext>

    select to_char(now(), 'YYYYMMDD_HH24MI') as today

      </querytext>
</fullquery>

<fullquery name="pdfs_to_join">
      <querytext>

	select fr.content
	from iv_invoices i, cr_items ci, cr_items fi, cr_revisions fr, acs_objects fo
	where ci.latest_revision = i.invoice_id
	and i.pdf_status = 'created'
	and fi.item_id = i.pdf_file_id
	and fr.revision_id = fi.latest_revision
	and fo.object_id = fr.revision_id
	and fo.creation_date > to_timestamp(:last_checkout, 'YYYY-MM-DD HH24:MI:SS')
	order by i.organization_id, i.invoice_nr

      </querytext>
</fullquery>

<fullquery name="get_file_location">
      <querytext>

    select r.content as file_location
    from cr_items i, cr_revisions r
    where i.latest_revision = r.revision_id
    and i.item_id = :file_id

      </querytext>
</fullquery>

<fullquery name="mark_join_creation">
      <querytext>

    insert into iv_joined_invoices (file_id, creation_date)
    values (:file_id, now())

      </querytext>
</fullquery>

<fullquery name="mark_invoices_billed">
      <querytext>

	update iv_invoices
	set pdf_status = 'sent'
	where invoice_id in (select i.invoice_id
			     from iv_invoices i, cr_items ci, cr_items fi, acs_objects fo
			     where ci.latest_revision = i.invoice_id
			     and i.pdf_status = 'created'
			     and fi.item_id = i.pdf_file_id
			     and fo.object_id = fi.latest_revision
			     and fo.creation_date > to_timestamp(:last_checkout, 'YYYY-MM-DD HH24:MI:SS'))

      </querytext>
</fullquery>

</queryset>
