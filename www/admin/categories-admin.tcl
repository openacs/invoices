ad_page_contract {
    Aministrate category trees.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.admin_categories]"
set context [list $page_title]
set package_id [ad_conn package_id]

set categories_node_id [db_string get_category_node_id {}]
set categories_url [site_node::get_url -node_id $categories_node_id]
array set container_objects [iv::util::get_default_objects -package_id $package_id]

set list_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(list_id)}}]"
set price_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(price_id)}}]"
set cost_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(cost_id)}}]"
set offer_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(offer_id)}}]"
set offer_item_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(offer_item_id)}}]"
set offer_item_title_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(offer_item_title_id)}}]"
set invoice_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(invoice_id)}}]"
set invoice_item_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(invoice_item_id)}}]"
set payment_url "$categories_url[export_vars -base cadmin/one-object {{object_id $container_objects(payment_id)}}]"

ad_return_template
