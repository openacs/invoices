# author Nils Lohse (nils.lohse@cognovis.de)
# creation-date 2006-08-21
# creation-date 2006-08-22


# if { [exists_and_not_null orderby] }

set today [clock format [clock seconds] -format "%Y-%m-%d"]

if { [exists_and_not_null start_date] } {
    if {[string equal $start_date "YYYY-MM-DD"]} {
	set date_range_start $today
    } else {
	set date_range_start $start_date
    }
} else {
    set date_range_start $today
}

if { [exists_and_not_null end_date] } {
    if {[string equal $end_date "YYYY-MM-DD"]} {
	#set date_range_end $today
	unset -nocomplain date_range_end
    } else {
	set date_range_end $end_date
    }
} else {
    #set date_range_end $today
}

set date_range_clause ""

if { [exists_and_not_null date_range_start] } {
    set date_range 1
    catch { set date_range_start [lc_time_fmt $date_range_start %y-%m-%d] } errMsg
    append date_range_clause " and to_char(p.latest_finish_date,'yy-mm-dd') >= :date_range_start"
}

if { [exists_and_not_null date_range_end] } {
    set date_range 1
    catch { set date_range_end [lc_time_fmt $date_range_end %y-%m-%d] } errMsg
    append date_range_clause " and to_char(p.latest_finish_date,'yy-mm-dd') <= :date_range_end"
}

template::list::create \
    -name report \
    -multirow report \
    -elements {
	title {
	    label {[_ invoices.iv_offer_project]}
	    csv_col title
	}
        customer_name {
            label {[_ invoices.Customer]}
	    csv_col customer_name
        }
	prj_sum {
	    label {[_ invoices.Amount_total]}
	    csv_col prj_sum
	}
    } -formats {
	normal {
            label "[_ logger.Table]"
            layout table
        }
        csv {
            label "[_ logger.CSV]"
            output csv
            page_size 0
        }
    } -filters {
	start_date {}
	end_date {}
    }

db_multirow -extend {prj_sum customer_url} report main_projects {} {
    # was copy&paste (2006/08/22) set customer_url "${contacts_url}$customer_id"
    set allsubs [pm::project::get_all_subprojects -project_item_id $item_id]
    set prj_sum $allsubs
    set prj_and_subs [linsert $allsubs 0 $item_id]
    set total_sum 0
    foreach project_item_id $prj_and_subs { 
	db_foreach get_project_amount_values {} {
	    set total_sum [expr $total_sum + $amount_total]
	}
    }
    set prj_sum [lc_numeric $total_sum]
}

# This spits out the CSV if we happen to be in CSV layout
if {$format eq "csv"} {
    template::list::write_csv -name report
    ad_script_abort
}
