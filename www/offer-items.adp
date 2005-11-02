<master>
<property name="title">@page_title;noquote@</property>
<property name="context"> @context;noquote@</property>

<include src="/packages/invoices/lib/offer-items-list-portlet"
	portlet_title="@page_title;noquote@"
	page="@page@"
	elements="@elements@"
	offer_items_orderby="@offer_items_orderby@"
	filters_p="@filters_p@"
/>
