set required_param_list [list]
set optional_param_list [list elements base_url package_id no_actions_p page_num orderby format groupby]
set optional_unset_list [list organization_id orderby page_num format groupby]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}


foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

# Quickfix
if {[exists_and_not_null orderby] && $orderby eq "invoice_nr"} {
    set orderby ""
}

if {[empty_string_p $no_actions_p]} {
    set no_actions_p 0
}

if {![exists_and_not_null format]} {
    set format "normal"
}

if {![exists_and_not_null page_size]} {
    set page_size "25"
}

if {[empty_string_p $package_id]} {
    set package_id [apm_package_id_from_key invoices]
}

if {[empty_string_p $base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}


set row_list ""

set org_p 1
if { ![exists_and_not_null organization_id] } {
    set org_p 0
    # append row_list "name {}\n"
    set groupby "name"
}


set return_url "[ad_conn url]?[ad_conn query]"
set p_closed_id [pm::project::default_status_closed]
set t_closed_id [pm::task::default_status_closed]
set contacts_p [apm_package_installed_p contacts]
if { $contacts_p } {
    set contacts_url [apm_package_url_from_key contacts]
}

foreach element $elements {
    append row_list "$element {}\n"
}

# Make sure we don't kill ourself
set new_elements [list] 
foreach element $elements {
    if {$element eq "count_total" || $element eq "count_billed"} {
	# get rid of it
    } else {
	lappend new_elements $element
    }
}

set elements $new_elements

if {[lsearch $elements "count_total"] > -1 || [lsearch $elements "count_billed"] > -1} {
    set query "projects_to_bill2"
} else {
    set query "projects_to_bill"
}

if {$no_actions_p} {
    set actions ""
    set bulk_id_list ""
} else {
    set actions  [list "[_ invoices.iv_invoice_New]" "${base_url}invoice-ae" "[_ invoices.iv_invoice_New2]" "[_ invoices.iv_mass_invoice_New]" "${base_url}mass-invoice" "[_ invoices.iv_mass_invoice_New2]" ]

    set bulk_id_list [list organization_id return_url]
    set row_list "checkbox {}\n $row_list"
}

set normal_actions [list "[_ invoices.iv_invoice_url]" $base_url "[_ invoices.iv_invoice_url2]"]

# Organization filter
if {[exists_and_not_null organization_id]} {
    set organization_where_clause "and p.customer_id = :organization_id"
} else {
    set organization_where_clause ""
}

template::list::create \
    -name projects \
    -key project_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	project_id {
	    label {[_ invoices.iv_invoice_project_id]}
	}
        name {
	    label {[_ invoices.Customer]}
	    display_template {@projects.name;noquote@}
        }
        title {
	    label {[_ invoices.iv_invoice_project_title]}
	    display_template {<a href="@projects.project_link@">@projects.title@</a>}
        }
	recipient {
	    label "[_ invoices.iv_invoice_recipient]"
	    display_template {@projects.recipient;noquote@ }
	}
        description {
	    label {[_ invoices.iv_invoice_project_descr]}
	    display_template {@projects.description;noquote@}
        }
        amount_open {
	    label {[_ invoices.iv_invoice_amount_open]}
	    display_template {@projects.amount_open@ @projects.currency@}
        }
	creation_date {
	    label {[_ invoices.iv_invoice_closed_date]}
	}
    } -bulk_actions $actions \
    -bulk_action_export_vars $bulk_id_list \
    -actions $normal_actions \
    -sub_class narrow \
    -groupby {
	label "[_ invoices.Group_by]:"
	type multivar
	values { {[_ invoices.Customer] { {groupby name } {orderby project_id,asc }}}}
    } -orderby {
	default_value project_id
        name {
	    label {[_ invoices.Customer]}
	    orderby {lower(name)}
	    default_direction asc
        }
	project_id {
	    label {[_ invoices.iv_invoice_project_id]}
	    orderby_desc {lower(name) asc, sub.customer_id asc, sub.project_id desc}
	    orderby_asc {lower(name) asc, sub.customer_id asc, sub.project_id asc}
	    default_direction desc
	}
	title {
	    label {[_ invoices.iv_invoice_project_title]}
	    orderby_desc {lower(r.title) desc, r.item_id}
	    orderby_asc {lower(r.title) asc, r.item_id}
	    default_direction asc
	}
	recipient {
	    label {[_ invoices.iv_invoice_recipient]}
	    orderby_desc {sub.recipient_id desc, r.item_id}
	    orderby_asc {sub.recipient_id, r.item_id}
	    default_direction asc
	}
	description {
	    label {[_ invoices.iv_invoice_project_descr]}
	    orderby_desc {lower(r.description) desc, r.item_id}
	    orderby_asc {lower(r.description) asc, r.item_id}
	    default_direction asc
	}
    } -orderby_name orderby -html {width 100%} \
    -page_size_variable_p 1 \
    -page_size 1000 \
    -page_flush_p 1 \
    -page_query_name projects_to_bill_paginated \
    -filters {
	page_num {}
    } \
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


set time_format "[lc_get d_fmt] %X"
set tot_amount_open 0
set contacts_package_id [apm_package_id_from_key contacts]

db_multirow -extend {project_link recipient currency} projects $query {} {
    set amount_open [format "%.2f" $amount_open]
    set tot_amount_open [expr $tot_amount_open + $amount_open]
    set currency [iv::price_list::get_currency -organization_id $org_id]
    set creation_date [lc_time_fmt $creation_date $time_format]

    if { $contacts_p } {
	set recipient "<a href=\"[contact::url -package_id $contacts_package_id -party_id $recipient_id]\">[contact::name -party_id $recipient_id]</a>"
	set name "<a href=\"[contact::url -package_id $contacts_package_id -party_id $org_id]\">[contact::name -party_id $org_id]</a>"
    } else {
	set recipient [person::name -person_id $recipient_id]
	set name $recipient
    }

    set pm_base_url [apm_package_url_from_id [acs_object::package_id -object_id $project_id]]
    set project_link [export_vars -base "${pm_base_url}one" {{project_item_id $project_id}}]
}
