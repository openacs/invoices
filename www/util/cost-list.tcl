ad_page_contract {
    List of Costs.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.iv_cost_2]"
set context [list $page_title]
set package_id [ad_conn package_id]

set actions [list "[_ invoices.iv_cost_New]" cost-ae "[_ invoices.iv_cost_New2]"]

template::list::create \
    -name iv_cost \
    -key cost_id \
    -no_data "[_ invoices.None]" \
    -elements {
        title {
	    label {[_ invoices.iv_cost_1]}
	    link_url_eval {[export_vars -base "cost-ae" {cost_id {mode display}}]}
        }
        action {
	    display_template {<a href="@iv_cost.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_cost.delete_link@">#invoices.Delete#</a>}
	
        }
    } -actions $actions

db_multirow -extend {edit_link delete_link} iv_cost iv_cost {} {
    set edit_link [export_vars -base "cost-ae" {cost_id}]
    set delete_link [export_vars -base "cost-delete" {cost_id}]
}

ad_return_template
    
