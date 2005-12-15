--
-- Invoices Package
--
-- @author Timo Hentschel (timo@timohentschel.de)
-- @creation-date 2005-06-06
--

-- title, description
-- linked organization

create table iv_price_lists (
        list_id                 integer
                                constraint iv_price_lists_pk
                                primary key
                                constraint iv_price_lists_id_fk
                                references cr_revisions,
        currency                char(3)
                                constraint iv_prices_currency_fk
                                references currencies(codeA),
        credit_percent          numeric(12,5) default 0
                                -- %credit
);

create index iv_price_lists_currency_idx on iv_price_lists(currency);

create table iv_prices (
        price_id                integer
                                constraint iv_prices_pk
                                primary key
                                constraint iv_prices_id_fk
                                references cr_revisions,
        list_id                 integer
                                constraint iv_prices_list_fk
                                references cr_items,
        category_id             integer
                                constraint iv_prices_category_fk
                                references categories,
        amount                  numeric(12,3)
);

-- categories: type, vat_type
-- use general comments
-- title, description

create table iv_costs (
        cost_id                 integer
                                constraint iv_costs_pk
                                primary key
                                constraint iv_costs_fk
                                references cr_revisions,
        cost_nr                 varchar(400)
                                constraint iv_costs_nr_nn
                                not null,
                                -- Nr is a current number to provide a unique 
                                -- identifier of cost item for backup/restore.
        organization_id         integer
                                constraint iv_costs_organization_nn
                                not null
                                constraint iv_costs_organization_fk
                                references organizations,
                                -- who pays?
        cost_object_id          integer
                                constraint im_costs_object_fk
                                references acs_objects,
                                -- reference to object that caused this cost
        item_units              numeric(12,1),
        price_per_unit          numeric(12,3),
        currency                char(3) 
                                constraint iv_costs_currency_fk
                                references currencies(codeA),
        apply_vat_p             char(1) default 't'
                                constraint iv_costs_apply_vat_p
                                check (apply_vat_p in ('t','f')),
                                -- include in VAT calculation?
        variable_cost_p         char(1)
                                constraint iv_costs_var_ck
                                check (variable_cost_p in ('t','f'))
                                -- variable or fixed costs
				-- A variable cost is calculated by multiplying
				-- with logger units. A fixed cost a fixed single amount
);

create index iv_costs_object_idx on iv_costs(cost_object_id);
create index iv_costs_organization_idx on iv_costs(organization_id);
create index iv_costs_currency_idx on iv_costs(currency);

create sequence iv_offer_seq start with 1000;

create table iv_offers (
        offer_id                integer
                                constraint iv_offers_pk
                                primary key
                                constraint iv_offers_id_fk
                                references cr_revisions,
        offer_nr                varchar(80),
        organization_id         integer not null
                                constraint iv_offers_organization_fk
                                references organizations,
                                -- who pays?
        comment                 text,
        amount_total            numeric(12,2),
        amount_sum              numeric(12,2),
        currency                char(3)
                                constraint iv_offers_currency_fk
                                references currencies(codeA),
        finish_date             timestamptz,
        date_comment            varchar(1000),
        payment_days            integer,
        vat_percent             numeric(12,5) default 0,
                                -- %VAT
        vat                     numeric(12,2) default 0,
                                -- VAT amount
        credit_percent          numeric(12,5) default 0,
                                -- %credit
        status                  varchar(10) default 'new',
                                -- new, accepted, billed, credit
        accepted_date           timestamptz
                                -- offer accepted by customer?
);

-- offers are linked to a project via cr_items.parent_id
-- if it's a preliminary offer, it's linked to the customer project
-- if it's a final project, it's linked to the actual project

create index iv_offers_organization_idx on iv_offers(organization_id);
create index iv_offers_currency_idx on iv_offers(currency);
create index iv_offers_finish_idx on iv_offers(finish_date);
create index iv_offers_accepted_idx on iv_offers(accepted_date);

create table iv_offer_items (
        offer_item_id           integer
                                constraint iv_offer_items_pk
                                primary key
                                constraint iv_offers_items_id_fk
                                references cr_revisions,
        item_nr                 varchar(200),
        offer_id                integer not null 
                                constraint iv_offer_items_offer_fk
                                references iv_offers,
        comment                 text,
        item_units              numeric(12,1),
        price_per_unit          numeric(12,3),
        rebate                  numeric(12,2),
        file_count              integer,
        page_count              integer,
        sort_order              integer,
        vat                     numeric(12,3) default 0,
                                -- VAT amount
        parent_item_id          integer
                                constraint iv_offer_items_parent_fk
                                references iv_offer_items
                                -- Points to its parent
);

create index iv_offer_items_offer_idx on iv_offer_items(offer_id);
create index iv_offer_items_sort_idx on iv_offer_items(sort_order);
create index iv_offer_items_parent_idx on iv_offer_items(parent_item_id);

-- linked file (for the real invoice)
-- categories: payment_method
-- title, description
-- should we link organization here?

create sequence iv_invoice_seq start with 1000;

