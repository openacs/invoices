create table iv_journals (
        file_id                 integer
                                constraint iv_journals_pk
                                primary key,
        creation_date           timestamptz
                                constraint iv_journals_date_nn
                                not null
);

create table iv_journal_country_codes (
        iso_code                char(2)
                                constraint iv_journal_country_codes_pk
                                primary key
                                constraint iv_journal_country_codes_iso_code_fk
                                references countries,
        journal_code            varchar(4)
                                constraint iv_journal_country_codes_journal_code_nn
                                not null
);
