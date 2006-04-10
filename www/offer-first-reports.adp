<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>


<include src="/packages/invoices/lib/report-first-order"
	portlet_title="@page_title@"
	base_url="@base_url@"
	year="@year@"
	month="@month@"
	day="@day@"
	last_years="@last_years@"
        orderby="@orderby@"
/>
