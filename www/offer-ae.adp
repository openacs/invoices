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

<if @_credit_percent@ gt 0>
function calculateTotalAmount() {
    var form = document.forms.iv_offer_form;
    var total = 0.;
    var credit_percent = form.credit_percent.value;
    var credit = 0.;

    for (i=1; i<@finish@; i++) {
      units = form["item_units."+i].value
      price = form["item_price."+i].value
      item_amount = form["amount_sum."+i].value
      item_rebate = form["item_rebate."+i].value
      item_total = 0.
      new_total = 0.

      item_total = Math.round( (1.*item_amount) * (100.-item_rebate) ) /100.;

      new_units = formatCurrency( (1.*units) );
      if ( (1.*price) > 1.) {
        new_units = formatCurrency( Math.round( (1.*units) * (100. + (1.*credit_percent)) / 10. ) / 10. );
      }

      new_amount = formatCurrency( Math.round( 100.* (1.*new_units) * (1.*price) ) /100. );
      new_total = Math.round( (1.*new_amount) * (100. - item_rebate) ) /100.;

      credit = credit + new_total - item_total;
      total = total + item_total;
    }

    form.credit_sum.value = formatCurrency(credit);
    form.amount_sum.value = formatCurrency(total);
    form.amount_total.value = formatCurrency(total);
}
</if><else>
function calculateTotalAmount() {
    var form = document.forms.iv_offer_form;
    var total = 0.;

    for (i=1; i<@finish@; i++) {
      units = form["item_units."+i].value
      price = form["item_price."+i].value
      item_amount = form["amount_sum."+i].value
      item_rebate = form["item_rebate."+i].value

      item_total = Math.round( (1*item_amount) * (100-item_rebate) ) /100;

      total = total + item_total;
    }

    form.amount_sum.value = formatCurrency(total);
    form.amount_total.value = formatCurrency(total);
}
</else>

</script>
</if>

<blockquote>
  <formtemplate id="iv_offer_form"></formtemplate>
</blockquote>
