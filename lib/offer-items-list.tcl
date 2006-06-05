set optional_param_list [list elements category_filter_clause date_range_start date_range_end]
set optional_unset_list [list offer_items_orderby category_id \
			     customer_id filter_package_id  \
			     project_status_id groupby]

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]]} {
            unset $optional_unset
        }
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set date_range_clause ""

if { [exists_and_not_null date_range_start] } {
    set date_range 1
    catch { set date_range_start [lc_time_fmt $date_range_start %y-%m-%d] } errMsg
    append date_range_clause "to_char(oi.creation_date,'yy-mm-dd') >= :date_range_start"
}

if { [exists_and_not_null date_range_end] } {
    set date_range 1
    catch { set date_range_end [lc_time_fmt $date_range_end %y-%m-%d] } errMsg

    if { [exists_and_not_null date_range_start] } {
	append date_range_clause " and to_char(oi.creation_date,'yy-mm-dd') <= :date_range_end"
    } else {
	append date_range_clause "to_char(oi.creation_date,'yy-mm-dd') <= :date_range_end"
    }
}

if {![info exist filters_p] } { 
    set filters_p 1
}

if {![info exists format]} {
    set format "normal"
}

if {![info exists page_size]} {
    set page_size "25"
}

if {![info exists invoice_package_id]} {
    set invoice_package_id [ad_conn package_id]
}

if {![info exists base_url]} {
    set base_url [apm_package_url_from_id $invoice_package_id]
}

if { ![exists_and_not_null return_url] } {
    set return_url [ad_return_url]
}

set categories_p 0

# Elements to construnct row_lists
if { [exists_and_not_null elements] } {
    set row_list [list]
    foreach element $elements {
	if { ![string equal $element "categories"] } {
	    lappend row_list $element
	    lappend row_list [list]
	} else {
	    set categories_p 1
	}
    }
} else {
    set row_list [list item_title {} final_amount {} offer_title {} rebate {} item_id {} offer_item_id {} creation_date {}]
}

# Create the elements for the list template
set elements [list]
set categories_filter [list]

# We are going to create the elements for each mapped category tree
if { $categories_p } {
    set categories_trees [db_list_of_lists get_category_trees { }]
    
    set mapped_objects [list]
    set multirow_extend [list]
    set tree_ids [list]

    foreach tree $categories_trees {
	set tree_name [lindex $tree 0]
	set tree_id   [lindex $tree 1]

	lappend tree_ids $tree_id
	lappend multirow_extend tree_$tree_id

	set label "$tree_name"
	
	lappend elements tree_$tree_id [list label $label]
	lappend row_list tree_$tree_id 
	lappend row_list [list]
    }
    set categories [db_list_of_lists get_categories " "]
    foreach cat $categories {
	lappend categories_filter [list [lang::util::localize [lindex $cat 0]] [lindex $cat 1]]
    }
}

lappend elements item_title [list label "[_ invoices.Offer_Item_Title]"] \
    final_amount [list label "[_ invoices.Final_Amount]"] \
    offer_title [list label "[_ invoices.Offer_Title]" \
		     display_template {
			 <a href=\"offer-ae?mode=display&offer_id=@offer_items.item_id@\">@offer_items.offer_title@</a>
		     } ] \
    rebate [list label "[_ invoices.Rebate]" \
		display_template {
		    @offer_items.rebate@ %
		}
	       ] \
    item_id [list label "[_ invoices.Item_Id]"] \
    offer_item_id [list label "[_ invoices.Offer_Item_Id]"] \
    creation_date [list label "[_ invoices.Creation_Date]"] \
    month [list label ""]

set cat_where_clause ""
if { [exists_and_not_null category_id] } {
    set cat_where_clause "com.category_id in ([template::util::tcl_to_sql_list $category_id])"
}

set filters [list \
		 category_id { 
		     label "[_ invoices.Category]"
		     values $categories_filter
		     type multival
		     where_clause { $cat_where_clause }
		 } \
		 filter_package_id { 
		     where_clause { oi.object_package_id = :filter_package_id } 
		 } \
		 customer_id {
		     where_clause { o.organization_id = :customer_id} 	    
		 } \
		 date_range { 
		     where_clause "$date_range_clause" 
		 } \
		 date_range_start { } \
		 date_range_end { } \
	    ]

