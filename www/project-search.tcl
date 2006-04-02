ad_page_contract {
    Page to redirect to project.

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-06
} {
    project_id
}

set match_projects [db_list_of_lists get_projects { }]
set match_length [llength $match_projects]

if { [string equal $match_length 0] } {
    # No Match just redirect
    ad_returnredirect $return_url

} else {
    set project_item_id [lindex [lindex $match_projects 0] 0]
    set object_package_id [lindex [lindex $match_projects 0] 2]
	
    # We get the node_id from the package_id and use it 
    # to get the url of the project-manager
    set pm_node_id [site_node::get_node_id_from_object_id -object_id $object_package_id]
    set pm_url [site_node::get_url -node_id $pm_node_id]
    
    # Just redirect to the pm_url and project_item_id
    ad_returnredirect "${pm_url}one?project_item_id=$project_item_id"
}
