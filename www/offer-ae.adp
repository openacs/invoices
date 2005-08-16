<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @has_submit@ eq 0>
<script language="javascript">
priceList = new Array(
<multiple name="pricelist" delimiter=",">
new Array(@pricelist.category_id@, @pricelist.amount@)</multiple>
);

function formatCurrency(amount) {
    if(isNaN(amount)) amount = "0";

    abs = Math.floor(amount);
    cents = Math.round(100*(amount-abs));
    if(cents<10) cents = "0" + cents;

    return (abs + "." + cents);
}

function setItemPrice(i) {
    var form = document.forms.iv_offer_form;

    category_id = form["item_category."+i].value;
    price = ""

    for (j=0; j<priceList.length; j++) {
      if (priceList[j][0] == category_id)
        price = priceList[j][1];
    }

    form["item_price."+i].value = formatCurrency(price);
    calculateItemAmount(i);
}

function calculateItemAmount(i) {
    var form = document.forms.iv_offer_form;

    units = form["item_units."+i].value
    price = form["item_price."+i].value

    amount = Math.round(100* (1*units) * (1*price)) /100;

    form["amount_sum."+i].value = formatCurrency(amount);

    calculateTotalAmount();
}

function calculateTotalAmount() {
    var form = document.forms.iv_offer_form;
    var total = 0.;

    for (i=1; i<5+@start@; i++) {
      item_amount = form["amount_sum."+i].value
      item_rebate = form["item_rebate."+i].value

      total = total + Math.round( (1*item_amount) * (100-item_rebate) ) /100;
    }

    form.amount_sum.value = formatCurrency(total);
    form.amount_total.value = formatCurrency(total);
}
</script>
</if>

<blockquote>
  <formtemplate id="iv_offer_form"></formtemplate>
</blockquote>