create table iv_invoices (
        invoice_id              integer
                                constraint iv_invoices_pk
                                primary key
                                constraint iv_invoices_id_fk
                                references cr_revisions,
        invoice_nr              varchar(80),
        parent_invoice_id       integer
                                constraint iv_invoices_parent_id_fk
                                references iv_invoices,
                                -- to reference a storno,
        organization_id         integer not null
                                constraint iv_invoices_organization_fk
                                references organizations,
                                -- who pays?
        recipient_id            integer not null
                                constraint iv_invoices_recipient_fk
                                references parties,
                                -- who receives invoice?
        total_amount            numeric(12,2),
        amount_sum              numeric(12,2),
        currency                char(3)
                                constraint iv_invoices_currency_fk
                                references currencies(codeA),
        paid_amount             numeric(12,2),
                                -- coming from table iv_payments
        paid_currency           char(3)
                                constraint iv_invoices_paid_currency_fk
                                references currencies(codeA),
        due_date                timestamptz,
        payment_days            integer,
        vat_percent             numeric(12,5) default 0,
                                -- %VAT
        vat                     numeric(12,2) default 0,
                                -- VAT amount
        status                  varchar(10) default 'new',
                                -- new, cancelled, billed, paid
        cancelled_p             char(1) default 'f'
                                constraint iv_invoices_cancelled_p
                                check (cancelled_p in ('t','f'))
                                -- is this invoice already cancelled?
);

create index iv_invoices_parent_idx on iv_invoices(parent_invoice_id);
create index iv_invoices_organization_idx on iv_invoices(organization_id);
create index iv_invoices_recipient_idx on iv_invoices(recipient_id);
create index iv_invoices_currency_idx on iv_invoices(currency);
create index iv_invoices_paid_currency_idx on iv_invoices(paid_currency);
create index iv_invoices_due_idx on iv_invoices(due_date);

-- linked project_item_id
-- categories: type, status
-- title, description

create table iv_invoice_items (
        iv_item_id              integer
                                constraint iv_invoice_items_pk
                                primary key
                                constraint iv_invoice_items_id_fk
                                references cr_revisions,
        item_nr                 varchar(200),
        invoice_id              integer not null 
                                constraint iv_invoice_items_invoice_fk
                                references iv_invoices,
        offer_item_id           integer
                                constraint iv_invoice_items_offer_fk
                                references iv_offer_items,
        item_units              numeric(12,1),
        price_per_unit          numeric(12,3),
        rebate                  numeric(12,2),
        amount_total            numeric(12,2),
        sort_order              integer,
        vat                     numeric(12,3) default 0,
                                -- VAT amount
        parent_item_id          integer
                                constraint iv_invoice_items_parent_fk
                                references iv_invoice_items
                                -- Points to its parent
);

create index iv_invoice_items_invoice_idx on iv_invoice_items(invoice_id);
create index iv_invoice_items_offer_idx on iv_invoice_items(offer_item_id);
create index iv_invoice_items_parent_idx on iv_invoice_items(parent_item_id);

-- categories type, status
-- with general comments
-- title, description
-- should we link organization here?

create table iv_payments (
        payment_id              integer not null 
                                constraint iv_payments_pk
                                primary key
                                constraint iv_payments_id_fk
                                references cr_revisions,
        invoice_id              integer
                                constraint iv_payments_invoice_fk
                                references iv_invoices,
                                -- what is paid?
        organization_id         integer not null
                                constraint iv_payments_organization_fk
                                references organizations,
                                -- who pays?
        received_date           timestamptz,
        amount                  numeric(12,2),
        currency                char(3) 
                                constraint iv_payments_currency_fk
                                references currencies(codeA)
);

create index iv_payments_invoice_idx on iv_payments(invoice_id);
create index iv_payments_organization_idx on iv_payments(organization_id);
create index iv_payments_currency_idx on iv_payments(currency);
create index iv_payments_date_idx on iv_payments(received_date);

create table iv_default_objects (
        package_id              integer
                                constraint iv_default_objects_pk
                                primary key
                                constraint iv_default_objects_fk
                                references apm_packages,
        list_id                 integer
                                constraint iv_default_objects_list_fk
                                references acs_objects,
        price_id                integer
                                constraint iv_default_objects_price_fk
                                references acs_objects,
        cost_id                 integer
                                constraint iv_default_objects_cost_fk
                                references acs_objects,
        offer_id                integer
                                constraint iv_default_objects_offer_fk
                                references acs_objects,
        offer_item_id           integer
                                constraint iv_default_objects_offer_item_fk
                                references acs_objects,
        offer_item_title_id     integer
                                constraint iv_default_objects_offer_title_fk
                                references acs_objects,
        invoice_id              integer
                                constraint iv_default_objects_invoice_fk
                                references acs_objects,
        invoice_item_id         integer
                                constraint iv_default_objects_invoice_item_fk
                                references acs_objects,
        payment_id              integer
                                constraint iv_default_objects_payment_fk
                                references acs_objects
);


begin;
    select acs_privilege__create_privilege('invoice_cancel',null,null);
    select acs_privilege__create_privilege('invoice_export',null,null);

    -- add children
    select acs_privilege__add_child('admin','invoice_cancel');
    select acs_privilege__add_child('admin','invoice_export');
end;


-- insert into contact_message_types (message_type,pretty_name) values ('offer','#invoices.template_offer#');
-- insert into contact_message_types (message_type,pretty_name) values ('offer_accepted','#invoices.template_offer_accepted#');
-- insert into contact_message_types (message_type,pretty_name) values ('invoice','#invoices.template_invoice#');
-- insert into contact_message_types (message_type,pretty_name) values ('invoice_cancel','#invoices.template_invoice_cancel#');
-- insert into contact_message_types (message_type,pretty_name) values ('invoice_credit','#invoices.template_invoice_credit#');
