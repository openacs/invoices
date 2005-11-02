set optional_unset_list [list offer_items_orderby]

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]]} {
            unset $optional_unset
        }
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

if {![info exists package_id]} {
    set package_id [ad_conn package_id]
}

if {![info exists base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

foreach optional_param { elements } {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set user_id [ad_conn user_id]

# Elements to construnct row_lists
if { [exists_and_not_null elements] } {
    set row_list [list]
    foreach element $elements {
	lappend row_list $element
	lappend row_list [list]
    }
} else {
    set row_list [list item_title {} final_amount {} offer_title {} rebate {} item_id {} offer_item_id {}]
}

# Create the elements for the list template
set elements [list]
lappend elements item_title [list label "Offer Item Title"]

lappend elements final_amount [list label "Final Ammount"] \
    offer_title [list label "Offer Title" \
		     display_template {
			 <a href=\"offer-ae?mode=display&offer_id=@offer_items.item_id@\">@offer_items.offer_title@</a>
		     } ] \
    rebate [list label "Rebate"] \
    item_id [list label "item_id"] \
    offer_item_id [list label "offer_item_id"]


template::list::create \
    -name offer_items \
    -key offer_item_id \
    -no_data "[_ invoices.None]" \
    -has_checkboxes \
    -selected_format $format \
    -elements $elements \
    -orderby_name offer_items_orderby \
    -orderby {
	default_value item_id 
	item_title {
	    label {Offer Item Title}
	    orderby_desc { lower(oi.title) desc }
	    orderby_asc { lower(oi.title) asc }
	}
	offer_title {
	    label "Offer Title"
	    orderby_desc { lower(o.title) desc }
	    orderby_asc { lower(o.title) asc }
	}
    } \
    -html {width 100%} \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "offer_items_paginated" \
    -filters { } \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
    }

db_multirow -extend { final_amount } offer_items offer_items { } {
    set final_amount [expr [expr $price_per_unit * $item_units] - [expr $rebate * $price_per_unit * $item_units]]
}
