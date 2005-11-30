<master src="@portlet_layout@">
<property name="portlet_title">@portlet_title;noquote@</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
	<include src="report-offer-items"
		base_url="@base_url@"
		year="@year@"
        	month="@month@"
        	day="@day@"
        	last_years="@last_years@"
		show_p="@show_p@"
	        category_f="@category_f@"
		status_f="@status_f@"
	/>
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>