set optional_param_list [list elements category_filter_clause date_range_start date_range_end]
set optional_unset_list [list iv_items_orderby category_id \
			     customer_id filter_package_id \
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
    set row_list [list item_title {} final_amount {} invoice_title {} \
		      rebate {} item_id {} invoice_item_id {} creation_date {}]
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

set aggregate_amount ""
if { [exists_and_not_null groupby] } {
    append aggregate_amount "<ul><table border=0><tr><td><b>Aggregate Amount:</b></td><td>&nbsp;</td></tr>"
    foreach cat $categories_filter {
	set c_name [lindex $cat 0]
	set c_id   [lindex $cat 1]
	if { [exists_and_not_null category_id] } {
	    if { [string equal $c_id $category_id] } {
		append aggregate_amount "<tr><td><li>$c_name:</td>"
		set amount [db_string get_amount { }]
		append aggregate_amount "<td align=right>$amount</td>"
		append aggregate_amount "</tr>"
	    }
	} else {
	    append aggregate_amount "<tr><td><li>$c_name:</td>"
	    set amount [db_string get_amount { }]
	    append aggregate_amount "<td align=right>$amount</td>"
	    append aggregate_amount "</tr>"
	}
    }
append aggregate_amount "</ul>"
}


lappend elements item_title [list label "[_ invoices.Invoice_Item_title]"] \
    final_amount [list label "[_ invoices.Final_Amount]"] \
    invoice_title [list label "[_ invoices.Invoice_Title]" \
		     display_template {
			 <a href=\"invoice-ae?mode=display&invoice_id=@iv_items.item_id@&organization_id=@iv_items.organization_id@&project_id=@iv_items.project_item_id@\">@iv_items.invoice_title@</a>
		     } ] \
    rebate [list label "[_ invoices.Rebate]" \
		display_template {
		    @iv_items.rebate@ %
		}
	       ] \
    item_id [list label "[_ invoices.Item_Id]"] \
    iv_item_id [list label "[_ invoices.Invoice_Item_Id]"] \
    creation_date [list label "[_ invoices.Creation_Date]"] \
    month [list label ""]


set filters [list \
		 category_id { 
                     label "[_ invoices.Category]"
                     values $categories_filter
                     where_clause { com.category_id = :category_id }
		 } \
		 filter_package_id { 
		     where_clause { ii.object_package_id = :filter_package_id } 
		 } \
		 customer_id {
		     where_clause { iv.organization_id = :customer_id} 	    
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

set project_status_p 0
if { [exists_and_not_null project_status_id] } {
    set project_status_p 1
}


set groupby_values {
    { "#invoices.Customer#" { { groupby org_name } { iv_items_orderby org_name,asc } } }
    { "#invoices.Category#" { { groupby cat_name } { iv_items_orderby cat_name,asc } } }    
    { "#invoices.Month#" { { groupby month } { iv_items_orderby month,asc } }  }
}


template::list::create \
    -name iv_items \
    -key iv_item_id \
    -no_data "[_ invoices.None]" \
    -has_checkboxes \
    -selected_format $format \
    -elements $elements \
    -orderby_name iv_items_orderby \
    -orderby {
	item_title {
	    label { [_ invoices.Invoice_Item_title] }
	    orderby_desc { lower(ii.title) desc }
	    orderby_asc { lower(ii.title) asc }
	}
	invoice_title {
	    label "[_ invoices.Invoice_Title]"
	    orderby_desc { lower(iv.title) desc }
	    orderby_asc { lower(iv.title) asc }
	}
	org_name {
	    label { [_ invoices.Customer] }
	    orderby_asc { org.name asc }
	}
	cat_name {
	    label { [_ invoices.Category] }
	    orderby_asc { ob.title asc }
	}
	month {
	    label { [_ invoices.Month] }
	    orderby_asc { to_char(ii.creation_date,'mm') asc }
	}
    } \
    -html {width 100%} \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "iv_items_paginated" \
    -pass_properties return_url \
    -groupby {
	label "[_ invoices.Group_by]:"
	type multivar
	values $groupby_values
    } \
    -filters $filters \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
    }

# Elements to extend the multirow
lappend multirow_extend project_item_id

db_multirow -extend $multirow_extend iv_items iv_items { } {
    if { $categories_p && [exists_and_not_null cat_id]} {
	set tree_id [category::get_tree $cat_id]
	set tree_$tree_id "$cat_name"
    }
    
    set off_item_id [db_string get_offer_item_id { }]
    
    set project_item_id [lindex [application_data_link::get_linked -from_object_id $off_item_id -to_object_type content_item] 0]
    if { $project_status_p } {
	if { [exists_and_not_null project_item_id] } {
	    switch $project_status_id {
		"1" {
		    if { ![pm::project::open_p -project_item_id $project_item_id] } {
			continue
		    }
		}
		"2" {
		    if { [pm::project::open_p -project_item_id $project_item_id] } {
			continue
		    }
		}
	    }
	} else {
	    continue
	}
    }
}
