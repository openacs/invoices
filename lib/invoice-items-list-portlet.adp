<master src="@portlet_layout@">
<property name="portlet_title">@portlet_title;noquote@</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	<include src="/packages/invoices/lib/invoice-items-list"
		page="@page@"
		elements="@elements@"
		iv_items_orderby="@iv_items_orderby@"
		filters_p="@filters_p@"
		category_id="@category_id@"
		filter_package_id="@filter_package_id@"
		customer_id="@customer_id@"
		date_range_start="@date_range_start@"
		date_range_end="@date_range_end@"
		project_status_id="@project_status_id@"
		groupby="@groupby@"
	/>
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


