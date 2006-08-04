ad_page_contract {
    List of Price Lists.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_price_list_2]"
set context [list $page_title]
set package_id [ad_conn package_id]

set actions [list "[_ invoices.iv_price_list_New]" price-list-ae "[_ invoices.iv_price_list_New2]"]

set default_list_id [iv::price_list::get_default_list_id]

template::list::create \
    -name iv_price_list \
    -key list_id \
    -no_data "[_ invoices.None]" \
    -elements {
        title {
	    label {[_ invoices.iv_price_list_1]}
	    link_url_eval {[export_vars -base "price-list" {list_id}]}
            display_template {@iv_price_list.title@<if @iv_price_list.list_id@ eq $default_list_id>*</if>}
        }
        action {
	    display_template {<a href="@iv_price_list.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_price_list.delete_link@">#invoices.Delete#</a>}
	
        }
    } -actions $actions

db_multirow -extend {edit_link delete_link} iv_price_list iv_price_list {} {
    set edit_link [export_vars -base "price-list-ae" {list_id}]
    set delete_link [export_vars -base "price-list-delete" {list_id}]
}

ad_return_template
