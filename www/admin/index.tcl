ad_page_contract {
    Admin Index page.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-07
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set page_title "[_ invoices.admin]"
set context [list]
set categories_url "categories-admin"
set linking_url "linking"
set parameter_url [export_vars -base "/shared/parameters" {{package_id "[ad_conn package_id]"} {return_url [ad_return_url]}}]

ad_return_template
