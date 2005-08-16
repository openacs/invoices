ad_page_contract {
    Form to add/edit Cost.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    cost_id:integer,optional
    {__new_p 0}
    {mode edit}
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set has_submit 0
if {![info exists cost_id] || $__new_p} {
    set page_title "[_ invoices.iv_cost_Add]"
    set _cost_id 0
} else {
    if {$mode == "edit"} {
        set page_title "[_ invoices.iv_cost_Edit]"
    } else {
        set page_title "[_ invoices.iv_cost_View]"
        set has_submit 1
    }
    set _cost_id [content::item::get_latest_revision -item_id $cost_id]
}

set context [list [list "cost-list" "[_ invoices.iv_cost_2]"] $page_title]
set package_id [ad_conn package_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]

set language [lang::conn::language]
set organization_options [db_list_of_lists organization_list {}]
set currency_options [db_list_of_lists currencies {}]
set boolean_options [list [list "[_ invoices.yes]" t] [list "[_ invoices.no]" f]]

ad_form -name iv_cost_form -action cost-ae -mode $mode -has_submit $has_submit -form {
    {cost_id:key}
}
    
ad_form -extend -name iv_cost_form -form {
    {title:text {label "[_ invoices.iv_cost_Title]"} {html {size 80 maxlength 1000}} {help_text "[_ invoices.iv_cost_Title_help]"}}
    {description:text(textarea),optional {label "[_ invoices.iv_cost_Description]"} {html {rows 5 cols 80}} {help_text "[_ invoices.iv_cost_Description_help]"}}
}
	
if {![empty_string_p [category_tree::get_mapped_trees $container_objects(cost_id)]]} {
    category::ad_form::add_widgets -container_object_id $container_objects(cost_id) -categorized_object_id $_cost_id -form_name iv_cost_form
}

ad_form -extend -name iv_cost_form -form {
    {cost_nr:text {label "[_ invoices.iv_cost_cost_nr]"} {html {size 80 maxlength 200}} {help_text "[_ invoices.iv_cost_cost_nr_help]"}}
    {organization_id:text(select),optional {label "[_ invoices.iv_cost_organization]"} {options $organization_options} {help_text "[_ invoices.iv_cost_organization_help]"}}
    {cost_object_id:integer,optional {label "[_ invoices.iv_cost_object_id]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_cost_object_id_help]"}}
    {item_units:integer,optional {label "[_ invoices.iv_cost_item_units]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_cost_item_units_help]"}}
    {price_per_unit:integer {label "[_ invoices.iv_cost_price_per_unit]"} {html {size 10 maxlength 10}} {help_text "[_ invoices.iv_cost_price_per_unit_help]"}}
    {currency:text(select),optional {label "[_ invoices.iv_cost_currency]"} {options $currency_options} {help_text "[_ invoices.iv_cost_currency_help]"}}
    {apply_vat_p:text(select),optional {label "[_ invoices.iv_cost_apply_vat_p]"} {options $boolean_options} {help_text "[_ invoices.iv_cost_apply_vat_p_help]"}}
    {variable_cost_p:text(select) {label "[_ invoices.iv_cost_variable_cost_p]"} {options $boolean_options} {help_text "[_ invoices.iv_cost_variable_cost_p_help]"}}
} -new_request {
    set title ""
    set description ""
    set cost_nr ""
    set organization_id ""
    set cost_object_id ""
    set item_units ""
    set price_per_unit ""
    set currency ""
    set apply_vat_p "t"
    set variable_cost_p "t"
} -edit_request {
    db_1row get_data {}
} -on_submit {
    set category_ids [category::ad_form::get_categories -container_object_id $container_objects(cost_id)]
} -new_data {
    db_transaction {
	set new_cost_rev_id [iv::cost::new  \
				 -title $title \
				 -description $description  \
				 -cost_nr $cost_nr \
				 -organization_id $organization_id \
				 -cost_object_id $cost_object_id \
				 -item_units $item_units \
				 -price_per_unit $price_per_unit \
				 -currency $currency \
				 -apply_vat_p $apply_vat_p \
				 -variable_cost_p $variable_cost_p ]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_cost_rev_id $category_ids
	}
    }
} -edit_data {
    db_transaction {
	set new_cost_rev_id [iv::cost::edit \
				 -cost_item_id $cost_id \
				 -title $title \
				 -description $description  \
				 -cost_nr $cost_nr \
				 -organization_id $organization_id \
				 -cost_object_id $cost_object_id \
				 -item_units $item_units \
				 -price_per_unit $price_per_unit \
				 -currency $currency \
				 -apply_vat_p $apply_vat_p \
				 -variable_cost_p $variable_cost_p ]

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $new_cost_rev_id $category_ids
	}
    }
} -after_submit {
    ad_returnredirect cost-list
    ad_script_abort
}

ad_return_template
