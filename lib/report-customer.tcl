set optional_param_list [list]
set optional_unset_list [list country_code type manager_id sector category_id amount_limit]

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


set manager_p [group::member_p -group_name "Account Manager"]
if {$manager_p} {
    set manager_id [ad_conn user_id]
}

set return_url [ad_return_url]
set postal_attribute_id [attribute::id -object_type "organization" -attribute_name "company_address"]
set sector_attribute_id [attribute::id -object_type "organization" -attribute_name "industrysector"]

set start_date_sql ""
set start_date_extra_sql ""
if { $start_date != "YYYY-MM-DD" } {
    # Get all customer invoices starting with start_date
    set start_date_sql [db_map start_date]
    set start_date_extra_sql [db_map start_date_new_customer]
}

set end_date_sql ""
set end_date_extra_sql ""
if { $end_date != "YYYY-MM-DD" } {
    # Get all customer invoices up to and including end_date
    set end_date_sql [db_map end_date]
    set end_date_extra_sql [db_map end_date_new_customer]
}

set extra_sql ""
set sql_query_name all_customer_orders
if { [exists_and_not_null country_code] } {
    append extra_sql [db_map customers_of_country]
}

if { [exists_and_not_null sector] } {
    append extra_sql [db_map customers_of_sector]
}

if { [exists_and_not_null manager_id] } {
    append extra_sql [db_map customers_of_account_manager]
}

if { [exists_and_not_null category_id] } {
    set sql_query_name category_customer_orders
}

if { [exists_and_not_null amount_limit] } {
    if { [exists_and_not_null category_id] } {
	append extra_sql [db_map category_amount_above_limit]
    } else {
	append extra_sql [db_map amount_above_limit]
    }
}

if { [exists_and_not_null type] } {
    set first_date "2006-02-01"
    set customer_group_id [group::get_id -group_name "Customers"]
    append extra_sql [db_map new_customers]
}

set country_options [util::address::country_options]
set sector_options [ams::widget_options -attribute_id $sector_attribute_id]
set type_options [list [list "[_ invoices.report_new_customer]" new]]

set manager_group_id [group::get_id -group_name "Account Manager"]
set manager_options {}
foreach member_id [group::get_members -group_id $manager_group_id] {
    lappend manager_options [list [contact::name -party_id $member_id -reverse_order] $member_id]
}
set manager_options [lsort -dictionary $manager_options]

set category_options {}
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]
set tree_id [lindex [lindex [category_tree::get_mapped_trees $container_objects(offer_item_id)] 0] 0]
set category_tree_name [category_tree::get_name $tree_id]
foreach cat [category_tree::get_tree $tree_id] {
    util_unlist $cat cat_id cat_name
    lappend category_options [list [lang::util::localize $cat_name] $cat_id]
}

template::list::create \
    -name reports \
    -multirow reports \
    -filters {
	year {}
	month {}
	day {}
    } -elements {
	customer_name {
	    label {[_ invoices.Customer]}
	    link_url_col customer_url
	    aggregate count
	    aggregate_label "[_ invoices.Total]:"
	}
	amount_total {
	    label "[_ invoices.Amount_total]"
	    aggregate sum
	    aggregate_label "[_ invoices.Total]:"
	}
	invoice_count {
	    label "[_ invoices.Invoice_count]"
	    aggregate sum
	    aggregate_label "[_ invoices.Total]:"
	}
    } -orderby {
	default_value amount_total
        customer_name {
	    label {[_ invoices.Customer]}
	    orderby {lower(oo.name)}
	    default_direction asc
        }
        amount_total {
	    label "[_ invoices.Amount_total]"
	    orderby {amount_total}
	    default_direction desc
        }
        invoice_count {
	    label "[_ invoices.Invoice_count]"
	    orderby {invoice_count}
	    default_direction desc
        }
    } -filters {
	type {
	    label "[_ invoices.report_customer_type]"
	    values $type_options
	}
	country_code {
	    label "[_ ams.country]"
	    type multival
	    values $country_options
	}
	sector {
	    label "[_ acs-translations.ams_attribute_${sector_attribute_id}_pretty_name]"
	    type multival
	    values $sector_options
	}
	manager_id {
	    label "[_ acs-translations.group_title_${manager_group_id}]"
	    values $manager_options
	    hide_p $manager_p
	}
	category_id {
	    label $category_tree_name
	    type multival
	    values $category_options
	}
	start_date {
	    where_clause $start_date_sql
	}
	end_date {
	    where_clause $end_date_sql
	}
	amount_limit {}
    }


set contacts_url [apm_package_url_from_key contacts]

db_multirow -extend {customer_url} reports $sql_query_name {} {
    set customer_url [export_vars -base "invoice-items" -url {customer_id {groupby "cat_name"} {orderby "cat_name"}}]
}
