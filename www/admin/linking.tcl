ad_page_contract {
    
    Links package instances with invoices
    
    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-07
    @cvs-id $Id$
} {
    {keys:array,optional}
}

set user_id [auth::require_login]
set title "[_ invoices.Link_instances]"
set context [list $title]
set this_package_id [ad_conn package_id]
set package_key [ad_conn package_key]

# todo: get this list from callbacks
set package_key_list [list contacts project-manager]

ad_form -name linking

foreach key $package_key_list {
    if {![db_0or1row package_pretty_name {}]} {
	continue
    }

    set options_list [list [list "" ""]]
    db_foreach package_instances {} {
	set urls [join [site_node::get_url_from_object_id -object_id $package_id] ", "]
	if {[empty_string_p $urls]} {
	    set urls "[_ invoices.Unmounted]"
	}

	lappend options_list [list "$instance_name ($urls)" $package_id]
    }

    set current_link [lindex [application_link::get_linked -from_package_id $this_package_id -to_package_key $key] 0]
    regsub -all -- {-} $key {_} key

    ad_form -extend -name linking -form [list [list keys.$key\:text(select) [list label $package_pretty_name] [list options $options_list] [list value $current_link]]]
}

ad_form -extend -name linking -on_request {
} -on_submit {
    db_transaction {
	application_link::delete_links -package_id $this_package_id

	foreach one_key [array names keys] {
	    set target_package_id $keys($one_key)

	    if {![empty_string_p $target_package_id]} {
		application_link::new -this_package_id $this_package_id -target_package_id $target_package_id
	    }
	}
    }
} -after_submit {
    ad_returnredirect .
    ad_script_abort
}

ad_return_template
