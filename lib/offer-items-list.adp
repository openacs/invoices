<if @filters_p@>
<table>
<tr>
    <td>
    <form>
	<table>
	<tr>
	   <td valign="middle">
              <b>#invoices.Date_Range#</b> 
           </td> 
           <td>
               <input type="text" id="sel1" name="date_range" size="10"> 
               <a href="" onclick="return showCalendar('sel1', 'yyyy-mm-dd')">
	       <img src="resources/calendar.gif" border="0"></a>
	       &nbsp;
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
