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


foreach optional_param {organization_id row_list} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]


#set package_id [ad_conn package_id]
set date_format [lc_get formbuilder_date_format]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

set actions [list "[_ invoices.iv_invoice_New]" [export_vars -base invoice-add {organization_id}] "[_ invoices.iv_invoice_New2]" "[_ invoices.iv_invoice_credit_New]" [export_vars -base invoice-credit {organization_id}] "[_ invoices.iv_invoice_credit_New2]" "[_ invoices.iv_offer_2]" [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]" "[_ invoices.projects]" $pm_base_url "[_ invoices.projects]" "[_ invoices.iv_reports]" [export_vars -base invoice-reports {organization_id}]]

template::list::create \
    -name iv_invoice \
    -key invoice_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	invoice_nr {
	    label {[_ invoices.iv_invoice_invoice_nr]}
	}
        title {
	    label {[_ invoices.iv_invoice_1]}
	    link_url_eval {[export_vars -base "invoice-ae" {invoice_id {mode display}}]}
        }
        description {
	    label {[_ invoices.iv_invoice_Description]}
        }
        total_amount {
	    label {[_ invoices.iv_invoice_total_amount]}
	    display_template {@iv_invoice.total_amount@ @iv_invoice.currency@}
        }
        paid_amount {
	    label {[_ invoices.iv_invoice_paid_amount]}
	    display_template {<if @iv_invoice.paid_currency@ not nil>@iv_invoice.paid_amount@ @iv_invoice.paid_currency@</if>}
        }
	creation_user {
	    label {[_ invoices.iv_invoice_creation_user]}
	    display_template {<a href="@iv_invoice.creator_link@">@iv_invoice.first_names@ @iv_invoice.last_name@</if>}
	}
	creation_date {
	    label {[_ invoices.iv_invoice_creation_date]}
	}
	due_date {
	    label {[_ invoices.iv_invoice_due_date]}
	}
        action {
	    display_template {<if @iv_invoice.cancelled_p@ eq f><a href="@iv_invoice.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_invoice.cancel_link@">#invoices.Cancel#</a></if><if @paid_currency@ nil>&nbsp;<a href="@iv_invoice.delete_link@">#invoices.Delete#</a></if>}
	}
    } -actions $actions -sub_class narrow \
    -orderby {
	default_value invoice_nr
	invoice_nr {
	    label {[_ invoices.iv_invoice_invoice_nr]}
	    orderby {t.invoice_nr}
	    default_direction desc
	}
	title {
	    label {[_ invoices.iv_invoice_1]}
	    orderby_desc {lower(cr.title) desc, t.due_date}
	    orderby_asc {lower(cr.title) asc, t.due_date}
	    default_direction asc
	}
	description {
	    label {[_ invoices.iv_invoice_Description]}
	    orderby_desc {lower(cr.description) desc, t.due_date}
	    orderby_asc {lower(cr.description) asc, t.due_date}
	    default_direction asc
	}
	total_amount {
	    label {[_ invoices.iv_invoice_total_amount]}
	    orderby_desc {t.total_amount desc, t.due_date}
	    orderby_asc {t.total_amount asc, t.due_date}
	    default_direction desc
	}
	paid_amount {
	    label {[_ invoices.iv_invoice_paid_amount]}
	    orderby_desc {t.paid_amount desc, t.due_date}
	    orderby_asc {t.paid_amount asc, t.due_date}
	    default_direction desc
	}
	creation_user {
	    label {[_ invoices.iv_invoice_creation_user]}
	    orderby_desc {lower(p.last_name) desc, lower(p.first_names) desc}
	    orderby_asc {lower(p.last_name) asc, lower(p.first_names) asc}
	    default_direction asc
	}
	creation_date {
	    label {[_ invoices.iv_invoice_creation_date]}
	    orderby {o.creation_date}
	    default_direction desc
	}
	due_date {
	    label {[_ invoices.iv_invoice_due_date]}
	    orderby {t.due_date}
	    default_direction desc
	}
    } -orderby_name orderby -html {width 100%} \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name iv_invoice_paginated \
    -filters {organization_id {}} \
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


db_multirow -extend {creator_link edit_link cancel_link delete_link} iv_invoice iv_invoice {} {
    # Ugly hack. We should find out which contact package is linked
    set creator_link "/contacts/$creation_user"
    set edit_link [export_vars -base "${base_url}invoice-ae" {invoice_id}]
    set cancel_link [export_vars -base "${base_url}invoice-cancellation" {organization_id {parent_id $invoice_rev_id}}]
    set delete_link [export_vars -base "${base_url}invoice-delete" {invoice_id}]
    if {[empty_string_p $total_amount]} {
	set total_amount 0
    }
    set total_amount [format "%.2f" $total_amount]
    if {![empty_string_p $paid_amount]} {
	set paid_amount [format "%.2f" $paid_amount]
    }
}
