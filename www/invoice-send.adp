<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/acs-mail-lite/lib/email"
 party_ids="@party_ids@" content="@invoice_text;noquote@"
 mime_type="text/html" subject="@invoice_nr@"
 export_vars="invoice_id" return_url="@return_url;noquote@">
