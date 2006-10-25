# status_ids: List of status_ids which should be displayed in the project
# if set to "", all project status are displayed. If not provided the status_id parameter is used.

set required_param_list [list]
set optional_param_list [list orderby elements base_url package_id page_num subproject_p export_vars]

set optional_unset_list [list organization_id party_id]


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

#set status_id 2
# db_1row get_offer_status_id {}
if {![info exists status_id]} {
    db_1row get_offer_status_id {}
}

if {[info exists status_ids]} {
    if {$status_ids eq ""} {
	set status_ids_where_clause ""
	unset status_id
    } else {
	set status_ids_where_clause "pp.status_id in ([join $status_ids ","])"
	unset status_id
    }
} else {
    set status_ids_where_clause ""
    set status_ids ""
}

if {![info exists format]} {
    set format "normal"
}
if {![info exists page_size]} {
    set page_size "25"
}
if {![info exists show_filter_p]} {
    set show_filter_p 0
}

if {$subproject_p == "f"} {
    set subproject_where_clause "cf2.folder_id = pi.parent_id"
    set subproject_from ", cr_folders cf2"
} else {
    set subproject_where_clause ""
    set subproject_from ""
}

set party_id_where_clause ""
if {[exists_and_not_null party_id]} {
    set assigned_projects [pm::util::assigned_projects -party_id $party_id -status_id $status_id]
    lappend assigned_projects 0

    set party_id_where_clause "pi.item_id in ([join $assigned_projects ","])"
}

if {[empty_string_p $package_id]} {
    set package_id [apm_package_id_from_key "invoices"]
}

