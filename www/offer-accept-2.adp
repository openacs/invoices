<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/acs-mail-lite/lib/email"
 party_ids="@contact_id@" content="@offer_text;noquote@"
 mime_type="text/html" subject="@subject@" object_id="@project_id@"
 export_vars="offer_id" return_url="@return_url;noquote@"
 cancel_url="@cancel_url@" file_ids="@file_ids@">
