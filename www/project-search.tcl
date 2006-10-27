ad_page_contract {
    Page to redirect to project.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    project_id
    {return_url "/invoices"}
}

set pm_url  "[pm::project::search_url -keyword $project_id]"

if {$pm_url eq ""} {
    set pm_url $return_url
}
ad_returnredirect $pm_url

