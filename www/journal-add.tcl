ad_page_contract {
    Export invoices and changes in customer data

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2006-01-27
} {
}

set user_id [auth::require_login]
set ip_addr [ad_conn peeraddr]
set folder_id [parameter::get -parameter "JournalFolderID"]
acs_object::get -object_id $folder_id -array folder
set fs_package_id $folder(package_id)
set fs_package_url [site_node::get_url_from_object_id -object_id $fs_package_id]

db_1row last_checkout {}
db_1row today {}
set date_format [lc_get d_fmt]
set today_pretty [lc_time_fmt $today_pretty $date_format]

db_foreach country_codes {} {
    set country_codes($iso_code) $journal_code
}

########
# customer changes
########

set customer_group_id [group::get_id -group_name "Customers"]
set new_customers [db_list_of_lists new_customers {}]

set orga_ids {}
set customer_text ""
foreach recipient_id $new_customers {

    if {[person::person_p -party_id $recipient_id]} {
	# recipient is person, so get employer organization
	set organization_id [lindex [lindex [contact::util::get_employers -employee_id $recipient_id] 0] 0]
    } else {
	# recipient is organization
	set organization_id $recipient_id
    }

    if {[lsearch -exact $orga_ids $organization_id] > -1} {
	continue
    } else {
	lappend orga_ids $organization_id
    }

    set email [party::email -party_id $organization_id]
    set orga_revision_id [content::item::get_best_revision -item_id $organization_id]
    contacts::postal_address::get -attribute_name "company_address" -party_id $organization_id -array address_array

    if {[exists_and_not_null address_array(postal_code)]} {
	set zip_code [string trim $address_array(postal_code)]
    } else {
	set zip_code ""
    }

    set client_id [ams::value -attribute_name "client_id" -object_id $orga_revision_id]

    if {[empty_string_p $client_id]} {
	# dont list customers without client_id
	continue
    }

    set company_name [string trim [ams::value -attribute_name "name" -object_id $orga_revision_id]]
    set company_name_ext [string trim [ams::value -attribute_name "company_name_ext" -object_id $orga_revision_id]]
    set payment_days [string trim [ams::value -attribute_name "payment_days" -object_id $orga_revision_id]]
    set ust_id_nr [string trim [ams::value -attribute_name "VAT_ident_number" -object_id $orga_revision_id]]
    set company_phone [string trim [ams::value -attribute_name "company_phone" -object_id $orga_revision_id]]
    set company_fax [string trim [ams::value -attribute_name "company_fax" -object_id $orga_revision_id]]

    regexp {<a href=[^>]+>([^<]+)</a>} $company_phone match company_phone
    regexp {<a href=[^>]+>([^<]+)</a>} $company_fax match company_fax

    # country_code
    if {[exists_and_not_null address_array(country_code)]} {
	set country_code [string trim $country_codes($address_array(country_code))]
    } else {
	set country_code ""
    }

    if {[exists_and_not_null address_array(municipality)]} {
	set municipality [string trim [string range $address_array(municipality) 0 39]]
    } else {
	set municipality ""
    }

    if {[exists_and_not_null address_array(delivery_address)]} {
	set address [string trim [string range $address_array(delivery_address) 0 39]]
    } else {
	set address ""
    }

    set company_name [string trim [string range $company_name 0 34]]
    set company_name_ext [string trim [string range $company_name_ext 0 39]]
    set zip_and_municipality [string range "$zip_code $municipality" 0 34]
    set email [string range $email 0 49]
    array unset address_array

    set new_line "S;0;D;$client_id;;$company_name;$zip_and_municipality;$ust_id_nr;1200;;;;0;;;$payment_days Tage netto;;;0;;;;;;;;$company_name;$company_name_ext;;$address;$zip_code;$municipality;;;;$company_phone;$company_fax;;;;;;;;;;;;$email;;$country_code"

    set new_line [string map {{&amp;} {&} {\n} {} {\x0a} {}} $new_line]

    append customer_text "$new_line\n"
}

########
# invoices
########

set new_invoices [db_list_of_lists new_invoices {}]

set financial_text ""
foreach invoice $new_invoices {

    util_unlist $invoice invoice_nr parent_invoice_id recipient_id total_amount currency payment_days vat vat_percent invoice_period invoice_name invoice_date

    if {[person::person_p -party_id $recipient_id]} {
	# recipient is person, so get employer organization
	set organization_id [lindex [lindex [contact::util::get_employers -employee_id $recipient_id] 0] 0]
    } else {
	# recipient is organization
	set organization_id $recipient_id
    }

    set orga_revision_id [content::item::get_best_revision -item_id $organization_id]
    contacts::postal_address::get -attribute_name "company_address" -party_id $organization_id -array address_array
    set client_id [string trim [ams::value -attribute_name "client_id" -object_id $orga_revision_id]]
    set ust_id_nr [string trim [ams::value -attribute_name "VAT_ident_number" -object_id $orga_revision_id]]
    set invoice_name [string range $invoice_name 0 29]
    set invoice_type "AR"
    set final_amount [lc_numeric [format "%.2f" [expr $total_amount + $vat]]]
    if {$total_amount < 0 || ![string eq $parent_invoice_id ""]} {
	# use AG for cancellations and credit
	set invoice_type "AG"
    }

    if {![string eq $parent_invoice_id ""]} {
	db_1row parent_invoice_nr {}
	set invoice_name "Storno Beleg $parent_invoice_nr"
    } elseif {$total_amount < 0} {
	set invoice_name "Gutschrift"
    } else {
	set invoice_name "Ausgangsrechnung"
    }

    # country_code
    if {[exists_and_not_null address_array(country_code)]} {
	set country_code $country_codes($address_array(country_code))
    } else {
	set country_code ""
    }
    array unset address_array

    if {![empty_string_p $vat_percent] && $vat_percent > 0} {
	set tax_account 4410
	set tax_type 40
    } else {
	set tax_account 4690
	set tax_type 10
	set final_amount $total_amount
    }

    append financial_text "F;0;940;;;$invoice_type;$invoice_date;$invoice_period;$invoice_nr;;$client_id;$tax_account;$tax_type;;$final_amount;$invoice_name;;;$currency;$country_code;$ust_id_nr;;;0;0\n"
}

