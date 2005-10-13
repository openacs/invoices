<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/invoices/lib/invoice-list-portlet"
 organization_id="@organization_id@" row_list="@row_list@"
 orderby="@orderby@" format="@format@" page_size="@page_size@">
