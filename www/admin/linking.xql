<?xml version="1.0"?>
<queryset>

<fullquery name="package_pretty_name">
    <querytext>
	select i.pretty_name as package_pretty_name
	from apm_package_version_info i, apm_enabled_package_versions e
	where i.version_id = e.version_id
	and e.package_key = :key
    </querytext>
</fullquery>

<fullquery name="package_instances">
    <querytext>
	select instance_name, package_id
	from apm_packages
	where package_key = :key
    </querytext>
</fullquery>

</queryset>
