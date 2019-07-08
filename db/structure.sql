SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    addressable_type character varying,
    addressable_id bigint,
    latitude numeric(11,8),
    longitude numeric(11,8),
    address character varying,
    number character varying,
    neighborhood character varying,
    cep character varying,
    complement character varying,
    reference_point character varying,
    city_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying NOT NULL
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: biddings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.biddings (
    id bigint NOT NULL,
    title character varying,
    description text,
    covenant_id bigint,
    kind integer,
    status integer,
    deadline integer,
    link character varying,
    start_date date,
    closing_date date,
    opening_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address character varying
);


--
-- Name: biddings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.biddings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: biddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.biddings_id_seq OWNED BY public.biddings.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    id bigint NOT NULL,
    code integer,
    name character varying,
    state_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_id_seq OWNED BY public.cities.id;


--
-- Name: classifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.classifications (
    id bigint NOT NULL,
    name character varying,
    classification_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    code integer
);


--
-- Name: classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.classifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.classifications_id_seq OWNED BY public.classifications.id;


--
-- Name: cooperatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cooperatives (
    id bigint NOT NULL,
    name text,
    cnpj character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cooperatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cooperatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cooperatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cooperatives_id_seq OWNED BY public.cooperatives.id;


--
-- Name: covenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.covenants (
    id bigint NOT NULL,
    number character varying,
    status integer,
    signature_date date,
    validity_date date,
    cooperative_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    admin_id bigint,
    estimated_cost double precision
);


--
-- Name: covenants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.covenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: covenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.covenants_id_seq OWNED BY public.covenants.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    eventable_type character varying,
    eventable_id bigint,
    creator_type character varying,
    creator_id bigint,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: group_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_items (
    id bigint NOT NULL,
    group_id bigint,
    item_id bigint,
    quantity integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    estimated_cost double precision,
    available_quantity integer
);


--
-- Name: group_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_items_id_seq OWNED BY public.group_items.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    covenant_id bigint,
    group_items_count integer DEFAULT 0
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: integration_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integration_configurations (
    id bigint NOT NULL,
    type character varying,
    endpoint_url character varying,
    token character varying,
    schedule character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer
);


--
-- Name: integration_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.integration_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: integration_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.integration_configurations_id_seq OWNED BY public.integration_configurations.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    title character varying,
    description text,
    unit integer,
    owner_type character varying,
    owner_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    classification_id bigint
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: legal_representatives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_representatives (
    id bigint NOT NULL,
    representable_type character varying,
    representable_id bigint,
    name character varying,
    nationality character varying,
    civil_state integer,
    rg character varying,
    cpf character varying,
    valid_until date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legal_representatives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legal_representatives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legal_representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legal_representatives_id_seq OWNED BY public.legal_representatives.id;


--
-- Name: lot_group_item_lot_proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lot_group_item_lot_proposals (
    id bigint NOT NULL,
    lot_group_item_id bigint,
    lot_proposal_id bigint,
    price numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lot_group_item_lot_proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lot_group_item_lot_proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lot_group_item_lot_proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lot_group_item_lot_proposals_id_seq OWNED BY public.lot_group_item_lot_proposals.id;


--
-- Name: lot_group_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lot_group_items (
    id bigint NOT NULL,
    lot_id bigint,
    group_item_id bigint,
    quantity integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lot_group_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lot_group_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lot_group_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lot_group_items_id_seq OWNED BY public.lot_group_items.id;


--
-- Name: lot_proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lot_proposals (
    id bigint NOT NULL,
    lot_id bigint,
    price_total numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    proposal_id bigint,
    supplier_id bigint
);


--
-- Name: lot_proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lot_proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lot_proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lot_proposals_id_seq OWNED BY public.lot_proposals.id;


--
-- Name: lots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lots (
    id bigint NOT NULL,
    bidding_id bigint,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lot_group_items_count integer,
    status integer DEFAULT 0,
    address text,
    deadline integer
);


--
-- Name: lots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lots_id_seq OWNED BY public.lots.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id integer,
    application_id bigint,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposals (
    id bigint NOT NULL,
    bidding_id bigint,
    provider_id bigint,
    status integer,
    price_total numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proposals_id_seq OWNED BY public.proposals.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.providers (
    id bigint NOT NULL,
    document character varying,
    name character varying,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.providers_id_seq OWNED BY public.providers.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    title character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id bigint NOT NULL,
    uf character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.states_id_seq OWNED BY public.states.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    name character varying NOT NULL,
    phone character varying NOT NULL,
    cpf character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider_id bigint
);


--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    cooperative_id bigint,
    phone character varying,
    cpf character varying,
    role_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes jsonb,
    created_at timestamp without time zone,
    owner_type character varying,
    owner_id bigint,
    ip character varying,
    user_agent character varying,
    class_name character varying NOT NULL
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: biddings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biddings ALTER COLUMN id SET DEFAULT nextval('public.biddings_id_seq'::regclass);


--
-- Name: cities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN id SET DEFAULT nextval('public.cities_id_seq'::regclass);


--
-- Name: classifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classifications ALTER COLUMN id SET DEFAULT nextval('public.classifications_id_seq'::regclass);


--
-- Name: cooperatives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cooperatives ALTER COLUMN id SET DEFAULT nextval('public.cooperatives_id_seq'::regclass);


--
-- Name: covenants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.covenants ALTER COLUMN id SET DEFAULT nextval('public.covenants_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: group_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_items ALTER COLUMN id SET DEFAULT nextval('public.group_items_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: integration_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_configurations ALTER COLUMN id SET DEFAULT nextval('public.integration_configurations_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: legal_representatives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_representatives ALTER COLUMN id SET DEFAULT nextval('public.legal_representatives_id_seq'::regclass);


--
-- Name: lot_group_item_lot_proposals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_item_lot_proposals ALTER COLUMN id SET DEFAULT nextval('public.lot_group_item_lot_proposals_id_seq'::regclass);


--
-- Name: lot_group_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_items ALTER COLUMN id SET DEFAULT nextval('public.lot_group_items_id_seq'::regclass);


--
-- Name: lot_proposals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_proposals ALTER COLUMN id SET DEFAULT nextval('public.lot_proposals_id_seq'::regclass);


--
-- Name: lots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lots ALTER COLUMN id SET DEFAULT nextval('public.lots_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: proposals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals ALTER COLUMN id SET DEFAULT nextval('public.proposals_id_seq'::regclass);


--
-- Name: providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers ALTER COLUMN id SET DEFAULT nextval('public.providers_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: biddings biddings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biddings
    ADD CONSTRAINT biddings_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: classifications classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classifications
    ADD CONSTRAINT classifications_pkey PRIMARY KEY (id);


--
-- Name: cooperatives cooperatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cooperatives
    ADD CONSTRAINT cooperatives_pkey PRIMARY KEY (id);


--
-- Name: covenants covenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.covenants
    ADD CONSTRAINT covenants_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: group_items group_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_items
    ADD CONSTRAINT group_items_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: integration_configurations integration_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_configurations
    ADD CONSTRAINT integration_configurations_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: legal_representatives legal_representatives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_representatives
    ADD CONSTRAINT legal_representatives_pkey PRIMARY KEY (id);


--
-- Name: lot_group_item_lot_proposals lot_group_item_lot_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_item_lot_proposals
    ADD CONSTRAINT lot_group_item_lot_proposals_pkey PRIMARY KEY (id);


--
-- Name: lot_group_items lot_group_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_items
    ADD CONSTRAINT lot_group_items_pkey PRIMARY KEY (id);


--
-- Name: lot_proposals lot_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_proposals
    ADD CONSTRAINT lot_proposals_pkey PRIMARY KEY (id);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: proposals proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_addresses_on_addressable_type_and_addressable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_addressable_type_and_addressable_id ON public.addresses USING btree (addressable_type, addressable_id);


--
-- Name: index_addresses_on_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_city_id ON public.addresses USING btree (city_id);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON public.admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON public.admins USING btree (reset_password_token);


--
-- Name: index_biddings_on_covenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_biddings_on_covenant_id ON public.biddings USING btree (covenant_id);


--
-- Name: index_cities_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cities_on_state_id ON public.cities USING btree (state_id);


--
-- Name: index_classifications_on_classification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_classifications_on_classification_id ON public.classifications USING btree (classification_id);


--
-- Name: index_covenants_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_covenants_on_admin_id ON public.covenants USING btree (admin_id);


--
-- Name: index_covenants_on_cooperative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_covenants_on_cooperative_id ON public.covenants USING btree (cooperative_id);


--
-- Name: index_events_on_creator_type_and_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_creator_type_and_creator_id ON public.events USING btree (creator_type, creator_id);


--
-- Name: index_events_on_eventable_type_and_eventable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventable_type_and_eventable_id ON public.events USING btree (eventable_type, eventable_id);


--
-- Name: index_group_items_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_items_on_group_id ON public.group_items USING btree (group_id);


--
-- Name: index_group_items_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_items_on_item_id ON public.group_items USING btree (item_id);


--
-- Name: index_groups_on_covenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_covenant_id ON public.groups USING btree (covenant_id);


--
-- Name: index_items_on_classification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_classification_id ON public.items USING btree (classification_id);


--
-- Name: index_items_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_owner_type_and_owner_id ON public.items USING btree (owner_type, owner_id);


--
-- Name: index_legal_reps_on_representable_type_and_representable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_reps_on_representable_type_and_representable_id ON public.legal_representatives USING btree (representable_type, representable_id);


--
-- Name: index_lot_group_item_lot_proposals_on_lot_group_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_group_item_lot_proposals_on_lot_group_item_id ON public.lot_group_item_lot_proposals USING btree (lot_group_item_id);


--
-- Name: index_lot_group_item_lot_proposals_on_lot_proposal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_group_item_lot_proposals_on_lot_proposal_id ON public.lot_group_item_lot_proposals USING btree (lot_proposal_id);


--
-- Name: index_lot_group_items_on_group_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_group_items_on_group_item_id ON public.lot_group_items USING btree (group_item_id);


--
-- Name: index_lot_group_items_on_lot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_group_items_on_lot_id ON public.lot_group_items USING btree (lot_id);


--
-- Name: index_lot_proposals_on_lot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_proposals_on_lot_id ON public.lot_proposals USING btree (lot_id);


--
-- Name: index_lot_proposals_on_proposal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_proposals_on_proposal_id ON public.lot_proposals USING btree (proposal_id);


--
-- Name: index_lot_proposals_on_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lot_proposals_on_supplier_id ON public.lot_proposals USING btree (supplier_id);


--
-- Name: index_lots_on_bidding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lots_on_bidding_id ON public.lots USING btree (bidding_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_name ON public.oauth_applications USING btree (name);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_proposals_on_bidding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proposals_on_bidding_id ON public.proposals USING btree (bidding_id);


--
-- Name: index_proposals_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proposals_on_provider_id ON public.proposals USING btree (provider_id);


--
-- Name: index_suppliers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suppliers_on_email ON public.suppliers USING btree (email);


--
-- Name: index_suppliers_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suppliers_on_provider_id ON public.suppliers USING btree (provider_id);


--
-- Name: index_suppliers_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suppliers_on_reset_password_token ON public.suppliers USING btree (reset_password_token);


--
-- Name: index_users_on_cooperative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_cooperative_id ON public.users USING btree (cooperative_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role_id ON public.users USING btree (role_id);


--
-- Name: index_versions_on_class_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_class_name ON public.versions USING btree (class_name);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_owner_type_and_owner_id ON public.versions USING btree (owner_type, owner_id);


--
-- Name: covenants fk_rails_43a527993c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.covenants
    ADD CONSTRAINT fk_rails_43a527993c FOREIGN KEY (cooperative_id) REFERENCES public.cooperatives(id);


--
-- Name: cities fk_rails_59b5e22e07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT fk_rails_59b5e22e07 FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: lot_group_items fk_rails_63db8ac679; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_items
    ADD CONSTRAINT fk_rails_63db8ac679 FOREIGN KEY (lot_id) REFERENCES public.lots(id);


--
-- Name: users fk_rails_642f17018b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_642f17018b FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: lot_group_item_lot_proposals fk_rails_6660084d82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_item_lot_proposals
    ADD CONSTRAINT fk_rails_6660084d82 FOREIGN KEY (lot_group_item_id) REFERENCES public.lot_group_items(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: classifications fk_rails_7ef509b794; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classifications
    ADD CONSTRAINT fk_rails_7ef509b794 FOREIGN KEY (classification_id) REFERENCES public.classifications(id);


--
-- Name: lot_group_items fk_rails_7f4a0ba6b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_items
    ADD CONSTRAINT fk_rails_7f4a0ba6b3 FOREIGN KEY (group_item_id) REFERENCES public.group_items(id);


--
-- Name: biddings fk_rails_8784e06615; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biddings
    ADD CONSTRAINT fk_rails_8784e06615 FOREIGN KEY (covenant_id) REFERENCES public.covenants(id);


--
-- Name: proposals fk_rails_9052affb5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT fk_rails_9052affb5a FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: lots fk_rails_956a1abf82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT fk_rails_956a1abf82 FOREIGN KEY (bidding_id) REFERENCES public.biddings(id);


--
-- Name: covenants fk_rails_a2234b8c15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.covenants
    ADD CONSTRAINT fk_rails_a2234b8c15 FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: addresses fk_rails_ab048f757c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_ab048f757c FOREIGN KEY (city_id) REFERENCES public.cities(id);


--
-- Name: groups fk_rails_af244fa2d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_af244fa2d2 FOREIGN KEY (covenant_id) REFERENCES public.covenants(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: lot_proposals fk_rails_b6e1b504be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_proposals
    ADD CONSTRAINT fk_rails_b6e1b504be FOREIGN KEY (lot_id) REFERENCES public.lots(id);


--
-- Name: group_items fk_rails_c5805488a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_items
    ADD CONSTRAINT fk_rails_c5805488a0 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: users fk_rails_cc5f950858; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_cc5f950858 FOREIGN KEY (cooperative_id) REFERENCES public.cooperatives(id);


--
-- Name: lot_group_item_lot_proposals fk_rails_cedf5f4695; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_group_item_lot_proposals
    ADD CONSTRAINT fk_rails_cedf5f4695 FOREIGN KEY (lot_proposal_id) REFERENCES public.lot_proposals(id);


--
-- Name: items fk_rails_d5fd619596; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_d5fd619596 FOREIGN KEY (classification_id) REFERENCES public.classifications(id);


--
-- Name: suppliers fk_rails_dddfbddb77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT fk_rails_dddfbddb77 FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: proposals fk_rails_f33f62299b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT fk_rails_f33f62299b FOREIGN KEY (bidding_id) REFERENCES public.biddings(id);


--
-- Name: group_items fk_rails_fb52dca2de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_items
    ADD CONSTRAINT fk_rails_fb52dca2de FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: lot_proposals fk_rails_fd74592e1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lot_proposals
    ADD CONSTRAINT fk_rails_fd74592e1a FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO "schema_migrations" (version) VALUES
('20180704163749'),
('20180704164316'),
('20180704175930'),
('20180704180028'),
('20180709151942'),
('20180709232627'),
('20180716142011'),
('20180718170017'),
('20180721141355'),
('20180721141400'),
('20180721141455'),
('20180721142401'),
('20180721142413'),
('20180721142420'),
('20180721153228'),
('20180722135612'),
('20180722140535'),
('20180722141418'),
('20180722141453'),
('20180722171313'),
('20180803173245'),
('20180803174101'),
('20180806172611'),
('20180807173640'),
('20180807180146'),
('20180808133501'),
('20180808170834'),
('20180808170855'),
('20180808171710'),
('20180809135735'),
('20180809140301'),
('20180809180226'),
('20180809180557'),
('20180813130513'),
('20180813130624'),
('20180813130721'),
('20180813141315'),
('20180813165016'),
('20180814125757'),
('20180903185722'),
('20180903191522'),
('20180910132154'),
('20180910140758'),
('20180917125528'),
('20180918143138'),
('20180919142648'),
('20180919161943'),
('20180922200025'),
('20180923161504'),
('20181001171518'),
('20181001172025'),
('20181001172329'),
('20181001180716'),
('20181001180742'),
('20181002125148'),
('20181002125248'),
('20181004191624'),
('20181008134815'),
('20181018182657');


