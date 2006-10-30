<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/contacts/lib/email"
 party_ids="@contact_id@" content="@offer_text;noquote@"
 mime_type="text/html" subject="@subject@" file_ids="@file_ids@"
 export_vars="offer_id" return_url="@return_url;noquote@" cc="@cc_emails@"
 object_id="@project_id@" context_id="@project_id@" cancel_url="@cancel_url;noquote@">