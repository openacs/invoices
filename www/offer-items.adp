<master>
<property name="title">@page_title;noquote@</property>
<property name="context"> @context;noquote@</property>

<include src="/packages/invoices/lib/offer-items-list-portlet"
	portlet_title="@page_title;noquote@"
	page="@page@"
	elements="@elements@"
	offer_items_orderby="@offer_items_orderby@"
	filters_p="@filters_p@"
	category_id="@category_id@"
	filter_package_id="@filter_package_id@"
	customer_id="@customer_id@"
	date_range_start="@date_range_start@"
	date_range_end="@date_range_end@"
	project_status_id="@project_status_id@"
	groupby="@groupby@"
/>
