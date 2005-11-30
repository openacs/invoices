ad_page_contract {
    Index page.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
} -properties {
    context:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]

set page_title "[_ invoices.invoices]"
set context [list]

ad_return_template
