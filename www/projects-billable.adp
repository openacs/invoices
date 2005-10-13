<master>
<table width="50%">
<tr>
   <td>
	<include src="/packages/invoices/lib/projects-billable-portlet" 
		organization_id="@organization_id@" 
		elements="checkbox project_id title amount_open" 
		package_id="@iv_package_id@" 
		base_url="@iv_base_url@"
		format=""
		orderby="" 
	        page_size=""/>
    </td>
</tr>
</table>
