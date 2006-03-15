<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<include src="/packages/invoices/lib/projects-billable-portlet"
	organization_id="@organization_id@" 
	elements="recipient title description amount_open count_total count_billed creation_date" 
	package_id=""
	base_url=""
	format="@format@" 
 	orderby="@orderby@" 
	page_size="@page_size@" />
