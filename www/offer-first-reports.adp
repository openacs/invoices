<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>


<table width="100%">
<tr>
<td>
<form action="@current_url@">
  @export_vars;noquote@
  <table>
    <tr>
      <td>#invoices.iv_invoice_start_date# <input type=text name="start_date" size=12 value="@start_date@"></td>
      <td>#invoices.iv_invoice_end_date# <input type=text name="end_date" size=12 value="@end_date@"</td>
      <td><input type=submit name="submit" value="#invoices.ok#"></td>
    </tr>
    <if @clear_p@ eq 1>
      <tr>
        <td><a href="@clear_link@">#invoices.clear#</a></td>
      </tr>
    </if>
  </table>
</form>
</td>

<include src="/packages/invoices/lib/report-first-order"
	portlet_title="@page_title@"
	base_url="@base_url@"
	start_date="@start_date@"
	end_date="@end_date@"
        orderby="@orderby@"
/>
