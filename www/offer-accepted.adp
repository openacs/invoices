<html>
<head>
  <title>#invoices.offer_accept#</title>
      <link rel="stylesheet" type="text/css" href="/resources/acs-templating/forms.css" media="all" />
      <link rel="stylesheet" type="text/css" href="/resources/acs-subsite/default-master.css" media="all" />
      <link rel="stylesheet" type="text/css" href="/resources/dotlrn/dotlrn-toolbar.css" media="all" />
      <link rel="stylesheet" type="text/css" href="/resources/theme-selva/Selva/default/Selva.css" media="all">
</head>
<body>
<div id="portal">

<if @template_src@ not nil>
  <include src="@template_src@" offer_id="@offer_rev_id@" x="@x@">
</if><else>
  <h3>#invoices.iv_offer_accepted_thanks#</h3>
</else>

</div>
</body>
</html>