########
# journal
########

set new_invoices [db_list_of_lists new_invoice_journal {}]

set total_sum 0.
set vat_sum 0.
set final_sum 0.
set journal_text ""
set journal_text2 "<html><body><h2>Rechnungsbuch $today_pretty</h2>\n<table width=100%>\n<tr><th align=left>Rechnung&nbsp;&nbsp;</th><th align=left>Datum&nbsp;&nbsp;</th><th align=left>Kunde&nbsp;&nbsp;</th><th align=left>Netto&nbsp;&nbsp;</th><th align=left>MWSt&nbsp;&nbsp;</th><th align=left>Brutto&nbsp;&nbsp;</th><th align=left>W&auml;hrung</th></tr>\n"
foreach invoice $new_invoices {

    util_unlist $invoice invoice_nr recipient_id total_amount currency amount_sum vat invoice_date

    if {[person::person_p -party_id $recipient_id]} {
	# recipient is person, so get employer organization
	set organization_id [lindex [lindex [contact::util::get_employers -employee_id $recipient_id] 0] 0]
    } else {
	# recipient is organization
	set organization_id $recipient_id
    }

    set orga_revision_id [content::item::get_best_revision -item_id $organization_id]
    set client_id [ams::value -attribute_name "client_id" -object_id $orga_revision_id]
    set final_amount [format "%.2f" [expr $total_amount + $vat]]

    set total_sum [expr $total_sum + $total_amount]
    set vat_sum [expr $vat_sum + $vat]
    set final_sum [expr $final_sum + $final_amount]

    set final_amount [lc_numeric $final_amount]
    set vat [lc_numeric $vat]
    set total_amount [lc_numeric $total_amount]
    set invoice_date [lc_time_fmt $invoice_date $date_format]

    append journal_text "$invoice_nr,$invoice_date,$client_id,$total_amount,$vat,$final_amount,$currency\n"
    append journal_text2 "<tr><td align=left>$invoice_nr</td><td align=left>$invoice_date</td><td align=left>$client_id</td><td align=left>$total_amount</td><td align=left>$vat</td><td align=left>$final_amount</td><td align=left>$currency</td></tr>\n"
}

set total_sum [lc_numeric [format "%.2f" $total_sum]]
set vat_sum [lc_numeric [format "%.2f" $vat_sum]]
set final_sum [lc_numeric [format "%.2f" $final_sum]]

append journal_text2 "<tr><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td></tr>\n"
append journal_text2 "<tr><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left>&nbsp;</td><td align=left><b>$total_sum</b></td><td align=left><b>$vat_sum</b></td><td align=left><b>$final_sum</b></td><td align=left>&nbsp;</td></tr>\n"
append journal_text2 "</table></body></html>"

set data(customer) $customer_text
set data(financial) $financial_text
set data(journal) $journal_text2

######
# create zip
######

# create tmp-folder for zip
set tmp_path [ns_mktemp]
file mkdir $tmp_path
set zip_path [ns_mktemp]
file mkdir $zip_path
set zip_file_id [db_nextval acs_object_id_seq]
set item_name "journal_${today}.zip"
set file_mime_type [cr_filename_to_mime_type -create zip]
set zip_file [file join ${zip_path} $item_name]
set zip_bin "/usr/bin/zip"
set cmd "exec $zip_bin -j $zip_file"

foreach type [array names data] {
    switch $type {
	customer {
	    set filename "debitoren"
	    set extension "s"
	}
	financial {
	    set filename "fibu"
	    set extension "ER2"
	}
	journal {
	    set filename "journal"
	    set extension "html"
	}
    }
    set file "${tmp_path}/${filename}_${today}.${extension}"
    set f [open $file w]
    fconfigure $f -encoding iso8859-1
    puts $f $data($type)
    flush $f
    close $f
    append cmd " \"$file\""
}

# create zip-file
catch { eval $cmd } errmsg

fs::add_file \
    -name $item_name \
    -item_id $zip_file_id \
    -parent_id $folder_id \
    -tmp_filename $zip_file \
    -creation_user $user_id \
    -creation_ip $ip_addr \
    -title $item_name \
    -package_id $fs_package_id \
    -mime_type $file_mime_type \
    -no_callback

exec rm -rf $tmp_path
exec rm -rf $zip_path

db_dml mark_journal_creation {}

ad_returnredirect [export_vars -base "${fs_package_url}index" {folder_id {orderby name,desc}}]
