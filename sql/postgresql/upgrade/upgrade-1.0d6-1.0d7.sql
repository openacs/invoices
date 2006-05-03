create table iv_joined_invoices (
        file_id                 integer
                                constraint iv_joined_invoices_pk
                                primary key,
        creation_date           timestamptz
                                constraint iv_joined_invoices_date_nn
                                not null
);

insert into iv_joined_invoices (file_id, creation_date) values (0, now());

alter table iv_invoices add column pdf_status varchar(10) default 'new';
alter table iv_invoices add column pdf_file_id integer constraint iv_invoices_pdf_file_fk references cr_items;

update iv_invoices set pdf_status = 'sent';
