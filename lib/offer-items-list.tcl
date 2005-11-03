set optional_param_list [list elements category_filter_clause]
set optional_unset_list [list offer_items_orderby category_id \
			     customer_id filter_package_id date_range \
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

if { [exists_and_not_null date_range] } {
    catch { set date_range [lc_time_fmt $date_range %y-%m-%d] } errMsg
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

if { [exists_and_not_null category_id] } {
    set category_filter_clause "and com.category_id = $category_id"
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

# We are going to create the elements for each mapped categories
if { $categories_p } {
    set categories [db_list_of_lists get_categories { }]
    
    set mapped_objects [list]
    set multirow_extend [list]
    
    foreach category $categories {
	set cat_name [lindex $category 0]
	set cat_id   [lindex $category 1]
	
	lappend multirow_extend category_$cat_id
	if { [exists_and_not_null category_id] } {
	    set label "<a href=\"offer-items?category_id=$cat_id\">$cat_name</a>"
	    append label "&nbsp;&nbsp;<small>(<a href=\"offer-items\">[_ invoices.clear]</a>)</small>"
	} else {
	    set label "<a href=\"offer-items?category_id=$cat_id\">$cat_name</a>"
	}
	lappend elements category_$cat_id [list label $label]
	lappend row_list category_$cat_id 
	lappend row_list [list]
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


set filters [list category_id { } \
		 filter_package_id { 
		     where_clause { oi.object_package_id = :filter_package_id } 
		 } \
		 customer_id {
		     where_clause { o.organization_id = :customer_id} 	    
		 } \
		 date_range { 
		     where_clause { to_char(oi.creation_date,'yy-mm-dd') > :date_range }
		 }]

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
    { "#invoices.Customer#" { { groupby organization_id } { orderby organization_id,desc } } }
    { "#invoices.Category#" { { groupby category_id } { orderby cateogory_id,desc } } }    
    { "#invoices.Month#" { { groupby month } { orderby time_stamp,desc } }  }
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
    } \
    -html {width 100%} \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "offer_items_paginated" \
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
lappend multirow_extend final_amount

db_multirow -extend $multirow_extend offer_items offer_items { } {
    set final_amount [expr [expr $price_per_unit * $item_units] - [expr $rebate * $price_per_unit * $item_units]]
    if { $categories_p } {
	set category_$category_id "[_ invoices.Mapped]"
    }
    set project_item_id [lindex [application_data_link::get_linked -from_object_id $item_id -to_object_type content_item] 0]
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
