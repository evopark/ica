--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.7
-- Dumped by pg_dump version 9.5.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

--
-- Name: ica_garage_system_variant; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE ica_garage_system_variant AS ENUM (
    'easy_to_park',
    'ica'
);


--
-- Name: parking_card_add_on_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE parking_card_add_on_provider AS ENUM (
    'shell',
    'legic_prime'
);


--
-- Name: parking_system_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE parking_system_type AS ENUM (
    'snb_customer_media',
    'snb_econnect',
    'skidata_svp4',
    'ica'
);


--
-- Name: user_brand; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE user_brand AS ENUM (
    'evopark',
    'easy_to_park'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id integer NOT NULL,
    "default" boolean,
    first_name character varying,
    last_name character varying,
    gender integer,
    academic_title integer,
    zip_code character varying,
    country_code character varying,
    city character varying,
    additional character varying,
    street character varying,
    type character varying DEFAULT 'InvoiceAddress'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id integer
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: blocklist_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE blocklist_entries (
    id integer NOT NULL,
    rfid_tag_id integer NOT NULL,
    parking_garage_id integer NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: blocklist_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blocklist_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocklist_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blocklist_entries_id_seq OWNED BY blocklist_entries.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers (
    id integer NOT NULL,
    customer_number character varying NOT NULL,
    workflow_state character varying NOT NULL,
    feature_set_id integer,
    brand user_brand DEFAULT 'evopark'::user_brand NOT NULL
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: customers_test_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers_test_groups (
    id integer NOT NULL,
    test_group_id integer,
    customer_id integer
);


--
-- Name: customers_test_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_test_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_test_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_test_groups_id_seq OWNED BY customers_test_groups.id;


--
-- Name: ica_card_account_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ica_card_account_mappings (
    id integer NOT NULL,
    customer_account_mapping_id integer NOT NULL,
    rfid_tag_id integer NOT NULL,
    card_key uuid,
    uploaded_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ica_card_account_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ica_card_account_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ica_card_account_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ica_card_account_mappings_id_seq OWNED BY ica_card_account_mappings.id;


--
-- Name: ica_carparks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ica_carparks (
    id integer NOT NULL,
    carpark_id integer,
    parking_garage_id integer,
    garage_system_id integer
);


--
-- Name: ica_carparks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ica_carparks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ica_carparks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ica_carparks_id_seq OWNED BY ica_carparks.id;


--
-- Name: ica_customer_account_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ica_customer_account_mappings (
    id integer NOT NULL,
    account_key uuid NOT NULL,
    uploaded_at timestamp without time zone,
    garage_system_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id integer NOT NULL
);


--
-- Name: ica_customer_account_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ica_customer_account_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ica_customer_account_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ica_customer_account_mappings_id_seq OWNED BY ica_customer_account_mappings.id;


--
-- Name: ica_garage_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ica_garage_systems (
    id integer NOT NULL,
    client_id character varying NOT NULL,
    auth_key character varying NOT NULL,
    sig_key character varying NOT NULL,
    description text,
    workflow_state character varying NOT NULL,
    last_account_sync_at timestamp without time zone,
    hostname character varying NOT NULL,
    variant ica_garage_system_variant NOT NULL,
    use_ssl boolean DEFAULT false NOT NULL,
    path_prefix character varying
);


--
-- Name: ica_garage_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ica_garage_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ica_garage_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ica_garage_systems_id_seq OWNED BY ica_garage_systems.id;


--
-- Name: ica_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ica_versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes jsonb,
    created_at timestamp without time zone
);


--
-- Name: ica_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ica_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ica_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ica_versions_id_seq OWNED BY ica_versions.id;


--
-- Name: operator_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE operator_companies (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: operator_companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE operator_companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operator_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE operator_companies_id_seq OWNED BY operator_companies.id;


--
-- Name: operator_companies_test_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE operator_companies_test_groups (
    id integer NOT NULL,
    test_group_id integer NOT NULL,
    operator_company_id integer NOT NULL
);


--
-- Name: operator_companies_test_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE operator_companies_test_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operator_companies_test_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE operator_companies_test_groups_id_seq OWNED BY operator_companies_test_groups.id;


--
-- Name: parking_card_add_ons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parking_card_add_ons (
    id integer NOT NULL,
    identifier character varying NOT NULL,
    rfid_tag_id integer,
    provider parking_card_add_on_provider,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: parking_card_add_ons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parking_card_add_ons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_card_add_ons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parking_card_add_ons_id_seq OWNED BY parking_card_add_ons.id;


--
-- Name: parking_garages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parking_garages (
    id integer NOT NULL,
    name character varying,
    system_type parking_system_type NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    operator_company_id integer
);


--
-- Name: parking_garages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parking_garages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_garages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parking_garages_id_seq OWNED BY parking_garages.id;


--
-- Name: rfid_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rfid_tags (
    id integer NOT NULL,
    tag_number character varying NOT NULL,
    uid character varying,
    workflow_state character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id integer
);


--
-- Name: rfid_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rfid_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rfid_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rfid_tags_id_seq OWNED BY rfid_tags.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: test_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE test_groups (
    id integer NOT NULL,
    garage_status character varying NOT NULL,
    system_types parking_system_type[] DEFAULT '{}'::parking_system_type[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: test_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE test_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE test_groups_id_seq OWNED BY test_groups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    customer_id integer NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocklist_entries ALTER COLUMN id SET DEFAULT nextval('blocklist_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_test_groups ALTER COLUMN id SET DEFAULT nextval('customers_test_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_card_account_mappings ALTER COLUMN id SET DEFAULT nextval('ica_card_account_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_carparks ALTER COLUMN id SET DEFAULT nextval('ica_carparks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_customer_account_mappings ALTER COLUMN id SET DEFAULT nextval('ica_customer_account_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_garage_systems ALTER COLUMN id SET DEFAULT nextval('ica_garage_systems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_versions ALTER COLUMN id SET DEFAULT nextval('ica_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY operator_companies ALTER COLUMN id SET DEFAULT nextval('operator_companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY operator_companies_test_groups ALTER COLUMN id SET DEFAULT nextval('operator_companies_test_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parking_card_add_ons ALTER COLUMN id SET DEFAULT nextval('parking_card_add_ons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parking_garages ALTER COLUMN id SET DEFAULT nextval('parking_garages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rfid_tags ALTER COLUMN id SET DEFAULT nextval('rfid_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY test_groups ALTER COLUMN id SET DEFAULT nextval('test_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blocklist_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocklist_entries
    ADD CONSTRAINT blocklist_entries_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers_test_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_test_groups
    ADD CONSTRAINT customers_test_groups_pkey PRIMARY KEY (id);


--
-- Name: ica_card_account_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_card_account_mappings
    ADD CONSTRAINT ica_card_account_mappings_pkey PRIMARY KEY (id);


--
-- Name: ica_carparks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_carparks
    ADD CONSTRAINT ica_carparks_pkey PRIMARY KEY (id);


--
-- Name: ica_customer_account_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_customer_account_mappings
    ADD CONSTRAINT ica_customer_account_mappings_pkey PRIMARY KEY (id);


--
-- Name: ica_garage_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_garage_systems
    ADD CONSTRAINT ica_garage_systems_pkey PRIMARY KEY (id);


--
-- Name: ica_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ica_versions
    ADD CONSTRAINT ica_versions_pkey PRIMARY KEY (id);


--
-- Name: operator_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY operator_companies
    ADD CONSTRAINT operator_companies_pkey PRIMARY KEY (id);


--
-- Name: operator_companies_test_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY operator_companies_test_groups
    ADD CONSTRAINT operator_companies_test_groups_pkey PRIMARY KEY (id);


--
-- Name: parking_card_add_ons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parking_card_add_ons
    ADD CONSTRAINT parking_card_add_ons_pkey PRIMARY KEY (id);


--
-- Name: parking_garages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parking_garages
    ADD CONSTRAINT parking_garages_pkey PRIMARY KEY (id);


--
-- Name: rfid_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rfid_tags
    ADD CONSTRAINT rfid_tags_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: test_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY test_groups
    ADD CONSTRAINT test_groups_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: idx_parking_card_add_on_unique_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_parking_card_add_on_unique_identifier ON parking_card_add_ons USING btree (provider, identifier);


--
-- Name: index_ica_customer_account_mappings_on_account_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ica_customer_account_mappings_on_account_key ON ica_customer_account_mappings USING btree (account_key);


--
-- Name: index_ica_garage_systems_on_client_id_and_auth_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ica_garage_systems_on_client_id_and_auth_key ON ica_garage_systems USING btree (client_id, auth_key);


--
-- Name: index_ica_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ica_versions_on_item_type_and_item_id ON ica_versions USING btree (item_type, item_id);


--
-- Name: index_rfid_tags_on_tag_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rfid_tags_on_tag_number ON rfid_tags USING btree (tag_number);


--
-- Name: index_rfid_tags_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rfid_tags_on_uid ON rfid_tags USING btree (uid);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO "schema_migrations" (version) VALUES
('20160112171000'),
('20160128154530'),
('20170807191813'),
('20170807191825'),
('20170807191950'),
('20170807192015'),
('20170808072359'),
('20170808080000'),
('20170808080001'),
('20170808080002'),
('20170808115156'),
('20170808120000'),
('20170808121126'),
('20170808155619'),
('20170810114840'),
('20170825112043'),
('20170830134633'),
('20171107162407'),
('20171108102228'),
('20711108112109');


