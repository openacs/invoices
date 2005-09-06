<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @year_p@ eq 1>
    <include src="/packages/invoices/lib/report-year"
        organization_id="@organization_id@" 
        format="@format@" 
        last_years="@last_years@"
	new_clients_p="@new_clients_p@"
	account_manager_p="@account_manager_p@"
	orderby="@orderby@"
    >
</if>

<if @month_p@ eq 1>
     <include src="/packages/invoices/lib/report-month"
        organization_id="@organization_id@" 
        format="@format@" 
        year="@year@"
	new_clients_p="@new_clients_p@"
	account_manager_p="@account_manager_p@"
	orderby="@orderby@"
    >
</if>
<if @day_p@ eq 1>
     <include src="/packages/invoices/lib/report-day"
        organization_id="@organization_id@" 
        format="@format@" 
        year="@year@"
	month="@month@"
	new_clients_p="@new_clients_p@"
	account_manager_p="@account_manager_p@"
	orderby="@orderby@"
    >
</if>
