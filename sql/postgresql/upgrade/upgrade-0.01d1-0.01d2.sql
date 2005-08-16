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
        amount_total            numeric(12,2),
        amount_sum              numeric(12,2),
        currency                char(3)
                                constraint iv_offers_currency_fk
                                references currencies(codeA),
        finish_date             timestamptz,
        payment_days            integer,
        vat_percent             numeric(12,5) default 0,
                                -- %VAT
        vat                     numeric(12,2) default 0,
                                -- VAT amount
        accepted_p              char(1) default 'f'
                                constraint iv_offers_accepted_p
                                check (accepted_p in ('t','f'))
                                -- offer accepted by customer?
);

-- offers are linked to a project via cr_items.parent_id
-- if it's a preliminary offer, it's linked to the customer project
-- if it's a final project, it's linked to the actual project

create index iv_offers_organization_idx on iv_offers(organization_id);
create index iv_offers_currency_idx on iv_offers(currency);

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
        item_units              numeric(12,1),
        price_per_unit          numeric(12,3),
        rebate                  numeric(12,2),
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

alter table iv_default_objects add column offer_id integer constraint iv_default_objects_offer_fk references acs_objects;

alter table iv_default_objects add column offer_item_id integer constraint iv_default_objects_offer_item_fk references acs_objects;

alter table iv_invoice_items add column offer_item_id integer constraint iv_invoice_items_offer_fk references iv_offer_items;

create index iv_invoice_items_offer_idx on iv_invoice_items(offer_item_id);
