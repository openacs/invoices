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
<li><a href="projects-billable">#invoices.Billable_Projects#</a></li>
<li><a href="invoice-items">#invoices.Invoices_items#</a></li>
<li><a href="offer-items">#invoices.Offers_items#</a></li>
<li><a href="offer-items-reports">#invoices.Offer_Items_Reports#</a></li>
<li><a href="invoice-items-reports">#invoices.Invoice_Items_Reports#</a></li>
<li><a href="offer-first-reports">#invoices.First_Order_Reports#</a></li>
<li><a href="@fs_folder_url@">#invoices.iv_journal#</a></li>
</ul>
