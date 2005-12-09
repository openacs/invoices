<if @organization_id@ not nil>
  <master src="@contact_master@">
  <property name="party_id">@organization_id@</property>
</if><else>
  <master>
</else>

<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<table width="40%">
<tr>
   <td>
	<include src="/packages/invoices/lib/price-list" 
		list_id="@list_id@" 
		organization_id="@organization_id@"
		page_title="@list_title;noquote@" />
   </td>
</tr>
</table>
<p>
<if @organization_id@ ne "">
<a href="price-list-ae?organization_id=@organization_id@">#invoices.Create_new_pricelist_for_customer#</a>
</if>