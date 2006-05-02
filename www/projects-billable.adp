<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<table width="100%">
<tr>
   <td>
	<include src="/packages/invoices/lib/projects-billable" 
		organization_id="@organization_id@" 
		elements="recipient title description creation_date amount_open count_total count_billed"
		package_id="@iv_package_id@" 
		base_url="@iv_base_url@"
		format=""
		orderby="@orderby@" 
	        page_size=""/>
    </td>
</tr>
</table>
