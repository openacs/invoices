<if @filters_p@>
<table>
<tr>
    <td>
    <form>
	<table border="0">
	<tr>
           <td valign="top">
		<b>#invoices.Between#:</b>
	   </td>
	   <td>
               <input type="text" id="sel1" name="date_range_start" size="10" value="@date_range_start@"> 
               <a href="" onclick="return showCalendar('sel1', 'yy-mm-dd')">
	       <img src="resources/calendar.gif" border="0"></a><br>
	       <small>[ yyyy-mm-dd ]</small>	
	   </td>
	   <td valign="top">
		&nbsp;<b>#invoices.and#</b>&nbsp;
           </td>
	   <td>
               <input type="text" id="sel2" name="date_range_end" size="10" value="@date_range_end@"> 
               <a href="" onclick="return showCalendar('sel2', 'yy-mm-dd')">
	       <img src="resources/calendar.gif" border="0"></a>
               <input type="submit" value="ok"><br>
	       <small>[ yyyy-mm-dd ]</small>
	   </td>
        </tr>
	</table>
    </form> 
    </td>
</tr>
<tr>
    <td>
    <listfilters name="offer_items" style="select-menu"></listfilters>
    </td>
</tr>
</table>
</if>

<listtemplate name="offer_items"></listtemplate>

@aggregate_amount;noquote@ 
