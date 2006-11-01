<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<blockquote>
  <formtemplate id="iv_invoice_form"></formtemplate>
</blockquote>
<if @odt_url@ ne "">
<a href="@odt_url@">invoice.odt</a>
</if>    
