set optional_param_list [list]
set optional_unset_list [list category_f]

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


# Procedure that manages the date filter
set date_filter [iv::invoice::year_month_day_filter \
		     -base $base_url \
		     -year $year \
		     -month $month \
		     -day $day \
		     -last_years $last_years \
		     -extra_vars ""]

set return_url [ad_return_url]
set extra_query ""

if { [exists_and_not_null year] } {
    # We get the projects for this year
    append extra_query " and to_char(ii.creation_date, 'YYYY') = :year"
}

if { [exists_and_not_null month] } {
    # We get the projects for this specific month
    append extra_query " and to_char(ii.creation_date, 'MM') = :month"
}

if { [exists_and_not_null day] } {
    # We get the projects for this specific day
    append extra_query " and to_char(ii.creation_date, 'DD') = :day"
}


set category_where_clause ""
if { [exists_and_not_null category_f] } {
    set category_where_clause "com.category_id in ([template::util::tcl_to_sql_list $category_f])"
}

set categories_trees [db_list_of_lists get_category_trees { }]

set categories_filter [list]
set tree_ids [list]

foreach tree $categories_trees {
    set tree_name [lindex $tree 0]
    set tree_id   [lindex $tree 1]
    lappend tree_ids $tree_id

    set categories [db_list_of_lists get_categories " "]
    
    foreach cat $categories {
	lappend categories_filter [list [lang::util::localize [lindex $cat 0]] [lindex $cat 1]]
    }
}

template::list::create \
    -name reports \
    -multirow reports \
    -filters {
	category_f {
	    label "Categories"
	    type multival
	    values $categories_filter
	    where_clause $category_where_clause
	}
	year {}
	month {}
	day {}
    } -elements {
	title {
	    label "[_ invoices.iv_invoice_item_Title]:"
	    display_template {
		<if @reports:rowcount@ eq 1>
		    @reports.title@
		    <if @reports.iv_items@ not eq 0>
		         <if "$return_url" eq "$base_url">
		             (<a href="${return_url}?show_p=t">@reports.iv_items@</a>)
		         </if>
		         <else>
		             (<a href="${return_url}&show_p=t">@reports.iv_items@</a>)
		         </else>
		    </if>
		    <else>
		    (@reports.iv_items@)
		    </else>
		</if>
		<else>
		    @reports.title@
		</else>
	    }
	}
	creation_date {
	    label "[_ invoices.Creation_Date]:"
	}
	amount_total {
	    label "[_ invoices.Amount_total]"
	}
    }



template::multirow create reports iv_items title creation_date amount_total offer_item_id category_id

set iv_items [db_list_of_lists get_iv_items { }]

if { [exists_and_not_null year] && [exists_and_not_null month] && [exists_and_not_null day] || $show_p} {
    # We get only the projects that match the exact date
    foreach item $iv_items {
        set iv_item_id    [lindex $item 0]
        set title         [lindex $item 1]
        set creation_date [lindex $item 2]
	set iv_item_total [lindex $item 3]
	set offer_item_id [lindex $item 4]
	set category_id   [lindex $item 5]
	
	set final_amount  [db_string get_final_amount {} -default 0]

	template::multirow append reports $iv_item_id $title $creation_date $iv_item_total $offer_item_id $category_id

    }
} else {
    # We accumulate the amount_total and the number of iv_invoice_items
    set iv_items_count [llength $iv_items]
    set amount  [db_string get_final_amount {} -default 0]
    if { $iv_items_count > 0 } {
	template::multirow append reports $iv_items_count "[_ invoices.Invoice_Items]" "- - - - - - - - - - -" $amount
    }
}

