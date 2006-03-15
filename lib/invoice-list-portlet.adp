<master src="@portlet_layout@">
<property name="portlet_title">#invoices.iv_invoice_2#</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	<include src="/packages/invoices/lib/invoice-list"
		organization_id="@organization_id@" 
		row_list="@row_list@"
		orderby="@orderby@" 
		page="@page@" 
		format="@format@" 
		page_size="@page_size@" />
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


