--
-- PostgreSQL database dump
--

\restrict WMIazM9bs7uRunVr0g7DyaUsq5AGM7XBLTYsza7DGwRh2g9LDSZzKDQtHZRnwQs

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    project_id bigint,
    name text,
    domain text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.companies OWNER TO n8n;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO n8n;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    company_id bigint,
    project_id bigint,
    name text,
    role text,
    email text,
    confidence integer,
    created_at timestamp with time zone DEFAULT now(),
    synced boolean DEFAULT false
);


ALTER TABLE public.contacts OWNER TO n8n;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO n8n;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: crm_log; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.crm_log (
    id bigint NOT NULL,
    contact_id bigint,
    project_id bigint,
    name text,
    email text,
    company text,
    project text,
    synced_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.crm_log OWNER TO n8n;

--
-- Name: crm_log_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.crm_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.crm_log_id_seq OWNER TO n8n;

--
-- Name: crm_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.crm_log_id_seq OWNED BY public.crm_log.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    project_id bigint,
    contact_id bigint,
    subject text,
    body text,
    status text DEFAULT 'draft'::text,
    approved boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.messages OWNER TO n8n;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO n8n;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    source text NOT NULL,
    source_id text NOT NULL,
    title text,
    naics text,
    state text,
    value numeric,
    posted_at date,
    deadline date,
    raw jsonb,
    status text DEFAULT 'new'::text NOT NULL,
    status_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.projects OWNER TO n8n;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO n8n;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: replies; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.replies (
    id bigint NOT NULL,
    message_id bigint,
    from_email text,
    body text,
    classification text,
    processed boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.replies OWNER TO n8n;

--
-- Name: replies_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.replies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.replies_id_seq OWNER TO n8n;

--
-- Name: replies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.replies_id_seq OWNED BY public.replies.id;


--
-- Name: suppressions; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.suppressions (
    email text NOT NULL,
    reason text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.suppressions OWNER TO n8n;

--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: crm_log id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.crm_log ALTER COLUMN id SET DEFAULT nextval('public.crm_log_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: replies id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.replies ALTER COLUMN id SET DEFAULT nextval('public.replies_id_seq'::regclass);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: crm_log crm_log_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.crm_log
    ADD CONSTRAINT crm_log_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: replies replies_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.replies
    ADD CONSTRAINT replies_pkey PRIMARY KEY (id);


--
-- Name: suppressions suppressions_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.suppressions
    ADD CONSTRAINT suppressions_pkey PRIMARY KEY (email);


--
-- Name: projects_source_uniq; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX projects_source_uniq ON public.projects USING btree (source, source_id);


--
-- Name: projects_status_idx; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX projects_status_idx ON public.projects USING btree (status, status_at);


--
-- PostgreSQL database dump complete
--

\unrestrict WMIazM9bs7uRunVr0g7DyaUsq5AGM7XBLTYsza7DGwRh2g9LDSZzKDQtHZRnwQs

