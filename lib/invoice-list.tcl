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
} else {
    set package_id [site_node::get_object_id -node_id [site_node::get_node_id -url $base_url]]
}


foreach optional_param {row_list} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset {organization_id} {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

set user_id [ad_conn user_id]
set timestamp_format "YYYY-MM-DD HH24:MI:SS"
set bulk_actions [list "[_ invoices.iv_invoice_send]" "${base_url}invoices-view" "[_ invoices.iv_invoice_send]" "[_ invoices.iv_invoice_pay]" "${base_url}invoice-pay" "[_ invoices.iv_invoice_pay]"]
set invoice_cancel_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege invoice_cancel]
set return_url [ad_return_url]

set actions [list]
if { [info exists organization_id] } {
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
    set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
    if {$invoice_cancel_p} {
	set actions [list "[_ invoices.iv_invoice_New]" [export_vars -base invoice-add {organization_id}] "[_ invoices.iv_invoice_New2]" "[_ invoices.iv_invoice_credit_New]" [export_vars -base invoice-credit {organization_id}] "[_ invoices.iv_invoice_credit_New2]" "[_ invoices.iv_offer_2]" [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]" "[_ invoices.projects]" $pm_base_url "[_ invoices.projects]" "[_ invoices.iv_reports]" [export_vars -base invoice-reports {organization_id}] "[_ invoices.iv_reports]"]
    } else {
	set actions [list "[_ invoices.iv_invoice_New]" [export_vars -base invoice-add {organization_id}] "[_ invoices.iv_invoice_New2]" "[_ invoices.iv_offer_2]" [export_vars -base offer-list {organization_id}] "[_ invoices.iv_offer_2]" "[_ invoices.projects]" $pm_base_url "[_ invoices.projects]" "[_ invoices.iv_reports]" [export_vars -base invoice-reports {organization_id}]]
    }
}

if {$invoice_cancel_p} {
    lappend actions "[_ invoices.iv_journal_check]" "${base_url}journal-check" "[_ invoices.iv_journal_check]"
}

# If the sum was paid, the total_amount should appear green.
# If it was billed, yet not paid, the total amount is red. Otherwise don't bother

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
	    display_template {<a href="@iv_invoice.display_link@">@iv_invoice.title@</if>}
        }
        description {
	    label {[_ invoices.iv_invoice_Description]}
        }
        total_amount {
	    label {[_ invoices.iv_invoice_total_amount]}
	    display_template {<if @iv_invoice.status@ eq "paid"><font color="green"></if><elseif @iv_invoice.status@ eq "billed"><font color="red"></elseif><else><font></else>@iv_invoice.total_amount@ @iv_invoice.currency@</font>}
        }
        paid_amount {
	    label {[_ invoices.iv_invoice_paid_amount]}
	    display_template {<if @iv_invoice.paid_currency@ not nil>@iv_invoice.paid_amount@ @iv_invoice.paid_currency@</if>}
        }
	recipient {
	    label "[_ invoices.iv_invoice_recipient]"
	    display_template "@iv_invoice.recipient;noquote@"
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
	status {
	    label {[_ invoices.iv_invoice_status]}
	    display_template {[_ invoices.iv_invoice_status_@iv_invoice.status@]}
	}
        action {
	    display_template {<if @iv_invoice.status@ eq new><a href="@iv_invoice.edit_link@">#invoices.Edit#</a>&nbsp;</if><else><if @invoice_cancel_p@ true><a href="@iv_invoice.cancel_link@">#invoices.Invoice_Cancel#</a>&nbsp;</if></else><if @iv_invoice.status@ ne billed and @iv_invoice.status@ ne paid><a href="@iv_invoice.delete_link@">#invoices.Delete#</a></if> <a href="@iv_invoice.preview_link@">#invoices.Preview#</a>}
        }
    } -actions $actions -sub_class narrow \
	    -bulk_actions $bulk_actions \
	    -bulk_action_export_vars {return_url} \
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
    -page_flush_p 1 \
    -page_query_name iv_invoice_paginated \
    -pass_properties {invoice_cancel_p} \
    -filters {
	organization_id {
	    where_clause {t.organization_id = :organization_id}
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
set date_format [lc_get d_fmt]
set contacts_p [apm_package_installed_p contacts]

db_multirow -extend {creator_link edit_link display_link cancel_link delete_link preview_link recipient} iv_invoice iv_invoice {} {
    # Ugly hack. We should find out which contact package is linked

    set creation_date [lc_time_fmt $creation_date $time_format]
    set due_date [lc_time_fmt $due_date $date_format]

    set display_link [export_vars -base "${base_url}invoice-ae" {invoice_id {mode display}}]
    set edit_link [export_vars -base "${base_url}invoice-ae" {invoice_id}]
    set cancel_link [export_vars -base "${base_url}invoice-cancellation" {{organization_id $orga_id} {parent_id $invoice_rev_id}}]
    set delete_link [export_vars -base "${base_url}invoice-delete" {invoice_id}]
    set preview_link [export_vars -base "${base_url}invoice-preview" {invoice_id}]
    if {[empty_string_p $total_amount]} {
	set total_amount 0
    }
    set total_amount [format "%.2f" $total_amount]
    if {![empty_string_p $paid_amount]} {
	set paid_amount [format "%.2f" $paid_amount]
    }

    if { $contacts_p } {
	set recipient "<a href=\"[contact::url -party_id $recipient_id]\">[contact::name -party_id $recipient_id]</a>"
	set creator_link "[contact::url -party_id $creation_user]"
    } else {
	set recipient [person::name -person_id $recipient_id]
    }
}
