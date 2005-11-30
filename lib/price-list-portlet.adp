<master src="@portlet_layout@">
<property name="portlet_title">@page_title;noquote@</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	    <include src="/packages/invoices/lib/price-list" 
		list_id="@list_id@" />
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


