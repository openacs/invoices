<if @organization_id@ not nil>
  <master src="@contact_master@">
  <property name="party_id">@organization_id@</property>
</if><else>
  <master>
</else>

<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

#invoices.Change_pricelist_of_customer#: @organization_name@ (@current_pricelist_name@)<br>

<p>
<if @price_list_id@ eq "">
<if @delete_only@ not eq 1>
<listtemplate name="iv_pricelist_list"></listtemplate><br>
<a href="/invoices/price-list-choose?organization_id=@organization_id@&delete_only=1">#invoices.Delete#</a>
</if>
</if>