set package_id [ad_conn package_id]
set language [lang::conn::language]
db_1row currency {}
array set container_objects [iv::util::get_default_objects -package_id $package_id]

set actions [list "[_ invoices.iv_price_Edit]" [export_vars -base "price-ae" {list_id}] "[_ invoices.iv_price_Edit]"]

template::list::create \
    -name iv_price \
    -key category_id \
    -no_data "[_ invoices.None]" \
    -pass_properties {list_id currency} \
    -elements {
        category_name {
	    label {[_ invoices.iv_price_category_id]}
	    display_template {@iv_price.category_name;noquote@}
        }
	amount {
	    label {[_ invoices.iv_price_amount]}
	    display_template {@iv_price.amount@ @currency@}
	}
    } -actions $actions


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

multirow create iv_price category_id tree_name category_name amount
set old_tree_id ""

foreach category_id $category_list {
    util_unlist $category_data($category_id) tree_id tree_name category_name level amount

    if {$old_tree_id == $tree_id} {
	set tree_name ""
    }
    set old_tree_id $tree_id

    if {$level > 1} {
	set category_name "[string repeat "&nbsp;" [expr {2 * $level - 4}]]..$category_name"
    }
    if {[empty_string_p $amount]} {
	set amount "0.00"
    }
    set amount [format "%.2f" $amount]

    multirow append iv_price $category_id $tree_name $category_name $amount
}
