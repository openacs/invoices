<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @sent_p@>
  <font color=red>#invoices.invoice_warning_sent#</font><p>
</if>

<blockquote>
  <formtemplate id="invoice_send"></formtemplate>
</blockquote>
    
