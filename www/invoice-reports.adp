<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<formtemplate id="aggregate"></formtemplate>

<center>
<table>
   <tr>
	<td>
	<multiple name="years">
	    <if @years.year@ eq @year@ >
                <b>@years.year_url;noquote@ &nbsp;</b>
	    </if>
            <else>
                @years.year_url;noquote@ &nbsp;
            </else>
	</multiple>
	</td>
   </tr>
   <tr>
	<td>
	<multiple name="months">
	    <if @months.month@ eq @month@>
		<b>@months.month_url;noquote@ &nbsp;</b>
	    </if>
	    <else>
		@months.month_url;noquote@ &nbsp;
            </else>
	</multiple>
	</td>
   </tr>
   <tr>
	<td>
	<multiple name="days">
	    <if @days.day@ eq @day@>
	       <b>@days.day_url;noquote@ &nbsp;</b>
	    </if>
	    <else>
	        @days.day_url;noquote@ &nbsp;
	    </else>
	</multiple>
	</td>
   </tr>
</table>
</center>

<include src="@include_src@"
    organization_id="@organization_id@" 
    format="@format@" 
    last_years="@last_years@"
    year="@year@"	
    month="@month@"
    day="@day@"
    new_clients_p="@new_clients_p@"
    account_manager_p="@account_manager_p@"
    orderby="@orderby@"
>
