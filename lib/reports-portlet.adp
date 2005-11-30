<master src="@portlet_layout@">
<property name="portlet_title">#invoices.iv_reports#</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	<include src="@include_src@"
    		organization_id="@organization_id@"
    		format="@format@"
		last_years="@last_years@"
		year="@year@"
		month="@month@"
    		day="@day@"
    		new_clients_p="@new_clients_p@"
    		account_manager_p="@account_manager_p@"
    		orderby="@orderby@" />
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