if {[empty_string_p $base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

set project_where_clause "1 = 1"
if {[exists_and_not_null project_id]} {
    set project_ids $project_id
}

if {[exists_and_not_null project_ids]} {
    set project_where_clause "pi.item_id in ([join $project_ids ,])"
}

foreach element $elements {
    append row_list "$element {}\n"
}

set user_id [ad_conn user_id]
set pm_base_url ""
if {[exists_and_not_null organization_id]} {
}

#set package_id [ad_conn package_id]
set timestamp_format "YYYY-MM-DD HH24:MI:SS"

if {[exists_and_not_null organization_id]} {
    set price_list_id [iv::price_list::get_list_id -organization_id $organization_id -package_id [apm_package_id_from_key invoices]]
    if {![info exists actions]} {
	set actions [list "[_ invoices.iv_invoice_2]" [export_vars -base "${base_url}invoice-list" {organization_id}] "[_ invoices.iv_invoice_2]" "[_ invoices.iv_price_list]" [export_vars -base "${base_url}price-list" {{list_id $price_list_id} organization_id}] "[_ invoices.iv_display_price_list]"]

	# We are looking at an organization, try to get the base_url for the Project manager
	
	set dotlrn_club_id [util_memoize [list lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]]
	
	if {$dotlrn_club_id > 0} {
	    set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]
	} else {
	    set pm_package_id ""
	}
	
	if {$pm_package_id eq ""} {
	    set pm_base_url ""
	} else {
	    set pm_base_url [apm_package_url_from_id $pm_package_id]
	}

	if {[exists_and_not_null pm_base_url]} {
	    lappend actions "[_ project-manager.Projects]" $pm_base_url "[_ project-manager.Projects]"
	    lappend actions "[_ invoices.Add_offer_project]" "[export_vars -base "${pm_base_url}/add-edit" -url {{customer_id $organization_id} status_id}]" "[_ invoices.Add_offer_project]"
	}
    }
} else {
    set actions ""
}
set filters {
    organization_id {
	where_clause {t.organization_id = :organization_id}
    }
    project_ids {
	where_clause {$project_where_clause}
    }
    status_id {
	where_clause {pp.status_id = :status_id}
    }
    status_ids {
	where_clause {$status_ids_where_clause}
    }
    party_id {
	where_clause {$party_id_where_clause}
    }
    subproject_p {
	where_clause {$subproject_where_clause}
    }
    page_num {}
}

foreach export_var $export_vars {
    lappend filters "$export_var"
    lappend filters {}
}

template::list::create \
    -name iv_offer \
    -key offer_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	offer_nr {
	    label {[_ invoices.iv_offer_offer_nr]}
	}
        title {
	    label {[_ invoices.iv_offer_1]}
	    display_template {<a href="@iv_offer.title_link@">@iv_offer.title@</a>}
        }
        description {
	    label {[_ invoices.iv_offer_Description]}
	    display_template {@iv_offer.description;noquote@}
        }
        comment {
	    label {[_ invoices.iv_offer_comment]}
	    display_template {@iv_offer.comment;noquote@}
        }
        project_id {
	    label {[_ invoices.iv_offer_project]}
	    display_template {<if @iv_offer.project_id@ not nil><a href="@iv_offer.project_link@">@iv_offer.project_title@</a></if>}
        }
	project_customer {
	    label {[_ invoices.iv_offer_project_customer]}
	    display_template {<a href="@iv_offer.customer_link@">@iv_offer.customer_name@</a>}
	}
	project_contact {
	    label {[_ invoices.iv_offer_project_contact]}
	    display_template {<a href="@iv_offer.contact_link@">@iv_offer.contact_first_names@ @iv_offer.contact_last_name@</a>&nbsp;<if @iv_offer.contact_phone@ not nil><a href="phone:@iv_offer.contact_phone@"><img src="/resources/invoices/telephone.png" border=0 alt="@iv_offer.contact_phone;noquote@"></a></if>}
	}
        amount_total {
	    label {[_ invoices.iv_offer_amount_total]}
	    display_template {@iv_offer.amount_total@ @iv_offer.currency@}
        }
	creation_user {
	    label {[_ invoices.iv_offer_creation_user]}
	    display_template {<a href="@iv_offer.creator_link@">@iv_offer.first_names@ @iv_offer.last_name@</a>}
	}
	creation_date {
	    label {[_ invoices.iv_offer_creation_date]}
	}
	finish_date {
	    label {[_ invoices.iv_offer_finish_date]}
	}
	accepted_date {
	    label {[_ invoices.iv_offer_accepted_date]}
	}
        action {
	    display_template {<if @iv_offer.status@ eq new><a href="@iv_offer.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_offer.delete_link@">#invoices.Delete#</a></if>}
	}
    } -actions $actions -filters $filters -sub_class narrow \
    -orderby {
	default_value project_id
	offer_nr {
	    label {[_ invoices.iv_offer_offer_nr]}
	    orderby {t.offer_nr}
	    default_direction desc
	}
	title {
	    label {[_ invoices.iv_offer_1]}
	    orderby {lower(cr.title)}
	    default_direction asc
	}
	project_id {
	    label {[_ invoices.iv_offer_project]}
	    orderby {lower(pr.title)}
	    default_direction desc
	}
	project_contact {
	    label {[_ invoices.iv_offer_project_contact]}
	    orderby_desc {contact__name(pp.contact_id) desc}
	    orderby_asc {contact__name(pp.contact_id) asc}
	    default_direction asc
	}
	amount_total {
	    label {[_ invoices.iv_offer_amount_total]}
	    orderby {t.amount_total}
	    default_direction desc
	}
	finish_date {
	    label {[_ invoices.iv_offer_finish_date]}
	    orderby {t.finish_date}
	    default_direction desc
	}
	accepted_date {
	    label {[_ invoices.iv_offer_accepted_date]}
	    orderby {t.accepted_date}
	    default_direction desc
	}
    } -orderby_name orderby \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 1 \
    -page_query_name iv_offer_paginated \
    -bulk_action_export_vars $export_vars \
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

db_multirow -extend {creator_link contact_link edit_link delete_link title_link project_link customer_name customer_link contact_phone} iv_offer iv_offer {} {

    # Ugly hack. We should find out which contact package is linked
    # aso. asf.
    set creator_link "/contacts/$creation_user"
    set contact_link "/contacts/$contact_id"
    set customer_link "/contacts/$customer_id"
    set customer_name [contact::name -party_id $customer_id]
    set edit_link [export_vars -base "${base_url}offer-ae" {offer_id}]
    set title_link [export_vars -base "${base_url}offer-ae" {offer_id {mode display}}]
    set delete_link [export_vars -base "${base_url}offer-delete" {offer_id}]
    
    # Get the base url for the customer
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $customer_id -to_object_type "dotlrn_club"] 0]

    if {$dotlrn_club_id > 0} {
	set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
    }

    set project_link [export_vars -base "${pm_base_url}one" {{project_item_id $project_id}}]

    set creation_date [lc_time_fmt $creation_date $time_format]
    set accepted_date [lc_time_fmt $accepted_date $time_format]
    set finish_date [lc_time_fmt $finish_date $time_format]

}

# If we call this in the db_multirow we run out of database pools...
multirow foreach iv_offer {
    set contact_phone [contact::employee::direct_phone -employee_id $contact_id -format "text"]
}
