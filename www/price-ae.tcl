ad_page_contract {
    Form to add/edit Price.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    amounts:float,array,optional
    {list_id:notnull}
    {__new_p 0}
    {mode edit}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set has_submit 0
if {$mode != "edit"} {
    set has_submit 1
}

set language [lang::conn::language]
db_1row list_data {}
set page_title "[_ invoices.iv_price_Edit]"
set context [list [list "price-list-list" "[_ invoices.iv_price_list_2]"] [list [export_vars -base price-list {list_id}] $list_title] $page_title]
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]


ad_form -name iv_prices_form -action price-ae -mode $mode -has_submit $has_submit -form {
    {list_id:key}
}

set category_list [list]
foreach tree [category_tree::get_mapped_trees $container_objects(price_id)] {
    util_unlist $tree tree_id tree_name subtree_id

    foreach cat [category_tree::get_tree -all -subtree_id $subtree_id $tree_id] {
	util_unlist $cat category_id category_name deprecated_p level

	lappend category_list $category_id
	set category_data($category_id) [list $tree_id $tree_name $category_name $level]
    }
}

db_foreach all_prices {} {
    if {[info exists category_data($category_id)]} {
	lappend category_data($category_id) $amount
    }
}

foreach category_id $category_list {
    util_unlist $category_data($category_id) tree_id tree_name category_name level amount

    if {$level > 1} {
	set category_name "[string repeat ".." [expr {2 * $level - 2}]]$category_name"
    }

    if {[empty_string_p $amount]} {
	set amount "0.00"
    }

    ad_form -extend -name iv_prices_form -form \
	[list [list "amounts.${category_id}:float" \
		   [list label $category_name] \
		   [list html [list size 10 maxlength 10]] \
		   [list value [format "%.2f" $amount]] \
		   [list after_html $currency_name] \
		   [list section $tree_name] ] ]
}

ad_form -extend -name iv_prices_form -edit_request {
} -edit_data {
    db_transaction {
	db_foreach old_prices {} {
	    set old_price($category_id) $item_id
	}

	db_dml invalidate_prices {}

	foreach category_id [array names amounts] {
	    if {[info exists old_price($category_id)]} {
		# new revision of old price
		set new_price_rev_id [iv::price::edit \
					  -price_item_id $old_price($category_id)  \
					  -list_id $list_id \
					  -category_id $category_id \
					  -amount $amounts($category_id) ]
	    } else {
		# new price
		set new_price_rev_id [iv::price::new \
					  -list_id $list_id \
					  -category_id $category_id \
					  -amount $amounts($category_id) ]
	    }
	}
    }
} -after_submit {
    ad_returnredirect [export_vars -base price-list {list_id}]
    ad_script_abort
}

ad_return_template
