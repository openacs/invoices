<master src="@portlet_layout@">
<property name="portlet_title">#invoices.Billable_Projects#</property>

<table width="100%">
<tr>
  <td colspan="2" class="fill-list-bottom">
    <table border="0" cellpadding="1" cellspacing="1" width="100%">
      <tr>
        <td>
            <include src="/packages/invoices/lib/projects-billable"
                organization_id="@organization_id@"
                elements="@elements@"
                package_id="@package_id@"
                base_url="@base_url@"
                format="@format@"
                orderby="@orderby@"
                page_size="@page_size@" />
        </td>
      </tr>
    </table>
  </td>
</tr>
</table>


