<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/acs-mail-lite/lib/email"
 party_ids="@party_ids@" content="@offer_text;noquote@"
 mime_type="text/html" subject="@offer_nr@" file_ids="@file_ids@"
 export_vars="offer_id" return_url="@return_url;noquote@">
