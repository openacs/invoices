<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/acs-mail-lite/lib/email"
 party_ids="@contact_id@" content="@invoice_text;noquote@"
 mime_type="text/html" subject="@subject@" file_ids="@file_ids@"
 export_vars="invoice_id" return_url="@return_url;noquote@"
 cancel_url="@cancel_url;noquote@">