if { [apm_package_installed_p "project-manager"] } {
    lappend filters project_status_id {
	label "Project Status Id:"
	values { [pm::status::project_status_select] } 
    }
}

# If the project_status_id filter is set, then
# Limit it in the pagination query
if {[exists_and_not_null project_status_id]} {
    set project_pag_query "and i.item_id in (select object_id_one
from acs_data_links r, cr_items i 
where r.object_id_one = i.item_id 
and i.content_type = 'iv_offer' 
and object_id_two in (select item_id 
   from cr_items pi, pm_projects p 
   where p.status_id = :project_status_id 
   and pi.latest_revision = p.project_id))"
} else {
    set project_pag_query ""
}

set groupby_values {
    { "#invoices.Customer#" { { groupby org_name } { offer_items_orderby org_name,asc } } }
    { "#invoices.Category#" { { groupby cat_name } { offer_items_orderby cat_name,asc } } }    
    { "#invoices.Month#" { { groupby month } { offer_items_orderby month,asc } }  }
}


template::list::create \
    -name offer_items \
    -key offer_item_id \
    -no_data "[_ invoices.None]" \
    -has_checkboxes \
    -selected_format $format \
    -elements $elements \
    -orderby_name offer_items_orderby \
    -orderby {
	item_title {
	    label { [_ invoices.Offer_Item_Title] }
	    orderby_desc { lower(oi.title) desc }
	    orderby_asc { lower(oi.title) asc }
	}
	offer_title {
	    label "[_ invoices.Offer_Title]"
	    orderby_desc { lower(o.title) desc }
	    orderby_asc { lower(o.title) asc }
	}
        cat_name {
            label { [_ invoices.Category] }
            orderby_asc { ob.title asc }
        }
	month {
	    label { [_ invoices.Month] }
	    orderby_asc { to_char(oi.creation_date,'mm') asc }
	}
    } \
    -html {width 100%} \
    -page_size $page_size \
    -page_flush_p 1 \
    -page_query_name "offer_items_paginated" \
    -pass_properties return_url \
    -groupby {
	label "[_ invoices.Group_by]:"
	type multivar
	values $groupby_values
    } -filters $filters \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
    }

# Elements to extend the multirow
lappend multirow_extend final_amount

db_multirow -extend $multirow_extend offer_items offer_items { } {
    set amount [expr $price_per_unit * $item_units]
    if { [string equal $rebate "0.00"] } {
	set final_amount [format %.2f $amount]
    } else {
	set final_amount [format %.2f [expr $amount - [expr [expr $rebate / 100] * $amount]]]
    }
    if { $categories_p && [exists_and_not_null cat_id]} {
	set tree_id [category::get_tree $cat_id]
	set tree_$tree_id $cat_name
    }
}

set aggregate_amount ""
if { [exists_and_not_null groupby] } {
    append aggregate_amount "<ul><table border=0><tr><td><b>Aggregate Amount:</b></td><td>&nbsp;</td></tr>"
    foreach cat $categories_filter {
        set c_name [lindex $cat 0]
        set c_id   [lindex $cat 1]
	set amount_values [db_list_of_lists get_amount_values { }]
	set total_amount "0.00"
	foreach val $amount_values {
	    set ppu [lindex $val 0]
	    set iu  [lindex $val 1]
	    set r   [lindex $val 2]
	    set amount [expr $ppu * $iu]
	    if { [string equal $r "0.00"] } {
		set amount [format %.2f $amount]
	    } else {
		set amount [format %.2f [expr $amount - [expr [expr $r / 100] * $amount]]]
	    }
	    set total_amount [expr $total_amount + $amount]
	}

        if { [exists_and_not_null category_id] } {
	    foreach cat_id $category_id {
		if { [string equal $c_id $cat_id] } {
		    append aggregate_amount "<tr><td><li>$c_name:</td>"
		    append aggregate_amount "<td align=right>$total_amount</td>"
		    append aggregate_amount "</tr>"
		}
	    }
        } else {
            append aggregate_amount "<tr><td><li>$c_name:</td>"
            append aggregate_amount "<td align=right>$total_amount</td>"
            append aggregate_amount "</tr>"
        }
    }
append aggregate_amount "</ul>"
}

