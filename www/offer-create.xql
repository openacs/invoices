<?xml version="1.0"?>
<queryset>

<fullquery name="get_currency_and_credit_percent">
      <querytext>
      
	select l.currency, l.credit_percent as credit_percent
	from iv_price_lists l, cr_items li
	where l.list_id = li.latest_revision
	and li.item_id = :list_id
	
      </querytext>
</fullquery>

<fullquery name="get_project">
      <querytext>

	select r.title as project_name, r.item_id, p.project_code, r.description as comment,
               to_char(p.planned_end_date,'YYYY-MM-DD HH24:MI:SS') as project_date_ansi
	from cr_revisions r, cr_items i, pm_projects p
	where i.item_id = :project_item_id
	and i.latest_revision = r.revision_id
	and p.project_id = r.revision_id

      </querytext>
</fullquery>

</queryset>
