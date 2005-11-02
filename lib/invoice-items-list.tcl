if {![info exists format]} {
    set format "normal"
}
if {![info exists orderby]} {
    set orderby ""
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

foreach optional_param {organization_id elements} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set user_id [ad_conn user_id]

set dotlrn_club_id [lindex [application_data_link::get_linked \
				-from_object_id $organization_id \
				-to_object_type "dotlrn_club"] 0]

set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key \
					      -package_key "project-manager" \
					      -community_id $dotlrn_club_id]]

set row_list [list]
foreach element $elements {
    lappend row_list [list $element {}]
}

template::list::create \
    -name invoice_items \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements { } \
    -actions  { } \
    -bulk_actions { } \
    -orderby { } \
    -orderby_name orderby \
    -html {width 100%} \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "invoice_items_paginated" \
    -filters { } \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
	csv {
	    label "[_ invoices.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }

db_multirow -extend { } invoice_items invoice_items { } {

}
