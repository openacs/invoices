set required_param_list [list portlet_title]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "<b>$required_param is a required parameter.</b>"
    }
}

set portlet_layout [parameter::get -parameter "DefaultPortletLayout"]