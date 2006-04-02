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
    append row_list "name {}\n"
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

if {$no_actions_p} {
    set actions ""
    set bulk_id_list ""
} else {
    set actions [list "[_ invoices.iv_invoice_New]" "${base_url}invoice-ae" "[_ invoices.iv_invoice_New2]" ]
    set bulk_id_list [list organization_id return_url]
    set row_list "checkbox {}\n $row_list"
}

set normal_actions [list "[_ invoices.iv_invoice_url]" $base_url "[_ invoices.iv_invoice_url2]"]


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
        }
        amount_open {
	    label {[_ invoices.iv_invoice_amount_open]}
	    display_template {@projects.amount_open@ @projects.currency@}
        }
	count_total {
	    label {[_ invoices.iv_invoice_count_total]}
	}
	count_billed {
	    label {[_ invoices.iv_invoice_count_billed]}
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
	    orderby_desc {lower(name) asc, sub.customer_id asc, r.item_id desc}
	    orderby_asc {lower(name) asc, sub.customer_id asc, r.item_id asc}
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
        amount_open {
	    label {[_ invoices.iv_invoice_amount_open]}
	    orderby_desc {sub.amount_open desc, r.item_id}
	    orderby_asc {sub.amount_open asc, r.item_id}
	    default_direction desc
        }
	count_total {
	    label {[_ invoices.iv_invoice_count_total]}
	    orderby_desc {total.count_total desc, r.item_id}
	    orderby_asc {total.count_total asc, r.item_id}
	    default_direction desc
	}
	count_billed {
	    label {[_ invoices.iv_invoice_count_billed]}
	    orderby_desc {billed.count_billed desc, total.count_total desc, r.item_id}
	    orderby_asc {billed.count_billed asc, total.count_total asc, r.item_id}
	    default_direction desc
	}
	creation_date {
	    label {[_ invoices.iv_invoice_closed_date]}
	    orderby {sub.creation_date}
	    default_direction desc
	}
    } -orderby_name orderby -html {width 100%} \
    -filters {
	page_num {}
        organization_id {
            where_clause {sub.customer_id = :organization_id}
        }
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

db_multirow -extend {project_link recipient currency} projects projects_to_bill {} {
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
    set dotlrn_club_id [lindex \
			    [application_data_link::get_linked \
				 -from_object_id $org_id \
				 -to_object_type "dotlrn_club"] 0]
    
    set pm_base_url [apm_package_url_from_id \
			 [dotlrn_community::get_package_id_from_package_key \
			      -package_key "project-manager" \
			      -community_id $dotlrn_club_id]]

    set project_link [export_vars -base "${pm_base_url}one" {{project_item_id $project_id}}]
}
