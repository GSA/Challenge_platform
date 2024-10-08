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

--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    avatar_key uuid,
    avatar_extension character varying(255),
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    created_on_import boolean DEFAULT false NOT NULL,
    acronym character varying(255),
    parent_id bigint
);


--
-- Name: agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agencies_id_seq OWNED BY public.agencies.id;


--
-- Name: agency_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_members (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    agency_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: agency_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agency_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agency_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agency_members_id_seq OWNED BY public.agency_members.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: certification_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certification_log (
    id bigint NOT NULL,
    approver_id bigint,
    approver_role character varying(255),
    approver_identifier character varying(255),
    approver_remote_ip character varying(255),
    user_id bigint NOT NULL,
    user_role character varying(255),
    user_identifier character varying(255),
    user_remote_ip character varying(255),
    requested_at timestamp(0) without time zone,
    certified_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    denied_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: certification_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certification_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certification_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certification_log_id_seq OWNED BY public.certification_log.id;


--
-- Name: challenge_managers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.challenge_managers (
    id bigint NOT NULL,
    challenge_id bigint,
    user_id bigint,
    revoked_at timestamp(0) without time zone
);


--
-- Name: challenge_owners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.challenge_owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: challenge_owners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.challenge_owners_id_seq OWNED BY public.challenge_managers.id;


--
-- Name: challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.challenges (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    captured_on date,
    published_on date,
    title character varying(255),
    tagline text,
    poc_email character varying(255),
    agency_name character varying(255),
    how_to_enter text,
    rules text,
    external_url character varying(255),
    custom_url character varying(255),
    start_date timestamp(0) without time zone,
    end_date timestamp(0) without time zone,
    fiscal_year character varying(255),
    type character varying(255),
    prize_total bigint NOT NULL,
    prize_description text,
    judging_criteria text,
    challenge_manager character varying(255),
    legal_authority character varying(255),
    terms_and_conditions text,
    non_monetary_prizes text,
    federal_partners text,
    faq text,
    winner_information text,
    number_of_phases text,
    phase_descriptions text,
    phase_dates text,
    brief_description text,
    multi_phase boolean,
    eligibility_requirements text,
    challenge_manager_email character varying(255),
    agency_id bigint,
    logo_key uuid,
    logo_extension character varying(255),
    winner_image_key uuid,
    winner_image_extension character varying(255),
    last_section character varying(255),
    types jsonb,
    auto_publish_date timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    rejection_message text,
    phases jsonb,
    upload_logo boolean,
    is_multi_phase boolean,
    timeline_events jsonb,
    prize_type character varying(255),
    terms_equal_rules boolean,
    how_to_enter_link character varying(255),
    resource_banner_key uuid,
    resource_banner_extension character varying(255),
    imported boolean DEFAULT false NOT NULL,
    description_delta text,
    prize_description_delta text,
    faq_delta text,
    eligibility_requirements_delta text,
    rules_delta text,
    terms_and_conditions_delta text,
    uuid uuid,
    sub_agency_id bigint,
    primary_type character varying(255),
    other_type character varying(255),
    announcement text,
    announcement_datetime timestamp(0) without time zone,
    sub_status character varying(255),
    gov_delivery_topic character varying(255),
    archive_date timestamp(0) without time zone,
    gov_delivery_subscribers integer DEFAULT 0 NOT NULL,
    brief_description_delta text,
    logo_alt_text character varying(255),
    short_url character varying(255),
    submission_collection_method character varying(255),
    file_upload_required boolean DEFAULT false,
    upload_instruction_note character varying(255)
);


--
-- Name: challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.challenges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.challenges_id_seq OWNED BY public.challenges.id;


--
-- Name: dap_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dap_reports (
    id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    key uuid NOT NULL,
    extension character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: dap_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dap_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dap_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dap_reports_id_seq OWNED BY public.dap_reports.id;


--
-- Name: evaluation_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evaluation_criteria (
    id bigint NOT NULL,
    evaluation_form_id bigint NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    points_or_weight integer NOT NULL,
    scoring_type integer NOT NULL,
    option_range_start integer,
    option_range_end integer,
    option_labels json DEFAULT '[]'::json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: evaluation_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evaluation_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluation_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evaluation_criteria_id_seq OWNED BY public.evaluation_criteria.id;


--
-- Name: evaluation_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evaluation_forms (
    id bigint NOT NULL,
    title character varying NOT NULL,
    instructions character varying NOT NULL,
    challenge_phase integer NOT NULL,
    comments_required boolean DEFAULT false,
    weighted_scoring boolean DEFAULT false,
    closing_date date NOT NULL,
    challenge_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: evaluation_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evaluation_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluation_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evaluation_forms_id_seq OWNED BY public.evaluation_forms.id;


--
-- Name: federal_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.federal_partners (
    id bigint NOT NULL,
    agency_id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    sub_agency_id bigint
);


--
-- Name: federal_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.federal_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: federal_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.federal_partners_id_seq OWNED BY public.federal_partners.id;


--
-- Name: message_context_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_context_statuses (
    id bigint NOT NULL,
    message_context_id bigint NOT NULL,
    user_id bigint NOT NULL,
    read boolean DEFAULT false,
    starred boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    archived boolean DEFAULT false
);


--
-- Name: message_context_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_context_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_context_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_context_statuses_id_seq OWNED BY public.message_context_statuses.id;


--
-- Name: message_contexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_contexts (
    id bigint NOT NULL,
    context character varying(255) NOT NULL,
    context_id integer NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    last_message_id bigint,
    audience character varying(255),
    parent_id bigint
);


--
-- Name: message_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_contexts_id_seq OWNED BY public.message_contexts.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    message_context_id bigint NOT NULL,
    author_id bigint NOT NULL,
    content text,
    content_delta text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    status character varying(255) DEFAULT 'sent'::character varying NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: non_federal_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_federal_partners (
    id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    name character varying(255)
);


--
-- Name: non_federal_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_federal_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_federal_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_federal_partners_id_seq OWNED BY public.non_federal_partners.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '12';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: phase_winners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phase_winners (
    id bigint NOT NULL,
    phase_id bigint,
    uuid uuid NOT NULL,
    status character varying(255),
    overview text,
    overview_delta text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    overview_image_key uuid,
    overview_image_extension character varying(255)
);


--
-- Name: phases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phases (
    id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    uuid uuid NOT NULL,
    title character varying(255),
    start_date timestamp(0) without time zone,
    end_date timestamp(0) without time zone,
    open_to_submissions boolean,
    judging_criteria text,
    judging_criteria_delta text,
    how_to_enter text,
    how_to_enter_delta text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: phases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phases_id_seq OWNED BY public.phases.id;


--
-- Name: saved_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_challenges (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: saved_challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_challenges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_challenges_id_seq OWNED BY public.saved_challenges.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: security_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_log (
    id bigint NOT NULL,
    action character varying(255) NOT NULL,
    details jsonb,
    originator_id bigint,
    originator_role character varying(255),
    originator_identifier character varying(255),
    target_id integer,
    target_type character varying(255),
    target_identifier character varying(255),
    logged_at timestamp(0) without time zone NOT NULL,
    originator_remote_ip character varying(255)
);


--
-- Name: security_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_log_id_seq OWNED BY public.security_log.id;


--
-- Name: site_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_content (
    id bigint NOT NULL,
    section character varying(255),
    content text,
    content_delta text,
    start_date timestamp(0) without time zone,
    end_date timestamp(0) without time zone
);


--
-- Name: site_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_content_id_seq OWNED BY public.site_content.id;


--
-- Name: submission_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_documents (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    submission_id bigint,
    filename character varying(255) NOT NULL,
    key uuid NOT NULL,
    extension character varying(255) NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: submission_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submission_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submission_documents_id_seq OWNED BY public.submission_documents.id;


--
-- Name: submission_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_exports (
    id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    phase_ids jsonb,
    judging_status character varying(255),
    format character varying(255),
    status character varying(255),
    key uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: submission_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submission_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submission_exports_id_seq OWNED BY public.submission_exports.id;


--
-- Name: submission_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_invites (
    id bigint NOT NULL,
    submission_id bigint NOT NULL,
    message text,
    message_delta text,
    status character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: submission_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submission_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submission_invites_id_seq OWNED BY public.submission_invites.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id bigint NOT NULL,
    submitter_id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    title character varying(255),
    brief_description text,
    description text,
    external_url character varying(255),
    status character varying(255),
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    phase_id bigint NOT NULL,
    judging_status character varying(255) DEFAULT 'not_selected'::character varying,
    manager_id bigint,
    terms_accepted boolean,
    review_verified boolean,
    description_delta text,
    brief_description_delta text,
    pdf_reference character varying(255)
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: supporting_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supporting_documents (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    challenge_id bigint,
    key uuid NOT NULL,
    extension character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    filename character varying(255) NOT NULL,
    section character varying(255) NOT NULL,
    name character varying(255)
);


--
-- Name: supporting_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supporting_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supporting_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supporting_documents_id_seq OWNED BY public.supporting_documents.id;


--
-- Name: timeline_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_events (
    id bigint NOT NULL,
    challenge_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    body text,
    occurs_on date NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: timeline_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timeline_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timeline_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timeline_events_id_seq OWNED BY public.timeline_events.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    token uuid,
    first_name character varying(255),
    last_name character varying(255),
    phone_number character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    email_verification_token character varying(255),
    email_verified_at timestamp(0) without time zone,
    role character varying(255) DEFAULT 'user'::character varying NOT NULL,
    password_reset_token uuid,
    password_reset_expires_at timestamp(0) without time zone,
    finalized boolean DEFAULT true NOT NULL,
    avatar_key uuid,
    avatar_extension character varying(255),
    display boolean DEFAULT true NOT NULL,
    terms_of_use timestamp(0) without time zone,
    privacy_guidelines timestamp(0) without time zone,
    agency_id bigint,
    last_active timestamp(0) without time zone,
    status character varying(255),
    active_session boolean DEFAULT false,
    renewal_request character varying(255),
    jwt_token text,
    recertification_expired_at timestamp(0) without time zone
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
-- Name: winners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.winners (
    id bigint NOT NULL,
    phase_winner_id bigint,
    name character varying(255),
    place_title character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    image_key uuid,
    image_extension character varying(255)
);


--
-- Name: winners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.winners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: winners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.winners_id_seq OWNED BY public.phase_winners.id;


--
-- Name: winners_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.winners_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: winners_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.winners_id_seq1 OWNED BY public.winners.id;


--
-- Name: agencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies ALTER COLUMN id SET DEFAULT nextval('public.agencies_id_seq'::regclass);


--
-- Name: agency_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members ALTER COLUMN id SET DEFAULT nextval('public.agency_members_id_seq'::regclass);


--
-- Name: certification_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_log ALTER COLUMN id SET DEFAULT nextval('public.certification_log_id_seq'::regclass);


--
-- Name: challenge_managers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_managers ALTER COLUMN id SET DEFAULT nextval('public.challenge_owners_id_seq'::regclass);


--
-- Name: challenges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenges ALTER COLUMN id SET DEFAULT nextval('public.challenges_id_seq'::regclass);


--
-- Name: dap_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dap_reports ALTER COLUMN id SET DEFAULT nextval('public.dap_reports_id_seq'::regclass);


--
-- Name: evaluation_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_criteria ALTER COLUMN id SET DEFAULT nextval('public.evaluation_criteria_id_seq'::regclass);


--
-- Name: evaluation_forms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_forms ALTER COLUMN id SET DEFAULT nextval('public.evaluation_forms_id_seq'::regclass);


--
-- Name: federal_partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federal_partners ALTER COLUMN id SET DEFAULT nextval('public.federal_partners_id_seq'::regclass);


--
-- Name: message_context_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_context_statuses ALTER COLUMN id SET DEFAULT nextval('public.message_context_statuses_id_seq'::regclass);


--
-- Name: message_contexts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_contexts ALTER COLUMN id SET DEFAULT nextval('public.message_contexts_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: non_federal_partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_federal_partners ALTER COLUMN id SET DEFAULT nextval('public.non_federal_partners_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: phase_winners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_winners ALTER COLUMN id SET DEFAULT nextval('public.winners_id_seq'::regclass);


--
-- Name: phases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phases ALTER COLUMN id SET DEFAULT nextval('public.phases_id_seq'::regclass);


--
-- Name: saved_challenges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_challenges ALTER COLUMN id SET DEFAULT nextval('public.saved_challenges_id_seq'::regclass);


--
-- Name: security_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_log ALTER COLUMN id SET DEFAULT nextval('public.security_log_id_seq'::regclass);


--
-- Name: site_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content ALTER COLUMN id SET DEFAULT nextval('public.site_content_id_seq'::regclass);


--
-- Name: submission_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_documents ALTER COLUMN id SET DEFAULT nextval('public.submission_documents_id_seq'::regclass);


--
-- Name: submission_exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_exports ALTER COLUMN id SET DEFAULT nextval('public.submission_exports_id_seq'::regclass);


--
-- Name: submission_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_invites ALTER COLUMN id SET DEFAULT nextval('public.submission_invites_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: supporting_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporting_documents ALTER COLUMN id SET DEFAULT nextval('public.supporting_documents_id_seq'::regclass);


--
-- Name: timeline_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events ALTER COLUMN id SET DEFAULT nextval('public.timeline_events_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: winners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners ALTER COLUMN id SET DEFAULT nextval('public.winners_id_seq1'::regclass);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: agency_members agency_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: certification_log certification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_log
    ADD CONSTRAINT certification_log_pkey PRIMARY KEY (id);


--
-- Name: challenge_managers challenge_owners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_managers
    ADD CONSTRAINT challenge_owners_pkey PRIMARY KEY (id);


--
-- Name: challenges challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (id);


--
-- Name: dap_reports dap_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dap_reports
    ADD CONSTRAINT dap_reports_pkey PRIMARY KEY (id);


--
-- Name: evaluation_criteria evaluation_criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_criteria
    ADD CONSTRAINT evaluation_criteria_pkey PRIMARY KEY (id);


--
-- Name: evaluation_forms evaluation_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_forms
    ADD CONSTRAINT evaluation_forms_pkey PRIMARY KEY (id);


--
-- Name: federal_partners federal_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federal_partners
    ADD CONSTRAINT federal_partners_pkey PRIMARY KEY (id);


--
-- Name: message_context_statuses message_context_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_context_statuses
    ADD CONSTRAINT message_context_statuses_pkey PRIMARY KEY (id);


--
-- Name: message_contexts message_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_contexts
    ADD CONSTRAINT message_contexts_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: non_federal_partners non_federal_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_federal_partners
    ADD CONSTRAINT non_federal_partners_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: phases phases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phases
    ADD CONSTRAINT phases_pkey PRIMARY KEY (id);


--
-- Name: saved_challenges saved_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_challenges
    ADD CONSTRAINT saved_challenges_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: security_log security_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_log
    ADD CONSTRAINT security_log_pkey PRIMARY KEY (id);


--
-- Name: site_content site_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content
    ADD CONSTRAINT site_content_pkey PRIMARY KEY (id);


--
-- Name: submission_documents submission_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_documents
    ADD CONSTRAINT submission_documents_pkey PRIMARY KEY (id);


--
-- Name: submission_exports submission_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_exports
    ADD CONSTRAINT submission_exports_pkey PRIMARY KEY (id);


--
-- Name: submission_invites submission_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_invites
    ADD CONSTRAINT submission_invites_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: supporting_documents supporting_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporting_documents
    ADD CONSTRAINT supporting_documents_pkey PRIMARY KEY (id);


--
-- Name: timeline_events timeline_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT timeline_events_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: phase_winners winners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_winners
    ADD CONSTRAINT winners_pkey PRIMARY KEY (id);


--
-- Name: winners winners_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_pkey1 PRIMARY KEY (id);


--
-- Name: agency_members_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX agency_members_user_id_index ON public.agency_members USING btree (user_id);


--
-- Name: challenges_custom_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX challenges_custom_url_index ON public.challenges USING btree (custom_url);


--
-- Name: index_evaluation_criteria_on_evaluation_form_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluation_criteria_on_evaluation_form_id ON public.evaluation_criteria USING btree (evaluation_form_id);


--
-- Name: index_evaluation_criteria_on_evaluation_form_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_evaluation_criteria_on_evaluation_form_id_and_title ON public.evaluation_criteria USING btree (evaluation_form_id, title);


--
-- Name: index_evaluation_forms_on_challenge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluation_forms_on_challenge_id ON public.evaluation_forms USING btree (challenge_id);


--
-- Name: index_evaluation_forms_on_challenge_id_and_challenge_phase; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_evaluation_forms_on_challenge_id_and_challenge_phase ON public.evaluation_forms USING btree (challenge_id, challenge_phase);


--
-- Name: message_contexts_context_context_id_audience_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX message_contexts_context_context_id_audience_parent_id_index ON public.message_contexts USING btree (context, context_id, audience, parent_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: saved_challenges_user_id_challenge_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX saved_challenges_user_id_challenge_id_index ON public.saved_challenges USING btree (user_id, challenge_id);


--
-- Name: site_content_section_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_content_section_index ON public.site_content USING btree (section);


--
-- Name: users_lower_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_lower_email_index ON public.users USING btree (lower((email)::text));


--
-- Name: winners_phase_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX winners_phase_id_index ON public.phase_winners USING btree (phase_id);


--
-- Name: agencies agencies_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.agencies(id);


--
-- Name: agency_members agency_members_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: agency_members agency_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: certification_log certification_log_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_log
    ADD CONSTRAINT certification_log_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: certification_log certification_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_log
    ADD CONSTRAINT certification_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: challenge_managers challenge_owners_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_managers
    ADD CONSTRAINT challenge_owners_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: challenge_managers challenge_owners_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenge_managers
    ADD CONSTRAINT challenge_owners_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: challenges challenges_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: challenges challenges_sub_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_sub_agency_id_fkey FOREIGN KEY (sub_agency_id) REFERENCES public.agencies(id);


--
-- Name: challenges challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: federal_partners federal_partners_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federal_partners
    ADD CONSTRAINT federal_partners_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: federal_partners federal_partners_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federal_partners
    ADD CONSTRAINT federal_partners_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: federal_partners federal_partners_sub_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.federal_partners
    ADD CONSTRAINT federal_partners_sub_agency_id_fkey FOREIGN KEY (sub_agency_id) REFERENCES public.agencies(id);


--
-- Name: evaluation_forms fk_rails_28ad57fb81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_forms
    ADD CONSTRAINT fk_rails_28ad57fb81 FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: evaluation_criteria fk_rails_a39b8fa483; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluation_criteria
    ADD CONSTRAINT fk_rails_a39b8fa483 FOREIGN KEY (evaluation_form_id) REFERENCES public.evaluation_forms(id);


--
-- Name: message_context_statuses message_context_statuses_message_context_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_context_statuses
    ADD CONSTRAINT message_context_statuses_message_context_id_fkey FOREIGN KEY (message_context_id) REFERENCES public.message_contexts(id);


--
-- Name: message_context_statuses message_context_statuses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_context_statuses
    ADD CONSTRAINT message_context_statuses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: message_contexts message_contexts_last_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_contexts
    ADD CONSTRAINT message_contexts_last_message_id_fkey FOREIGN KEY (last_message_id) REFERENCES public.messages(id);


--
-- Name: message_contexts message_contexts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_contexts
    ADD CONSTRAINT message_contexts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.message_contexts(id);


--
-- Name: messages messages_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: messages messages_message_context_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_message_context_id_fkey FOREIGN KEY (message_context_id) REFERENCES public.message_contexts(id);


--
-- Name: non_federal_partners non_federal_partners_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_federal_partners
    ADD CONSTRAINT non_federal_partners_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: phases phases_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phases
    ADD CONSTRAINT phases_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: saved_challenges saved_challenges_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_challenges
    ADD CONSTRAINT saved_challenges_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: saved_challenges saved_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_challenges
    ADD CONSTRAINT saved_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: security_log security_log_originator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_log
    ADD CONSTRAINT security_log_originator_id_fkey FOREIGN KEY (originator_id) REFERENCES public.users(id);


--
-- Name: submission_documents solution_documents_solution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_documents
    ADD CONSTRAINT solution_documents_solution_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: submission_documents solution_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_documents
    ADD CONSTRAINT solution_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: submissions solutions_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT solutions_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: submissions solutions_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT solutions_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id);


--
-- Name: submissions solutions_phase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT solutions_phase_id_fkey FOREIGN KEY (phase_id) REFERENCES public.phases(id);


--
-- Name: submissions solutions_submitter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT solutions_submitter_id_fkey FOREIGN KEY (submitter_id) REFERENCES public.users(id);


--
-- Name: submission_exports submission_exports_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_exports
    ADD CONSTRAINT submission_exports_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: submission_invites submission_invites_solution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_invites
    ADD CONSTRAINT submission_invites_solution_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: supporting_documents supporting_documents_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporting_documents
    ADD CONSTRAINT supporting_documents_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: supporting_documents supporting_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supporting_documents
    ADD CONSTRAINT supporting_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: timeline_events timeline_events_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT timeline_events_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id);


--
-- Name: users users_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: phase_winners winners_phase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_winners
    ADD CONSTRAINT winners_phase_id_fkey FOREIGN KEY (phase_id) REFERENCES public.phases(id);


--
-- Name: winners winners_phase_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_phase_winner_id_fkey FOREIGN KEY (phase_winner_id) REFERENCES public.phase_winners(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
(20241001143033),
(20240927010020),
(20240917010803),
(20231112151027),
(20231112151017),
(20231112151006),
(20230919172929),
(20230322031917),
(20220509195351),
(20220329133004),
(20211025212439),
(20211021161736),
(20211019185650),
(20210923161248),
(20210919200909),
(20210803015000),
(20210726174345),
(20210726172128),
(20210723165038),
(20210723162419),
(20210714145513),
(20210713210749),
(20210711194628),
(20210709195911),
(20210701020028),
(20210622184536),
(20210616032817),
(20210608023340),
(20210518191653),
(20210506205512),
(20210422044336),
(20210419200019),
(20210225160407),
(20210217130527),
(20210207205711),
(20210203021508),
(20201214233413),
(20201204172046),
(20201204025748),
(20201109170549),
(20201106190632),
(20201011205016),
(20201007193910),
(20200927220805),
(20200927103451),
(20200910005419),
(20200909171803),
(20200907002801),
(20200714165629),
(20200706003548),
(20200701202731),
(20200630195815),
(20200629171008),
(20200615145652),
(20200612201224),
(20200611202305),
(20200609150711),
(20200608192810),
(20200605004340),
(20200604154913),
(20200602163959),
(20200531164823),
(20200529173532),
(20200528163012),
(20200522145736),
(20200521155811),
(20200513193528),
(20200513014720),
(20200508205423),
(20200508030221),
(20200505185007),
(20200420173121),
(20200415210810),
(20200414162033),
(20200410201245),
(20200331154239),
(20200331152959),
(20200329191919),
(20200327213851),
(20200327140330),
(20200325195452),
(20200325163633),
(20200325135627),
(20200320204602),
(20200319174637),
(20200318173348),
(20200317201339),
(20200312141035),
(20200311174950),
(20200303165006),
(20200303042719),
(20200302211911),
(20200302182818),
(20200227193814),
(20200227024847),
(20200226014642),
(20200225164301),
(20200224212658),
(20200224211514),
(20200218194056),
(20200211155911),
(20200211005324),
(20200210200708),
(20200210183407),
(20200202220944),
(20200130024406),
(20200130011111),
(20200128155430),
(20200126221536),
(20200124040625),
(20200124040048),
(20200124035328),
(20200123164205),
(20200123030637),
(20200122223217),
(20190818213426),
(20190818211908),
(20190730164747),
(20190730143901),
(20190607163746),
(20190607135753),
(20190606164709),
(20190606145018),
(20190605203035),
(20190605192812),
(20190522203136),
(20190522182115),
(20190521165143),
(20190521153351),
(20190521140305),
(20190520201827),
(20190315162658),
(20190313183651),
(20190313163553),
(20190311204150),
(20190308185308),
(20190308170458),
(20190307214310),
(20190307162931);

