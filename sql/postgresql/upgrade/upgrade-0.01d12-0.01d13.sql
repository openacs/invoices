begin;
    select acs_privilege__create_privilege('invoice_cancel',null,null);
    select acs_privilege__create_privilege('invoice_export',null,null);

    -- add children
    select acs_privilege__add_child('admin','invoice_cancel');
    select acs_privilege__add_child('admin','invoice_export');
end;
