set required_param_list [list]
set optional_param_list [list orderby elements base_url package_id page_num]
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

if {![info exists format]} {
    set format "normal"
}
if {![info exists page_size]} {
    set page_size "25"
}
if {![info exists show_filter_p]} {
    set show_filter_p 0
}

if {[exists_and_not_null party_id]} {
    set party_id_where_clause "pi.item_id in ([join [pm::util::assigned_projects -party_id $party_id] ","])"
} else {
    set party_id_where_clause ""
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
    set price_list_id [iv::price_list::get_list_id -organization_id $organization_id]
    if {![info exists actions]} {
	set actions [list "[_ invoices.iv_invoice_2]" [export_vars -base "${base_url}invoice-list" {organization_id}] "[_ invoices.iv_invoice_2]" "[_ invoices.iv_price_list]" [export_vars -base "${base_url}price-list" {{list_id $price_list_id} organization_id}] "[_ invoices.iv_display_price_list]"]

	# We are looking at an organization, try to get the base_url for the Project manager
	set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]

	if {$dotlrn_club_id > 0} {
	    set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
	}

	if {[exists_and_not_null pm_base_url]} {
	    lappend actions "[_ project-manager.Projects]" $pm_base_url "[_ project-manager.Projects]"
	    lappend actions "[_ invoices.Add_offer_project]" "[export_vars -base "${pm_base_url}/add-edit" -url {{customer_id $organization_id} status_id}]" "[_ invoices.Add_offer_project]"
	}
    }
} else {
    set actions ""
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
        }
        comment {
	    label {[_ invoices.iv_offer_comment]}
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
	    display_template {<a href="@iv_offer.contact_link@">@iv_offer.contact_first_names@ @iv_offer.contact_last_name@</a><br>@iv_offer.contact_phone;noquote@}
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
    } -actions $actions -sub_class narrow \
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
	description {
	    label {[_ invoices.iv_offer_Description]}
	    orderby {lower(cr.description)}
	    default_direction asc
	}
	comment {
	    label {[_ invoices.iv_offer_comment]}
	    orderby {lower(t.comment)}
	    default_direction asc
	}
	project_id {
	    label {[_ invoices.iv_offer_project]}
	    orderby {lower(pr.title)}
	    default_direction desc
	}
	project_contact {
	    label {[_ invoices.iv_offer_project_contact]}
	    orderby_desc {lower(p2.last_name) desc, lower(p2.first_names) desc}
	    orderby_asc {lower(p2.last_name) asc, lower(p2.first_names) asc}
	    default_direction asc
	}
	amount_total {
	    label {[_ invoices.iv_offer_amount_total]}
	    orderby {t.amount_total}
	    default_direction desc
	}
	creation_user {
	    label {[_ invoices.iv_offer_creation_user]}
	    orderby_desc {lower(p.last_name) desc, lower(p.first_names) desc}
	    orderby_asc {lower(p.last_name) asc, lower(p.first_names) asc}
	    default_direction asc
	}
	creation_date {
	    label {[_ invoices.iv_offer_creation_date]}
	    orderby {o.creation_date}
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
    -filters {
        organization_id {
            where_clause {t.organization_id = :organization_id}
        }
        project_ids {
            where_clause {$project_where_clause}
        }
        status_id {
            where_clause {pp.status_id = :status_id}
        }
	party_id {
	    where_clause {$party_id_where_clause}
	}
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

multirow foreach iv_offer {
    contact::employee::get -employee_id $contact_id -array contact_data -use_cache
    set contact_phone $contact_data(directphoneno)
}
