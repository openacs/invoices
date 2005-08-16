<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @admin_p@ true>
  <a href="admin/">#invoices.admin#</a>
  <p>
</if>

<ul>
<li><a href="price-list-list">#invoices.Price_Lists#</a></li>
<li><a href="offer-list">#invoices.Offers#</a></li>
<li><a href="invoice-list">#invoices.Invoices#</a></li>
</ul>
