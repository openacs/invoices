set required_param_list [list organization_id]
set optional_param_list [list orderby elements base_url package_id]
set optional_unset_list [list]

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

foreach element $elements {
    append row_list "$element {}\n"
}

if {![exists_and_not_null format]} {
    set format "normal"
}
if {![exists_and_not_null orderby]} {
    set orderby ""
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

set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]

set p_closed_id [pm::project::default_status_closed]
set t_closed_id [pm::task::default_status_closed]
set date_format [lc_get formbuilder_date_format]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"
set currency [iv::price_list::get_currency -organization_id $organization_id]
set contacts_url [apm_package_url_from_key contacts]

set actions [list "[_ invoices.iv_invoice_New]" "${base_url}invoice-ae" "[_ invoices.iv_invoice_New2]" ]

template::list::create \
    -name projects \
    -key project_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -pass_properties {currency} \
    -elements {
	project_id {
	    label {[_ invoices.iv_invoice_project_id]}
	}
        name {
	    label {[_ invoices.Customer]}
	    display_template {<a href="@projects.project_link@">@projects.name@</a>}
        }
        title {
	    label {[_ invoices.iv_invoice_project_title]}
	    display_template {<a href="@projects.project_link@">@projects.title@</a>}
        }
        description {
	    label {[_ invoices.iv_invoice_project_descr]}
        }
        amount_open {
	    label {[_ invoices.iv_invoice_amount_open]}
	    display_template {@projects.amount_open@ @currency@}
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
    -bulk_action_export_vars {organization_id} \
    -sub_class narrow \
    -orderby {
	default_value project_id
	project_id {
	    label {[_ invoices.iv_invoice_project_id]}
	    orderby {r.item_id}
	    default_direction desc
	}
	title {
	    label {[_ invoices.iv_invoice_project_title]}
	    orderby_desc {lower(r.title) desc, r.item_id}
	    orderby_asc {lower(r.title) asc, r.item_id}
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


db_multirow -extend {project_link} projects projects_to_bill {} {
    set project_link [export_vars -base "${pm_base_url}one" {{project_item_id $project_id}}]
    set amount_open [format "%.2f" $amount_open]
}
