@date_filter;noquote@
<br><br>

<listfilters name="reports" style="select-menu"></listfilters>
<listtemplate name="reports"></listtemplate>

<center>
<if @final_amount@ not nil>
<br>
<ul>
<li><b>#invoices.Total#:</b> @final_amount@
</ul>
</if>
</center>

