<master src="@portlet_layout@">
<property name="portlet_title">@portlet_title;noquote@</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	<include src="/packages/invoices/lib/offer-items-list"
		page="@page@"
		elements="@elements@"
		offer_items_orderby="@offer_items_orderby@"
		filters_p="@filters_p@"
	/>
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


