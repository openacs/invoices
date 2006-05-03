<?xml version="1.0"?>
<queryset>

<fullquery name="last_checkout">
      <querytext>

    select max(to_char(creation_date, 'YYYY-MM-DD HH24:MI:SS')) as last_checkout
    from iv_journals

      </querytext>
</fullquery>

<fullquery name="today">
      <querytext>

    select to_char(now(), 'YYYYMMDD_HH24MI') as today, to_char(now(), 'YYYY-MM-DD HH24:MI:SS') as today_pretty

      </querytext>
</fullquery>

<fullquery name="country_codes">
      <querytext>

    select iso_code, journal_code
    from iv_journal_country_codes

      </querytext>
</fullquery>

<fullquery name="new_customers">
      <querytext>

    select distinct i.recipient_id
       from iv_invoices i, cr_items ii, acs_objects o
      where i.invoice_id = ii.latest_revision
      and o.object_id = ii.item_id
      and i.status in ('billed', 'cancelled', 'paid')
      and o.creation_date > to_timestamp(:last_checkout, 'YYYY-MM-DD HH24:MI:SS')

      </querytext>
</fullquery>

<fullquery name="new_invoices">
      <querytext>

    select i.invoice_nr, i.parent_invoice_id, i.recipient_id, i.total_amount, i.currency,
           i.payment_days, i.vat, i.vat_percent, to_char(o.creation_date, 'MMYYYY') as invoice_period,
           r.title as invoice_name, to_char(o.creation_date, 'DDMMYYYY') as invoice_date
    from iv_invoices i, cr_revisions r, cr_items ii, acs_objects o
    where i.invoice_id = r.revision_id
    and r.revision_id = ii.latest_revision
    and o.object_id = ii.item_id
    and i.status in ('billed', 'cancelled', 'paid')
    and o.creation_date > to_timestamp(:last_checkout, 'YYYY-MM-DD HH24:MI:SS')

      </querytext>
</fullquery>

<fullquery name="new_invoice_journal">
      <querytext>

    select i.invoice_nr, i.recipient_id, i.total_amount, i.currency, i.amount_sum, i.vat,
           to_char(o.creation_date, 'YYYY-MM-DD HH24:MI:SS') as invoice_date
    from iv_invoices i, cr_items ii, acs_objects o
    where i.invoice_id = ii.latest_revision
    and o.object_id = ii.item_id
    and i.status in ('billed', 'cancelled')
    and o.creation_date > to_timestamp(:last_checkout, 'YYYY-MM-DD HH24:MI:SS')
    order by i.invoice_nr

      </querytext>
</fullquery>

<fullquery name="parent_invoice_nr">
      <querytext>

	    select invoice_nr as parent_invoice_nr
	    from iv_invoices
	    where invoice_id = :parent_invoice_id

      </querytext>
</fullquery>

<fullquery name="mark_journal_creation">
      <querytext>

    insert into iv_journals (file_id, creation_date)
    values (:zip_file_id, now())

      </querytext>
</fullquery>

</queryset>
