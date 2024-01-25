<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<script src="/resources/acs-templating/calendar.js"></script>

<table width="100%">
<tr>
<td>
<form action="@current_url@">
  @export_vars;noquote@
  <table>
    <tr>
      <td>#invoices.iv_invoice_start_date# <input type=text name="start_date" size=12 value="@start_date@" id=sel1><input type='reset' value=' ... ' onclick="return showCalendar('sel1', 'y-m-d');"></td>
      <td>#invoices.iv_invoice_end_date# <input type=text name="end_date" size=12 value="@end_date@" id=sel2><input type='reset' value=' ... ' onclick="return showCalendar('sel2', 'y-m-d');"></td>
      <td>#invoices.iv_invoice_amount_limit# <input type=text name="amount_limit" size=6 value="@amount_limit@"></td>
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

<include src="/packages/invoices/lib/report-customer"
	portlet_title="@page_title@"
	base_url="@base_url@"
	start_date="@start_date@"
	end_date="@end_date@"
        orderby="@orderby@"
        country_code="@country_code@"
        sector="@sector@"
        category_id="@category_id@"
        type="@type@"
        amount_limit="@amount_limit@"
        manager_id="@manager_id@"
/>
