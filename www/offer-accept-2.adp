<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/acs-mail-lite/lib/email"
 party_ids="@contact_id@" content="@offer_text;noquote@"
 mime_type="text/html" subject="@subject@"
 export_vars="offer_id" return_url="@return_url;noquote@"
 cancel_url="@cancel_url@" file_ids="@file_ids@"
 template_type="offer_accepted" template_object="@offer_id@"
 template_locale="@locale@" template_package_id="@contacts_package_id@">
