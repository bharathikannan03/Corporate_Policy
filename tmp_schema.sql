--
-- PostgreSQL database dump
--

\restrict ku1jgzsx3tIDoUyr70xAG81izbaj5zE69PyhLkAHejspcMC67MKiAs9CZuaKjBY

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: mapping_policy_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mapping_policy_completions (
    id bigint NOT NULL,
    ref_policy_id bigint NOT NULL,
    section_id integer NOT NULL,
    is_completed boolean DEFAULT false,
    completed_by bigint,
    completed_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mapping_policy_completions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mapping_policy_completions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mapping_policy_completions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mapping_policy_completions_id_seq OWNED BY public.mapping_policy_completions.id;


--
-- Name: mapping_policy_feature_templates_corporates_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mapping_policy_feature_templates_corporates_policies (
    policy_feature_template_field_value_id bigint CONSTRAINT mapping_policy_feature_temp_policy_feature_template_fi_not_null NOT NULL,
    ref_policy_feature_template_field_name character varying(255),
    policy_feature_template_field_value text,
    ref_template_id integer,
    ref_coporate_id integer,
    ref_policy_id integer,
    ref_policy_feature_template_field_id integer,
    ref_policy_feature_template_field_type_id integer,
    policy_feature_template_field_visibility_role_ids character varying(255),
    status integer DEFAULT 0,
    deleted_at timestamp(0) without time zone,
    ref_policyidentifier_id integer,
    created_by bigint,
    updated_by bigint,
    inserted_at timestamp(0) without time zone CONSTRAINT mapping_policy_feature_templates_corporate_inserted_at_not_null NOT NULL,
    updated_at timestamp(0) without time zone CONSTRAINT mapping_policy_feature_templates_corporates_updated_at_not_null NOT NULL
);


--
-- Name: mapping_policy_feature_templa_policy_feature_template_field_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mapping_policy_feature_templa_policy_feature_template_field_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mapping_policy_feature_templa_policy_feature_template_field_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mapping_policy_feature_templa_policy_feature_template_field_seq OWNED BY public.mapping_policy_feature_templates_corporates_policies.policy_feature_template_field_value_id;


--
-- Name: master_add_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_add_policies (
    id bigint NOT NULL,
    corporate_name character varying(100) NOT NULL,
    ref_corporate_id bigint NOT NULL,
    ref_md_line_of_businesses_id bigint NOT NULL,
    line_of_business character varying(100) NOT NULL,
    ref_md_policy_types_id bigint NOT NULL,
    policy_type character varying(100) NOT NULL,
    ref_md_sum_insured_types_id bigint,
    sum_insured_type character varying(100),
    ref_select_insurer_id bigint NOT NULL,
    select_insurer character varying(255) NOT NULL,
    select_tpa text,
    ref_tpa_id bigint,
    have_policy_number integer DEFAULT 0 NOT NULL,
    policy_number character varying(100),
    policy_start_date date,
    policy_end_date date,
    ref_md_family_definitions_id bigint,
    family_definition character varying(100),
    ref_md_claim_submission_visibilities_id bigint DEFAULT 0,
    claim_submission_additional_email text,
    ref_intimate_claim_visibilities_id bigint,
    intimate_claim_visibility character varying(50),
    status integer DEFAULT 0 NOT NULL,
    user_id bigint,
    ref_fy_year_id bigint NOT NULL,
    created_by bigint,
    updated_by bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    policy_number_identifier character varying(100)
);


--
-- Name: master_add_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_add_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_add_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_add_policies_id_seq OWNED BY public.master_add_policies.id;


--
-- Name: master_cd_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_cd_accounts (
    id bigint NOT NULL,
    cd_name character varying(100) NOT NULL,
    cd_number character varying(100) NOT NULL,
    ref_corporate_id bigint NOT NULL,
    corporate_name character varying(100) NOT NULL,
    ref_insurer_id bigint NOT NULL,
    insurer_name character varying(100) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_cd_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_cd_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_cd_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_cd_accounts_id_seq OWNED BY public.master_cd_accounts.id;


--
-- Name: trp_claim_submission_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trp_claim_submission_logs (
    id bigint CONSTRAINT master_claim_logs_id_not_null NOT NULL,
    claim_id bigint CONSTRAINT master_claim_logs_claim_id_not_null NOT NULL,
    policy_id integer CONSTRAINT master_claim_logs_policy_id_not_null NOT NULL,
    portal_id integer CONSTRAINT master_claim_logs_portal_id_not_null NOT NULL,
    action character varying(255) CONSTRAINT master_claim_logs_action_not_null NOT NULL,
    remarks text,
    user_id bigint,
    inserted_at timestamp without time zone CONSTRAINT master_claim_logs_inserted_at_not_null NOT NULL,
    submitted_by bigint,
    claim_number character varying(255),
    policy_number character varying(255),
    corporate_name character varying(255),
    policy_type character varying(255),
    insurer_name character varying(255),
    employee_code character varying(255),
    patient_name character varying(255),
    relationship character varying(255),
    claim_status character varying(255),
    estimated_amount numeric(12,2),
    hospital_name character varying(255),
    city character varying(255),
    state character varying(255)
);


--
-- Name: master_claim_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_claim_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_claim_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_claim_logs_id_seq OWNED BY public.trp_claim_submission_logs.id;


--
-- Name: master_claim_submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_claim_submission (
    id bigint NOT NULL,
    ref_corporate_id integer NOT NULL,
    ref_policy_id bigint NOT NULL,
    portal_id integer NOT NULL,
    claim_number character varying(255) NOT NULL,
    intimation_number character varying(255),
    corporate_name character varying(255),
    policy_number character varying(255),
    policy_type character varying(255),
    insurer_name character varying(255),
    tpa_name character varying(255),
    employee_code character varying(255) NOT NULL,
    employee_name character varying(255),
    patient_name character varying(255) NOT NULL,
    relationship character varying(255),
    estimated_amount numeric(12,2) NOT NULL,
    claim_reason text NOT NULL,
    claim_type character varying(255) NOT NULL,
    hospital_name character varying(255) NOT NULL,
    hospital_address text NOT NULL,
    hospitalization_date date NOT NULL,
    discharge_date date NOT NULL,
    city character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    pincode character varying(255) NOT NULL,
    treatment_details text,
    remarks text,
    claim_status character varying(255) DEFAULT 'Draft'::character varying NOT NULL,
    submitted_at timestamp without time zone,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    submitted_by bigint
);


--
-- Name: master_claim_submission_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_claim_submission_documents (
    id bigint NOT NULL,
    claim_id bigint NOT NULL,
    policy_id integer NOT NULL,
    document_name character varying(255) NOT NULL,
    original_file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    mime_type character varying(255),
    file_size integer,
    status integer DEFAULT 1,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_claim_submission_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_claim_submission_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_claim_submission_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_claim_submission_documents_id_seq OWNED BY public.master_claim_submission_documents.id;


--
-- Name: master_claim_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_claim_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_claim_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_claim_submission_id_seq OWNED BY public.master_claim_submission.id;


--
-- Name: master_corporates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_corporates (
    corporate_id bigint NOT NULL,
    corporate_name character varying(255) NOT NULL,
    ref_master_corporate_logos_id integer,
    coporate_contact_email character varying(255),
    corporate_landline character varying(255),
    ref_master_pincode_pincode_id integer DEFAULT 0 NOT NULL,
    ref_master_city_city_id integer DEFAULT 0 NOT NULL,
    ref_master_state_state_id integer DEFAULT 0 NOT NULL,
    corporate_address character varying(255) NOT NULL,
    corporate_group_code character varying(255),
    industry_type character varying(255),
    corporate_buffer_visibility integer DEFAULT 0 NOT NULL,
    corporate_status integer DEFAULT 0 NOT NULL,
    pincode character varying(10) DEFAULT ''::character varying NOT NULL,
    city character varying(25) DEFAULT ''::character varying NOT NULL,
    state character varying(25) DEFAULT ''::character varying NOT NULL,
    helpline_no character varying(255),
    pan_number character varying(15),
    branch_name character varying(255),
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: master_corporates_corporate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_corporates_corporate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_corporates_corporate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_corporates_corporate_id_seq OWNED BY public.master_corporates.corporate_id;


--
-- Name: master_ecards_data_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_ecards_data_uploads (
    id bigint NOT NULL,
    ref_doc_id integer,
    employee_code character varying(255),
    ecard_data_originalname character varying(255),
    ecards_data_url character varying(255) NOT NULL,
    ref_policy_id bigint NOT NULL,
    data_upload integer DEFAULT 0,
    status integer DEFAULT 0,
    created_by integer,
    updated_by integer,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_ecards_data_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_ecards_data_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_ecards_data_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_ecards_data_uploads_id_seq OWNED BY public.master_ecards_data_uploads.id;


--
-- Name: master_endorsement_data_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_endorsement_data_uploads (
    id bigint NOT NULL,
    employee_code character varying(255),
    employee_name character varying(255),
    gender character varying(255),
    relationship character varying(255),
    dob character varying(255),
    age character varying(255),
    mobile_number character varying(255),
    email character varying(255),
    sum_insured character varying(255),
    doj character varying(255),
    endorsement_number character varying(255),
    endorsement_date character varying(255),
    endorsement_type character varying(255),
    dol character varying(255),
    member_card_number character varying(255),
    designation character varying(255),
    status integer DEFAULT 0,
    ref_policy_id bigint NOT NULL,
    is_register integer DEFAULT 0,
    is_mail_send integer DEFAULT 0,
    is_testuser integer DEFAULT 0,
    created_by integer,
    updated_by integer,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_endorsement_data_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_endorsement_data_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_endorsement_data_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_endorsement_data_uploads_id_seq OWNED BY public.master_endorsement_data_uploads.id;


--
-- Name: master_escalation_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_escalation_matrices (
    id bigint NOT NULL,
    fullname character varying(150),
    phone_number character varying(15),
    mobile_number character varying(15),
    email_id character varying(50),
    alt_email_id character varying(50),
    send_mail_alt_email boolean,
    company_fulladdress text,
    type character varying(30),
    type_id integer,
    status integer DEFAULT 1 NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_escalation_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_escalation_matrices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_escalation_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_escalation_matrices_id_seq OWNED BY public.master_escalation_matrices.id;


--
-- Name: master_inception_data_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_inception_data_uploads (
    id bigint NOT NULL,
    ref_policy_id bigint NOT NULL,
    employee_code character varying(255),
    employee_name character varying(255),
    gender character varying(255),
    relationship character varying(255),
    dob character varying(255),
    age integer,
    mobile_number character varying(255),
    email character varying(255),
    sum_insured double precision,
    doj character varying(255),
    endorsement_number character varying(255),
    endorsement_date character varying(255),
    endorsement_type character varying(255),
    dol character varying(255),
    member_card_number character varying(255),
    designation character varying(255),
    status character varying(255) DEFAULT '0'::character varying,
    otp integer,
    otp_expires_at timestamp(0) without time zone,
    is_register integer DEFAULT 0,
    is_mail_send integer DEFAULT 0,
    is_testuser integer DEFAULT 0,
    created_by integer,
    updated_by integer,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_inception_data_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_inception_data_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_inception_data_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_inception_data_uploads_id_seq OWNED BY public.master_inception_data_uploads.id;


--
-- Name: master_logos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_logos (
    logo_id bigint NOT NULL,
    logo character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_logos_logo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_logos_logo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_logos_logo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_logos_logo_id_seq OWNED BY public.master_logos.logo_id;


--
-- Name: master_policy_cd_statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_cd_statements (
    id bigint NOT NULL,
    corporate_name character varying(255) NOT NULL,
    corporate_id integer NOT NULL,
    cd_number character varying(255) NOT NULL,
    cd_account_id integer NOT NULL,
    data_upload_file character varying(255),
    policy_id integer,
    is_dataupload boolean DEFAULT true,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_policy_cd_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_cd_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_cd_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_cd_statements_id_seq OWNED BY public.master_policy_cd_statements.id;


--
-- Name: master_policy_corporate_buffer_amounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_corporate_buffer_amounts (
    id bigint NOT NULL,
    ref_policy_id bigint NOT NULL,
    buffer_amount numeric(15,2),
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_policy_corporate_buffer_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_corporate_buffer_amounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_corporate_buffer_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_corporate_buffer_amounts_id_seq OWNED BY public.master_policy_corporate_buffer_amounts.id;


--
-- Name: master_policy_corporate_buffer_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_corporate_buffer_transactions (
    id bigint NOT NULL,
    ref_policy_id bigint CONSTRAINT master_policy_corporate_buffer_transacti_ref_policy_id_not_null NOT NULL,
    ref_buffer_amount_id bigint CONSTRAINT master_policy_corporate_buffer_tr_ref_buffer_amount_id_not_null NOT NULL,
    transaction_type character varying(50),
    amount numeric(15,2),
    description text,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone CONSTRAINT master_policy_corporate_buffer_transaction_inserted_at_not_null NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_policy_corporate_buffer_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_corporate_buffer_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_corporate_buffer_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_corporate_buffer_transactions_id_seq OWNED BY public.master_policy_corporate_buffer_transactions.id;


--
-- Name: master_policy_data_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_data_uploads (
    id bigint NOT NULL,
    data_type character varying(100) NOT NULL,
    remark character varying(100),
    file_path character varying(255) NOT NULL,
    policy_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    is_dataupload boolean DEFAULT false NOT NULL,
    original_file_name character varying(200),
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_policy_data_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_data_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_data_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_data_uploads_id_seq OWNED BY public.master_policy_data_uploads.id;


--
-- Name: master_policy_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_documents (
    id bigint NOT NULL,
    document_type_id integer,
    document_type character varying(100),
    document_name_id integer,
    document_name character varying(100),
    note text,
    file_path character varying(255) NOT NULL,
    policy_id integer NOT NULL,
    status integer DEFAULT 0,
    original_file_name character varying(200),
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_policy_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_documents_id_seq OWNED BY public.master_policy_documents.id;


--
-- Name: master_policy_escalation_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_escalation_matrices (
    id bigint NOT NULL,
    escalation_level_id integer,
    level character varying(100),
    user_id integer,
    user_fullname character varying(100),
    policy_id integer,
    status integer DEFAULT 0,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_policy_escalation_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_escalation_matrices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_escalation_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_escalation_matrices_id_seq OWNED BY public.master_policy_escalation_matrices.id;


--
-- Name: master_policy_feature_template_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_feature_template_fields (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    placeholder character varying(255),
    field_type_id integer NOT NULL,
    template_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    is_mandatory boolean DEFAULT false NOT NULL,
    policy_identifier_id integer,
    description text,
    field_grouping_id character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_policy_feature_template_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_feature_template_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_feature_template_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_feature_template_fields_id_seq OWNED BY public.master_policy_feature_template_fields.id;


--
-- Name: master_policy_feature_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_policy_feature_templates (
    template_id bigint NOT NULL,
    policy_identifier character varying(100) NOT NULL,
    set_default integer DEFAULT 0 NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    ref_policy_id character varying(100),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: master_policy_feature_templates_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_policy_feature_templates_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_policy_feature_templates_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_policy_feature_templates_template_id_seq OWNED BY public.master_policy_feature_templates.template_id;


--
-- Name: master_sum_insureds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_sum_insureds (
    id bigint NOT NULL,
    sum_insured integer NOT NULL,
    policy_feature_identifier character varying(100) NOT NULL,
    template_id integer NOT NULL,
    policy_id integer NOT NULL,
    feature_identifier_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_sum_insureds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_sum_insureds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_sum_insureds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_sum_insureds_id_seq OWNED BY public.master_sum_insureds.id;


--
-- Name: master_total_claim_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_total_claim_reports (
    id bigint NOT NULL,
    ref_policy_id bigint,
    employee_code character varying(255),
    employee_name character varying(255),
    patient_name character varying(255),
    relationship character varying(255),
    claim_type character varying(255),
    tpa_claim_no character varying(255),
    date_of_hospitalization character varying(255),
    date_of_discharge character varying(255),
    hospital_name character varying(255),
    amount_claimed double precision,
    amount_sanctioned double precision,
    claim_status character varying(255),
    patient_gender character varying(255),
    hospital_state character varying(255),
    network_status character varying(255),
    treatment_type character varying(255),
    level_of_care character varying(255),
    cause character varying(255),
    city character varying(255),
    age integer,
    claim_file_submitted_dt character varying(255),
    claim_settled_date character varying(255),
    disease_category character varying(255),
    claim_registered_date character varying(255),
    intimation_method character varying(255),
    sum_insured double precision,
    tds_amount double precision,
    deduction_amount double precision,
    deduction_reason character varying(255),
    deficiency_intimated_date character varying(255),
    deficiency_submission_date character varying(255),
    icd_code character varying(255),
    claim_paid_amount double precision,
    close_reasons character varying(255),
    deficiency_reason text,
    claim_sub_status character varying(255),
    insurance_claim_no character varying(255),
    status integer DEFAULT 0,
    created_by integer,
    updated_by integer,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: master_total_claim_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_total_claim_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_total_claim_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_total_claim_reports_id_seq OWNED BY public.master_total_claim_reports.id;


--
-- Name: md_cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_cities (
    city_id bigint NOT NULL,
    city character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_cities_city_id_seq OWNED BY public.md_cities.city_id;


--
-- Name: md_data_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_data_types (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: md_data_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_data_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_data_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_data_types_id_seq OWNED BY public.md_data_types.id;


--
-- Name: md_document_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_document_names (
    id bigint NOT NULL,
    document_type_id bigint,
    document_name character varying(100),
    status integer DEFAULT 0,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: md_document_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_document_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_document_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_document_names_id_seq OWNED BY public.md_document_names.id;


--
-- Name: md_document_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_document_types (
    id bigint NOT NULL,
    document_type character varying(100),
    status integer DEFAULT 0,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: md_document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_document_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_document_types_id_seq OWNED BY public.md_document_types.id;


--
-- Name: md_escalation_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_escalation_matrices (
    id bigint NOT NULL,
    level character varying(255),
    status integer DEFAULT 0,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: md_escalation_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_escalation_matrices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_escalation_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_escalation_matrices_id_seq OWNED BY public.md_escalation_matrices.id;


--
-- Name: md_family_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_family_definitions (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    display_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_family_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_family_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_family_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_family_definitions_id_seq OWNED BY public.md_family_definitions.id;


--
-- Name: md_financial_years; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_financial_years (
    id bigint NOT NULL,
    year_name character varying(50) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_financial_years_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_financial_years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_financial_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_financial_years_id_seq OWNED BY public.md_financial_years.id;


--
-- Name: md_insurer_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_insurer_lists (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_md_line_of_businesses_id bigint
);


--
-- Name: md_insurer_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_insurer_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_insurer_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_insurer_lists_id_seq OWNED BY public.md_insurer_lists.id;


--
-- Name: md_intimate_claim_visibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_intimate_claim_visibilities (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    display_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_intimate_claim_visibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_intimate_claim_visibilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_intimate_claim_visibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_intimate_claim_visibilities_id_seq OWNED BY public.md_intimate_claim_visibilities.id;


--
-- Name: md_line_of_businesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_line_of_businesses (
    id bigint NOT NULL,
    line_of_business_value character varying(100) NOT NULL,
    display_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_line_of_businesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_line_of_businesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_line_of_businesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_line_of_businesses_id_seq OWNED BY public.md_line_of_businesses.id;


--
-- Name: md_pincodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_pincodes (
    pincode_id bigint NOT NULL,
    pincode integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_pincodes_pincode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_pincodes_pincode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_pincodes_pincode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_pincodes_pincode_id_seq OWNED BY public.md_pincodes.pincode_id;


--
-- Name: md_policy_tpas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_policy_tpas (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_policy_tpas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_policy_tpas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_policy_tpas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_policy_tpas_id_seq OWNED BY public.md_policy_tpas.id;


--
-- Name: md_policy_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_policy_types (
    id bigint NOT NULL,
    policy_type_value character varying(100) NOT NULL,
    display_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref_md_line_of_businesses_id bigint
);


--
-- Name: md_policy_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_policy_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_policy_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_policy_types_id_seq OWNED BY public.md_policy_types.id;


--
-- Name: md_role_accessdetails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_role_accessdetails (
    id bigint NOT NULL,
    role_id integer NOT NULL,
    feature_id integer NOT NULL,
    can_view boolean DEFAULT false,
    can_add boolean DEFAULT false,
    can_edit boolean DEFAULT false,
    can_delete boolean DEFAULT false,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_role_accessdetails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_role_accessdetails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_role_accessdetails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_role_accessdetails_id_seq OWNED BY public.md_role_accessdetails.id;


--
-- Name: md_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_states (
    state_id bigint NOT NULL,
    state character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_states_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_states_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_states_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_states_state_id_seq OWNED BY public.md_states.state_id;


--
-- Name: md_sum_insured_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_sum_insured_types (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    display_id integer,
    status integer DEFAULT 1,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: md_sum_insured_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_sum_insured_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_sum_insured_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_sum_insured_types_id_seq OWNED BY public.md_sum_insured_types.id;


--
-- Name: md_sum_insurer_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_sum_insurer_types (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    display_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_sum_insurer_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_sum_insurer_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_sum_insurer_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_sum_insurer_types_id_seq OWNED BY public.md_sum_insurer_types.id;


--
-- Name: md_temp_field_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_temp_field_types (
    id bigint NOT NULL,
    field_type character varying(50) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_temp_field_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_temp_field_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_temp_field_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_temp_field_types_id_seq OWNED BY public.md_temp_field_types.id;


--
-- Name: md_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_user_roles (
    id bigint NOT NULL,
    user_role_id integer NOT NULL,
    user_role_information character varying(255) NOT NULL,
    status integer NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: md_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_user_roles_id_seq OWNED BY public.md_user_roles.id;


--
-- Name: md_visibility_role_id_feature_tmps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_visibility_role_id_feature_tmps (
    id bigint NOT NULL,
    ref_feature_template_field_id bigint CONSTRAINT md_visibility_role_id_featu_ref_feature_template_field_not_null NOT NULL,
    role_id integer NOT NULL,
    is_visible integer DEFAULT 2,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role character varying(255)
);


--
-- Name: md_visibility_role_id_feature_tmps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.md_visibility_role_id_feature_tmps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: md_visibility_role_id_feature_tmps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.md_visibility_role_id_feature_tmps_id_seq OWNED BY public.md_visibility_role_id_feature_tmps.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: trn_endorsement_deletion_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_endorsement_deletion_logs (
    id bigint NOT NULL,
    ref_policy_id bigint NOT NULL,
    ref_corporate_id bigint,
    employee_code character varying(255),
    employee_name character varying(255),
    relationship character varying(255),
    endorsement_number character varying(255),
    endorsement_date character varying(255),
    endorsement_type character varying(255),
    deletion_category character varying(255) DEFAULT 'Dependant Deletion'::character varying,
    deleted_at timestamp(0) without time zone,
    created_by integer,
    updated_by integer,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    upload_id bigint,
    action character varying(255)
);


--
-- Name: trn_endorsement_deletion_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_endorsement_deletion_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_endorsement_deletion_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_endorsement_deletion_logs_id_seq OWNED BY public.trn_endorsement_deletion_logs.id;


--
-- Name: trn_mapping_corporate_contact_email_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_mapping_corporate_contact_email_logs (
    id bigint NOT NULL,
    user_id bigint,
    sent_status character varying(255) NOT NULL,
    error_message text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trn_mapping_corporate_contact_email_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_mapping_corporate_contact_email_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_mapping_corporate_contact_email_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_mapping_corporate_contact_email_logs_id_seq OWNED BY public.trn_mapping_corporate_contact_email_logs.id;


--
-- Name: trn_mapping_corporateid_corporatecontactsids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_mapping_corporateid_corporatecontactsids (
    id bigint NOT NULL,
    corporate_id integer CONSTRAINT trn_mapping_corporateid_corporatecontacts_corporate_id_not_null NOT NULL,
    corporatecontacts_id integer CONSTRAINT trn_mapping_corporateid_corporate_corporatecontacts_id_not_null NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone CONSTRAINT trn_mapping_corporateid_corporatecontactsi_inserted_at_not_null NOT NULL,
    updated_at timestamp without time zone CONSTRAINT trn_mapping_corporateid_corporatecontactsid_updated_at_not_null NOT NULL
);


--
-- Name: trn_mapping_corporateid_corporatecontactsids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_mapping_corporateid_corporatecontactsids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_mapping_corporateid_corporatecontactsids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_mapping_corporateid_corporatecontactsids_id_seq OWNED BY public.trn_mapping_corporateid_corporatecontactsids.id;


--
-- Name: trn_mapping_live_employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_mapping_live_employees (
    id bigint NOT NULL,
    ref_policy_id bigint NOT NULL,
    employee_code character varying(255),
    employee_name character varying(255),
    gender character varying(255),
    relationship character varying(255),
    dob character varying(255),
    age integer,
    mobile_number character varying(255),
    email character varying(255),
    sum_insured double precision,
    doj character varying(255),
    endorsement_number character varying(255),
    endorsement_date character varying(255),
    endorsement_type character varying(255),
    dol character varying(255),
    member_card_number character varying(255),
    designation character varying(255),
    status character varying(255) DEFAULT 'active'::character varying,
    source_type character varying(255),
    created_by integer,
    updated_by integer,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    ref_corporate_id bigint
);


--
-- Name: trn_mapping_live_employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_mapping_live_employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_mapping_live_employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_mapping_live_employees_id_seq OWNED BY public.trn_mapping_live_employees.id;


--
-- Name: trn_mapping_pincode_city_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_mapping_pincode_city_states (
    id bigint NOT NULL,
    pincode_id integer NOT NULL,
    city_id integer NOT NULL,
    state_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trn_mapping_pincode_city_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_mapping_pincode_city_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_mapping_pincode_city_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_mapping_pincode_city_states_id_seq OWNED BY public.trn_mapping_pincode_city_states.id;


--
-- Name: trn_mapping_roleid_roleaccessdetails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trn_mapping_roleid_roleaccessdetails (
    id bigint NOT NULL,
    role_id integer NOT NULL,
    access_detail_id integer NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trn_mapping_roleid_roleaccessdetails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trn_mapping_roleid_roleaccessdetails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trn_mapping_roleid_roleaccessdetails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trn_mapping_roleid_roleaccessdetails_id_seq OWNED BY public.trn_mapping_roleid_roleaccessdetails.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email_address character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    remember_token character varying(255),
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mobile_no character varying(20),
    full_name character varying(255),
    gender character varying(20),
    dob date,
    ref_corporate_id bigint,
    ref_md_department_id bigint,
    department_name character varying(50),
    location character varying(100),
    onboarding_status_id integer DEFAULT 0,
    reporting character varying(100),
    ref_reporting_id bigint,
    designation character varying(100),
    assign_corporate character varying(100),
    test_user integer DEFAULT 0,
    corporate_username character varying(100),
    department_id integer
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
-- Name: mapping_policy_completions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_completions ALTER COLUMN id SET DEFAULT nextval('public.mapping_policy_completions_id_seq'::regclass);


--
-- Name: mapping_policy_feature_templates_corporates_policies policy_feature_template_field_value_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_feature_templates_corporates_policies ALTER COLUMN policy_feature_template_field_value_id SET DEFAULT nextval('public.mapping_policy_feature_templa_policy_feature_template_field_seq'::regclass);


--
-- Name: master_add_policies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_add_policies ALTER COLUMN id SET DEFAULT nextval('public.master_add_policies_id_seq'::regclass);


--
-- Name: master_cd_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_cd_accounts ALTER COLUMN id SET DEFAULT nextval('public.master_cd_accounts_id_seq'::regclass);


--
-- Name: master_claim_submission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission ALTER COLUMN id SET DEFAULT nextval('public.master_claim_submission_id_seq'::regclass);


--
-- Name: master_claim_submission_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission_documents ALTER COLUMN id SET DEFAULT nextval('public.master_claim_submission_documents_id_seq'::regclass);


--
-- Name: master_corporates corporate_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_corporates ALTER COLUMN corporate_id SET DEFAULT nextval('public.master_corporates_corporate_id_seq'::regclass);


--
-- Name: master_ecards_data_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_ecards_data_uploads ALTER COLUMN id SET DEFAULT nextval('public.master_ecards_data_uploads_id_seq'::regclass);


--
-- Name: master_endorsement_data_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_endorsement_data_uploads ALTER COLUMN id SET DEFAULT nextval('public.master_endorsement_data_uploads_id_seq'::regclass);


--
-- Name: master_escalation_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_escalation_matrices ALTER COLUMN id SET DEFAULT nextval('public.master_escalation_matrices_id_seq'::regclass);


--
-- Name: master_inception_data_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_inception_data_uploads ALTER COLUMN id SET DEFAULT nextval('public.master_inception_data_uploads_id_seq'::regclass);


--
-- Name: master_logos logo_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_logos ALTER COLUMN logo_id SET DEFAULT nextval('public.master_logos_logo_id_seq'::regclass);


--
-- Name: master_policy_cd_statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_cd_statements ALTER COLUMN id SET DEFAULT nextval('public.master_policy_cd_statements_id_seq'::regclass);


--
-- Name: master_policy_corporate_buffer_amounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_corporate_buffer_amounts ALTER COLUMN id SET DEFAULT nextval('public.master_policy_corporate_buffer_amounts_id_seq'::regclass);


--
-- Name: master_policy_corporate_buffer_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_corporate_buffer_transactions ALTER COLUMN id SET DEFAULT nextval('public.master_policy_corporate_buffer_transactions_id_seq'::regclass);


--
-- Name: master_policy_data_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_data_uploads ALTER COLUMN id SET DEFAULT nextval('public.master_policy_data_uploads_id_seq'::regclass);


--
-- Name: master_policy_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_documents ALTER COLUMN id SET DEFAULT nextval('public.master_policy_documents_id_seq'::regclass);


--
-- Name: master_policy_escalation_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_escalation_matrices ALTER COLUMN id SET DEFAULT nextval('public.master_policy_escalation_matrices_id_seq'::regclass);


--
-- Name: master_policy_feature_template_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_template_fields ALTER COLUMN id SET DEFAULT nextval('public.master_policy_feature_template_fields_id_seq'::regclass);


--
-- Name: master_policy_feature_templates template_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_templates ALTER COLUMN template_id SET DEFAULT nextval('public.master_policy_feature_templates_template_id_seq'::regclass);


--
-- Name: master_sum_insureds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sum_insureds ALTER COLUMN id SET DEFAULT nextval('public.master_sum_insureds_id_seq'::regclass);


--
-- Name: master_total_claim_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_total_claim_reports ALTER COLUMN id SET DEFAULT nextval('public.master_total_claim_reports_id_seq'::regclass);


--
-- Name: md_cities city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_cities ALTER COLUMN city_id SET DEFAULT nextval('public.md_cities_city_id_seq'::regclass);


--
-- Name: md_data_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_data_types ALTER COLUMN id SET DEFAULT nextval('public.md_data_types_id_seq'::regclass);


--
-- Name: md_document_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_names ALTER COLUMN id SET DEFAULT nextval('public.md_document_names_id_seq'::regclass);


--
-- Name: md_document_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_types ALTER COLUMN id SET DEFAULT nextval('public.md_document_types_id_seq'::regclass);


--
-- Name: md_escalation_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_escalation_matrices ALTER COLUMN id SET DEFAULT nextval('public.md_escalation_matrices_id_seq'::regclass);


--
-- Name: md_family_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_family_definitions ALTER COLUMN id SET DEFAULT nextval('public.md_family_definitions_id_seq'::regclass);


--
-- Name: md_financial_years id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_financial_years ALTER COLUMN id SET DEFAULT nextval('public.md_financial_years_id_seq'::regclass);


--
-- Name: md_insurer_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_insurer_lists ALTER COLUMN id SET DEFAULT nextval('public.md_insurer_lists_id_seq'::regclass);


--
-- Name: md_intimate_claim_visibilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_intimate_claim_visibilities ALTER COLUMN id SET DEFAULT nextval('public.md_intimate_claim_visibilities_id_seq'::regclass);


--
-- Name: md_line_of_businesses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_line_of_businesses ALTER COLUMN id SET DEFAULT nextval('public.md_line_of_businesses_id_seq'::regclass);


--
-- Name: md_pincodes pincode_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_pincodes ALTER COLUMN pincode_id SET DEFAULT nextval('public.md_pincodes_pincode_id_seq'::regclass);


--
-- Name: md_policy_tpas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_policy_tpas ALTER COLUMN id SET DEFAULT nextval('public.md_policy_tpas_id_seq'::regclass);


--
-- Name: md_policy_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_policy_types ALTER COLUMN id SET DEFAULT nextval('public.md_policy_types_id_seq'::regclass);


--
-- Name: md_role_accessdetails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_role_accessdetails ALTER COLUMN id SET DEFAULT nextval('public.md_role_accessdetails_id_seq'::regclass);


--
-- Name: md_states state_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_states ALTER COLUMN state_id SET DEFAULT nextval('public.md_states_state_id_seq'::regclass);


--
-- Name: md_sum_insured_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_sum_insured_types ALTER COLUMN id SET DEFAULT nextval('public.md_sum_insured_types_id_seq'::regclass);


--
-- Name: md_sum_insurer_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_sum_insurer_types ALTER COLUMN id SET DEFAULT nextval('public.md_sum_insurer_types_id_seq'::regclass);


--
-- Name: md_temp_field_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_temp_field_types ALTER COLUMN id SET DEFAULT nextval('public.md_temp_field_types_id_seq'::regclass);


--
-- Name: md_user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_user_roles ALTER COLUMN id SET DEFAULT nextval('public.md_user_roles_id_seq'::regclass);


--
-- Name: md_visibility_role_id_feature_tmps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_visibility_role_id_feature_tmps ALTER COLUMN id SET DEFAULT nextval('public.md_visibility_role_id_feature_tmps_id_seq'::regclass);


--
-- Name: trn_endorsement_deletion_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_endorsement_deletion_logs ALTER COLUMN id SET DEFAULT nextval('public.trn_endorsement_deletion_logs_id_seq'::regclass);


--
-- Name: trn_mapping_corporate_contact_email_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_corporate_contact_email_logs ALTER COLUMN id SET DEFAULT nextval('public.trn_mapping_corporate_contact_email_logs_id_seq'::regclass);


--
-- Name: trn_mapping_corporateid_corporatecontactsids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_corporateid_corporatecontactsids ALTER COLUMN id SET DEFAULT nextval('public.trn_mapping_corporateid_corporatecontactsids_id_seq'::regclass);


--
-- Name: trn_mapping_live_employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_live_employees ALTER COLUMN id SET DEFAULT nextval('public.trn_mapping_live_employees_id_seq'::regclass);


--
-- Name: trn_mapping_pincode_city_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_pincode_city_states ALTER COLUMN id SET DEFAULT nextval('public.trn_mapping_pincode_city_states_id_seq'::regclass);


--
-- Name: trn_mapping_roleid_roleaccessdetails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_roleid_roleaccessdetails ALTER COLUMN id SET DEFAULT nextval('public.trn_mapping_roleid_roleaccessdetails_id_seq'::regclass);


--
-- Name: trp_claim_submission_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trp_claim_submission_logs ALTER COLUMN id SET DEFAULT nextval('public.master_claim_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: mapping_policy_completions mapping_policy_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_completions
    ADD CONSTRAINT mapping_policy_completions_pkey PRIMARY KEY (id);


--
-- Name: mapping_policy_feature_templates_corporates_policies mapping_policy_feature_templates_corporates_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_feature_templates_corporates_policies
    ADD CONSTRAINT mapping_policy_feature_templates_corporates_policies_pkey PRIMARY KEY (policy_feature_template_field_value_id);


--
-- Name: master_add_policies master_add_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_add_policies
    ADD CONSTRAINT master_add_policies_pkey PRIMARY KEY (id);


--
-- Name: master_cd_accounts master_cd_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_cd_accounts
    ADD CONSTRAINT master_cd_accounts_pkey PRIMARY KEY (id);


--
-- Name: trp_claim_submission_logs master_claim_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trp_claim_submission_logs
    ADD CONSTRAINT master_claim_logs_pkey PRIMARY KEY (id);


--
-- Name: master_claim_submission_documents master_claim_submission_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission_documents
    ADD CONSTRAINT master_claim_submission_documents_pkey PRIMARY KEY (id);


--
-- Name: master_claim_submission master_claim_submission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission
    ADD CONSTRAINT master_claim_submission_pkey PRIMARY KEY (id);


--
-- Name: master_corporates master_corporates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_corporates
    ADD CONSTRAINT master_corporates_pkey PRIMARY KEY (corporate_id);


--
-- Name: master_ecards_data_uploads master_ecards_data_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_ecards_data_uploads
    ADD CONSTRAINT master_ecards_data_uploads_pkey PRIMARY KEY (id);


--
-- Name: master_endorsement_data_uploads master_endorsement_data_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_endorsement_data_uploads
    ADD CONSTRAINT master_endorsement_data_uploads_pkey PRIMARY KEY (id);


--
-- Name: master_escalation_matrices master_escalation_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_escalation_matrices
    ADD CONSTRAINT master_escalation_matrices_pkey PRIMARY KEY (id);


--
-- Name: master_inception_data_uploads master_inception_data_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_inception_data_uploads
    ADD CONSTRAINT master_inception_data_uploads_pkey PRIMARY KEY (id);


--
-- Name: master_logos master_logos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_logos
    ADD CONSTRAINT master_logos_pkey PRIMARY KEY (logo_id);


--
-- Name: master_policy_cd_statements master_policy_cd_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_cd_statements
    ADD CONSTRAINT master_policy_cd_statements_pkey PRIMARY KEY (id);


--
-- Name: master_policy_corporate_buffer_amounts master_policy_corporate_buffer_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_corporate_buffer_amounts
    ADD CONSTRAINT master_policy_corporate_buffer_amounts_pkey PRIMARY KEY (id);


--
-- Name: master_policy_corporate_buffer_transactions master_policy_corporate_buffer_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_corporate_buffer_transactions
    ADD CONSTRAINT master_policy_corporate_buffer_transactions_pkey PRIMARY KEY (id);


--
-- Name: master_policy_data_uploads master_policy_data_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_data_uploads
    ADD CONSTRAINT master_policy_data_uploads_pkey PRIMARY KEY (id);


--
-- Name: master_policy_documents master_policy_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_documents
    ADD CONSTRAINT master_policy_documents_pkey PRIMARY KEY (id);


--
-- Name: master_policy_escalation_matrices master_policy_escalation_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_escalation_matrices
    ADD CONSTRAINT master_policy_escalation_matrices_pkey PRIMARY KEY (id);


--
-- Name: master_policy_feature_template_fields master_policy_feature_template_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_template_fields
    ADD CONSTRAINT master_policy_feature_template_fields_pkey PRIMARY KEY (id);


--
-- Name: master_policy_feature_templates master_policy_feature_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_templates
    ADD CONSTRAINT master_policy_feature_templates_pkey PRIMARY KEY (template_id);


--
-- Name: master_sum_insureds master_sum_insureds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sum_insureds
    ADD CONSTRAINT master_sum_insureds_pkey PRIMARY KEY (id);


--
-- Name: master_total_claim_reports master_total_claim_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_total_claim_reports
    ADD CONSTRAINT master_total_claim_reports_pkey PRIMARY KEY (id);


--
-- Name: md_cities md_cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_cities
    ADD CONSTRAINT md_cities_pkey PRIMARY KEY (city_id);


--
-- Name: md_data_types md_data_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_data_types
    ADD CONSTRAINT md_data_types_pkey PRIMARY KEY (id);


--
-- Name: md_document_names md_document_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_names
    ADD CONSTRAINT md_document_names_pkey PRIMARY KEY (id);


--
-- Name: md_document_types md_document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_types
    ADD CONSTRAINT md_document_types_pkey PRIMARY KEY (id);


--
-- Name: md_escalation_matrices md_escalation_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_escalation_matrices
    ADD CONSTRAINT md_escalation_matrices_pkey PRIMARY KEY (id);


--
-- Name: md_family_definitions md_family_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_family_definitions
    ADD CONSTRAINT md_family_definitions_pkey PRIMARY KEY (id);


--
-- Name: md_financial_years md_financial_years_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_financial_years
    ADD CONSTRAINT md_financial_years_pkey PRIMARY KEY (id);


--
-- Name: md_insurer_lists md_insurer_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_insurer_lists
    ADD CONSTRAINT md_insurer_lists_pkey PRIMARY KEY (id);


--
-- Name: md_intimate_claim_visibilities md_intimate_claim_visibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_intimate_claim_visibilities
    ADD CONSTRAINT md_intimate_claim_visibilities_pkey PRIMARY KEY (id);


--
-- Name: md_line_of_businesses md_line_of_businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_line_of_businesses
    ADD CONSTRAINT md_line_of_businesses_pkey PRIMARY KEY (id);


--
-- Name: md_pincodes md_pincodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_pincodes
    ADD CONSTRAINT md_pincodes_pkey PRIMARY KEY (pincode_id);


--
-- Name: md_policy_tpas md_policy_tpas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_policy_tpas
    ADD CONSTRAINT md_policy_tpas_pkey PRIMARY KEY (id);


--
-- Name: md_policy_types md_policy_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_policy_types
    ADD CONSTRAINT md_policy_types_pkey PRIMARY KEY (id);


--
-- Name: md_role_accessdetails md_role_accessdetails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_role_accessdetails
    ADD CONSTRAINT md_role_accessdetails_pkey PRIMARY KEY (id);


--
-- Name: md_states md_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_states
    ADD CONSTRAINT md_states_pkey PRIMARY KEY (state_id);


--
-- Name: md_sum_insured_types md_sum_insured_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_sum_insured_types
    ADD CONSTRAINT md_sum_insured_types_pkey PRIMARY KEY (id);


--
-- Name: md_sum_insurer_types md_sum_insurer_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_sum_insurer_types
    ADD CONSTRAINT md_sum_insurer_types_pkey PRIMARY KEY (id);


--
-- Name: md_temp_field_types md_temp_field_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_temp_field_types
    ADD CONSTRAINT md_temp_field_types_pkey PRIMARY KEY (id);


--
-- Name: md_user_roles md_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_user_roles
    ADD CONSTRAINT md_user_roles_pkey PRIMARY KEY (id);


--
-- Name: md_visibility_role_id_feature_tmps md_visibility_role_id_feature_tmps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_visibility_role_id_feature_tmps
    ADD CONSTRAINT md_visibility_role_id_feature_tmps_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: trn_endorsement_deletion_logs trn_endorsement_deletion_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_endorsement_deletion_logs
    ADD CONSTRAINT trn_endorsement_deletion_logs_pkey PRIMARY KEY (id);


--
-- Name: trn_mapping_corporate_contact_email_logs trn_mapping_corporate_contact_email_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_corporate_contact_email_logs
    ADD CONSTRAINT trn_mapping_corporate_contact_email_logs_pkey PRIMARY KEY (id);


--
-- Name: trn_mapping_corporateid_corporatecontactsids trn_mapping_corporateid_corporatecontactsids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_corporateid_corporatecontactsids
    ADD CONSTRAINT trn_mapping_corporateid_corporatecontactsids_pkey PRIMARY KEY (id);


--
-- Name: trn_mapping_live_employees trn_mapping_live_employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_live_employees
    ADD CONSTRAINT trn_mapping_live_employees_pkey PRIMARY KEY (id);


--
-- Name: trn_mapping_pincode_city_states trn_mapping_pincode_city_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_pincode_city_states
    ADD CONSTRAINT trn_mapping_pincode_city_states_pkey PRIMARY KEY (id);


--
-- Name: trn_mapping_roleid_roleaccessdetails trn_mapping_roleid_roleaccessdetails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_roleid_roleaccessdetails
    ADD CONSTRAINT trn_mapping_roleid_roleaccessdetails_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: mapping_policy_completions_ref_policy_id_section_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mapping_policy_completions_ref_policy_id_section_id_index ON public.mapping_policy_completions USING btree (ref_policy_id, section_id);


--
-- Name: master_add_policies_policy_number_identifier_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_policy_number_identifier_index ON public.master_add_policies USING btree (policy_number_identifier);


--
-- Name: master_add_policies_policy_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_policy_number_index ON public.master_add_policies USING btree (policy_number);


--
-- Name: master_add_policies_ref_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_ref_corporate_id_index ON public.master_add_policies USING btree (ref_corporate_id);


--
-- Name: master_add_policies_ref_fy_year_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_ref_fy_year_id_index ON public.master_add_policies USING btree (ref_fy_year_id);


--
-- Name: master_add_policies_ref_tpa_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_ref_tpa_id_index ON public.master_add_policies USING btree (ref_tpa_id);


--
-- Name: master_add_policies_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_add_policies_status_index ON public.master_add_policies USING btree (status);


--
-- Name: master_claim_submission_claim_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX master_claim_submission_claim_number_index ON public.master_claim_submission USING btree (claim_number);


--
-- Name: master_claim_submission_claim_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_claim_status_index ON public.master_claim_submission USING btree (claim_status);


--
-- Name: master_claim_submission_documents_claim_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_documents_claim_id_index ON public.master_claim_submission_documents USING btree (claim_id);


--
-- Name: master_claim_submission_documents_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_documents_policy_id_index ON public.master_claim_submission_documents USING btree (policy_id);


--
-- Name: master_claim_submission_employee_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_employee_code_index ON public.master_claim_submission USING btree (employee_code);


--
-- Name: master_claim_submission_intimation_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX master_claim_submission_intimation_number_index ON public.master_claim_submission USING btree (intimation_number);


--
-- Name: master_claim_submission_portal_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_portal_id_index ON public.master_claim_submission USING btree (portal_id);


--
-- Name: master_claim_submission_ref_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_ref_corporate_id_index ON public.master_claim_submission USING btree (ref_corporate_id);


--
-- Name: master_claim_submission_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_claim_submission_ref_policy_id_index ON public.master_claim_submission USING btree (ref_policy_id);


--
-- Name: master_ecards_data_uploads_employee_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_ecards_data_uploads_employee_code_index ON public.master_ecards_data_uploads USING btree (employee_code);


--
-- Name: master_ecards_data_uploads_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_ecards_data_uploads_ref_policy_id_index ON public.master_ecards_data_uploads USING btree (ref_policy_id);


--
-- Name: master_endorsement_data_uploads_ref_policy_id_endorsement_type_; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_endorsement_data_uploads_ref_policy_id_endorsement_type_ ON public.master_endorsement_data_uploads USING btree (ref_policy_id, endorsement_type);


--
-- Name: master_endorsement_data_uploads_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_endorsement_data_uploads_ref_policy_id_index ON public.master_endorsement_data_uploads USING btree (ref_policy_id);


--
-- Name: master_inception_data_uploads_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_inception_data_uploads_ref_policy_id_index ON public.master_inception_data_uploads USING btree (ref_policy_id);


--
-- Name: master_policy_cd_statements_cd_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_cd_statements_cd_account_id_index ON public.master_policy_cd_statements USING btree (cd_account_id);


--
-- Name: master_policy_cd_statements_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_cd_statements_corporate_id_index ON public.master_policy_cd_statements USING btree (corporate_id);


--
-- Name: master_policy_cd_statements_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_cd_statements_policy_id_index ON public.master_policy_cd_statements USING btree (policy_id);


--
-- Name: master_policy_corporate_buffer_amounts_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_corporate_buffer_amounts_ref_policy_id_index ON public.master_policy_corporate_buffer_amounts USING btree (ref_policy_id);


--
-- Name: master_policy_corporate_buffer_transactions_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_corporate_buffer_transactions_ref_policy_id_index ON public.master_policy_corporate_buffer_transactions USING btree (ref_policy_id);


--
-- Name: master_policy_data_uploads_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_data_uploads_policy_id_index ON public.master_policy_data_uploads USING btree (policy_id);


--
-- Name: master_policy_documents_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_documents_policy_id_index ON public.master_policy_documents USING btree (policy_id);


--
-- Name: master_policy_escalation_matrices_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_escalation_matrices_policy_id_index ON public.master_policy_escalation_matrices USING btree (policy_id);


--
-- Name: master_policy_feature_template_fields_template_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_policy_feature_template_fields_template_id_index ON public.master_policy_feature_template_fields USING btree (template_id);


--
-- Name: master_sum_insureds_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_sum_insureds_policy_id_index ON public.master_sum_insureds USING btree (policy_id);


--
-- Name: master_sum_insureds_template_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_sum_insureds_template_id_index ON public.master_sum_insureds USING btree (template_id);


--
-- Name: master_total_claim_reports_employee_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_total_claim_reports_employee_code_index ON public.master_total_claim_reports USING btree (employee_code);


--
-- Name: master_total_claim_reports_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX master_total_claim_reports_ref_policy_id_index ON public.master_total_claim_reports USING btree (ref_policy_id);


--
-- Name: md_data_types_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX md_data_types_name_index ON public.md_data_types USING btree (name);


--
-- Name: md_document_names_document_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_document_names_document_type_id_index ON public.md_document_names USING btree (document_type_id);


--
-- Name: md_financial_years_year_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX md_financial_years_year_name_index ON public.md_financial_years USING btree (year_name);


--
-- Name: md_insurer_lists_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_insurer_lists_name_index ON public.md_insurer_lists USING btree (name);


--
-- Name: md_insurer_lists_ref_md_line_of_businesses_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_insurer_lists_ref_md_line_of_businesses_id_index ON public.md_insurer_lists USING btree (ref_md_line_of_businesses_id);


--
-- Name: md_line_of_businesses_line_of_business_value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX md_line_of_businesses_line_of_business_value_index ON public.md_line_of_businesses USING btree (line_of_business_value);


--
-- Name: md_policy_types_policy_type_value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX md_policy_types_policy_type_value_index ON public.md_policy_types USING btree (policy_type_value);


--
-- Name: md_policy_types_ref_md_line_of_businesses_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_policy_types_ref_md_line_of_businesses_id_index ON public.md_policy_types USING btree (ref_md_line_of_businesses_id);


--
-- Name: md_user_roles_user_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX md_user_roles_user_role_id_index ON public.md_user_roles USING btree (user_role_id);


--
-- Name: md_visibility_role_id_feature_tmps_is_visible_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_visibility_role_id_feature_tmps_is_visible_index ON public.md_visibility_role_id_feature_tmps USING btree (is_visible);


--
-- Name: md_visibility_role_id_feature_tmps_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX md_visibility_role_id_feature_tmps_role_id_index ON public.md_visibility_role_id_feature_tmps USING btree (role_id);


--
-- Name: trn_endorsement_deletion_logs_employee_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_endorsement_deletion_logs_employee_code_index ON public.trn_endorsement_deletion_logs USING btree (employee_code);


--
-- Name: trn_endorsement_deletion_logs_ref_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_endorsement_deletion_logs_ref_corporate_id_index ON public.trn_endorsement_deletion_logs USING btree (ref_corporate_id);


--
-- Name: trn_endorsement_deletion_logs_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_endorsement_deletion_logs_ref_policy_id_index ON public.trn_endorsement_deletion_logs USING btree (ref_policy_id);


--
-- Name: trn_endorsement_deletion_logs_upload_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_endorsement_deletion_logs_upload_id_index ON public.trn_endorsement_deletion_logs USING btree (upload_id);


--
-- Name: trn_mapping_corporate_contact_email_logs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_corporate_contact_email_logs_user_id_index ON public.trn_mapping_corporate_contact_email_logs USING btree (user_id);


--
-- Name: trn_mapping_live_employees_ref_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_live_employees_ref_corporate_id_index ON public.trn_mapping_live_employees USING btree (ref_corporate_id);


--
-- Name: trn_mapping_live_employees_ref_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_live_employees_ref_policy_id_index ON public.trn_mapping_live_employees USING btree (ref_policy_id);


--
-- Name: trn_mapping_pincode_city_states_city_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_pincode_city_states_city_id_index ON public.trn_mapping_pincode_city_states USING btree (city_id);


--
-- Name: trn_mapping_pincode_city_states_pincode_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_pincode_city_states_pincode_id_index ON public.trn_mapping_pincode_city_states USING btree (pincode_id);


--
-- Name: trn_mapping_pincode_city_states_state_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trn_mapping_pincode_city_states_state_id_index ON public.trn_mapping_pincode_city_states USING btree (state_id);


--
-- Name: trp_claim_submission_logs_claim_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trp_claim_submission_logs_claim_id_index ON public.trp_claim_submission_logs USING btree (claim_id);


--
-- Name: trp_claim_submission_logs_policy_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trp_claim_submission_logs_policy_id_index ON public.trp_claim_submission_logs USING btree (policy_id);


--
-- Name: trp_claim_submission_logs_portal_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trp_claim_submission_logs_portal_id_index ON public.trp_claim_submission_logs USING btree (portal_id);


--
-- Name: unique_policy_live_employee_relationship_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_policy_live_employee_relationship_index ON public.trn_mapping_live_employees USING btree (ref_policy_id, employee_code, relationship);


--
-- Name: unique_roles; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_roles ON public.md_visibility_role_id_feature_tmps USING btree (role_id, is_visible);


--
-- Name: users_corporate_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_corporate_username_index ON public.users USING btree (corporate_username);


--
-- Name: users_email_address_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_address_index ON public.users USING btree (email_address);


--
-- Name: users_ref_corporate_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_ref_corporate_id_index ON public.users USING btree (ref_corporate_id);


--
-- Name: users_ref_reporting_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_ref_reporting_id_index ON public.users USING btree (ref_reporting_id);


--
-- Name: mapping_policy_feature_templates_corporates_policies mapping_policy_feature_templates_corporates_policies_created_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_feature_templates_corporates_policies
    ADD CONSTRAINT mapping_policy_feature_templates_corporates_policies_created_by FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: mapping_policy_feature_templates_corporates_policies mapping_policy_feature_templates_corporates_policies_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mapping_policy_feature_templates_corporates_policies
    ADD CONSTRAINT mapping_policy_feature_templates_corporates_policies_updated_by FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: trp_claim_submission_logs master_claim_logs_claim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trp_claim_submission_logs
    ADD CONSTRAINT master_claim_logs_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES public.master_claim_submission(id) ON DELETE CASCADE;


--
-- Name: trp_claim_submission_logs master_claim_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trp_claim_submission_logs
    ADD CONSTRAINT master_claim_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: master_claim_submission master_claim_submission_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission
    ADD CONSTRAINT master_claim_submission_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_claim_submission_documents master_claim_submission_documents_claim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission_documents
    ADD CONSTRAINT master_claim_submission_documents_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES public.master_claim_submission(id) ON DELETE CASCADE;


--
-- Name: master_claim_submission_documents master_claim_submission_documents_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission_documents
    ADD CONSTRAINT master_claim_submission_documents_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_claim_submission_documents master_claim_submission_documents_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission_documents
    ADD CONSTRAINT master_claim_submission_documents_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_claim_submission master_claim_submission_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission
    ADD CONSTRAINT master_claim_submission_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: master_claim_submission master_claim_submission_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_claim_submission
    ADD CONSTRAINT master_claim_submission_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_ecards_data_uploads master_ecards_data_uploads_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_ecards_data_uploads
    ADD CONSTRAINT master_ecards_data_uploads_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: master_endorsement_data_uploads master_endorsement_data_uploads_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_endorsement_data_uploads
    ADD CONSTRAINT master_endorsement_data_uploads_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: master_inception_data_uploads master_inception_data_uploads_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_inception_data_uploads
    ADD CONSTRAINT master_inception_data_uploads_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: master_policy_cd_statements master_policy_cd_statements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_cd_statements
    ADD CONSTRAINT master_policy_cd_statements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_policy_cd_statements master_policy_cd_statements_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_cd_statements
    ADD CONSTRAINT master_policy_cd_statements_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_policy_data_uploads master_policy_data_uploads_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_data_uploads
    ADD CONSTRAINT master_policy_data_uploads_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_policy_data_uploads master_policy_data_uploads_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_data_uploads
    ADD CONSTRAINT master_policy_data_uploads_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_policy_documents master_policy_documents_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_documents
    ADD CONSTRAINT master_policy_documents_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_policy_documents master_policy_documents_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_documents
    ADD CONSTRAINT master_policy_documents_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_policy_escalation_matrices master_policy_escalation_matrices_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_escalation_matrices
    ADD CONSTRAINT master_policy_escalation_matrices_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_policy_escalation_matrices master_policy_escalation_matrices_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_escalation_matrices
    ADD CONSTRAINT master_policy_escalation_matrices_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_policy_feature_template_fields master_policy_feature_template_fields_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_template_fields
    ADD CONSTRAINT master_policy_feature_template_fields_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_policy_feature_template_fields master_policy_feature_template_fields_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_policy_feature_template_fields
    ADD CONSTRAINT master_policy_feature_template_fields_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_sum_insureds master_sum_insureds_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sum_insureds
    ADD CONSTRAINT master_sum_insureds_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: master_sum_insureds master_sum_insureds_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sum_insureds
    ADD CONSTRAINT master_sum_insureds_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: master_total_claim_reports master_total_claim_reports_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_total_claim_reports
    ADD CONSTRAINT master_total_claim_reports_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: md_document_names md_document_names_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_names
    ADD CONSTRAINT md_document_names_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: md_document_names md_document_names_document_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_names
    ADD CONSTRAINT md_document_names_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.md_document_types(id);


--
-- Name: md_document_names md_document_names_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_names
    ADD CONSTRAINT md_document_names_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: md_document_types md_document_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_types
    ADD CONSTRAINT md_document_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: md_document_types md_document_types_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_document_types
    ADD CONSTRAINT md_document_types_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: md_escalation_matrices md_escalation_matrices_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_escalation_matrices
    ADD CONSTRAINT md_escalation_matrices_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: md_escalation_matrices md_escalation_matrices_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_escalation_matrices
    ADD CONSTRAINT md_escalation_matrices_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: md_policy_types md_policy_types_ref_md_line_of_businesses_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.md_policy_types
    ADD CONSTRAINT md_policy_types_ref_md_line_of_businesses_id_fkey FOREIGN KEY (ref_md_line_of_businesses_id) REFERENCES public.md_line_of_businesses(id) ON DELETE SET NULL;


--
-- Name: trn_endorsement_deletion_logs trn_endorsement_deletion_logs_ref_corporate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_endorsement_deletion_logs
    ADD CONSTRAINT trn_endorsement_deletion_logs_ref_corporate_id_fkey FOREIGN KEY (ref_corporate_id) REFERENCES public.master_corporates(corporate_id);


--
-- Name: trn_endorsement_deletion_logs trn_endorsement_deletion_logs_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_endorsement_deletion_logs
    ADD CONSTRAINT trn_endorsement_deletion_logs_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- Name: trn_endorsement_deletion_logs trn_endorsement_deletion_logs_upload_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_endorsement_deletion_logs
    ADD CONSTRAINT trn_endorsement_deletion_logs_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES public.master_policy_data_uploads(id);


--
-- Name: trn_mapping_corporate_contact_email_logs trn_mapping_corporate_contact_email_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_corporate_contact_email_logs
    ADD CONSTRAINT trn_mapping_corporate_contact_email_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: trn_mapping_live_employees trn_mapping_live_employees_ref_corporate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_live_employees
    ADD CONSTRAINT trn_mapping_live_employees_ref_corporate_id_fkey FOREIGN KEY (ref_corporate_id) REFERENCES public.master_corporates(corporate_id);


--
-- Name: trn_mapping_live_employees trn_mapping_live_employees_ref_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trn_mapping_live_employees
    ADD CONSTRAINT trn_mapping_live_employees_ref_policy_id_fkey FOREIGN KEY (ref_policy_id) REFERENCES public.master_add_policies(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ku1jgzsx3tIDoUyr70xAG81izbaj5zE69PyhLkAHejspcMC67MKiAs9CZuaKjBY

INSERT INTO public."schema_migrations" (version) VALUES (20260708104739);
INSERT INTO public."schema_migrations" (version) VALUES (20260710112514);
INSERT INTO public."schema_migrations" (version) VALUES (20260710112520);
INSERT INTO public."schema_migrations" (version) VALUES (20260710112521);
INSERT INTO public."schema_migrations" (version) VALUES (20260710112522);
INSERT INTO public."schema_migrations" (version) VALUES (20260710112530);
INSERT INTO public."schema_migrations" (version) VALUES (20260710163916);
INSERT INTO public."schema_migrations" (version) VALUES (20260713073919);
INSERT INTO public."schema_migrations" (version) VALUES (20260713074704);
INSERT INTO public."schema_migrations" (version) VALUES (20260713123831);
INSERT INTO public."schema_migrations" (version) VALUES (20260713133604);
INSERT INTO public."schema_migrations" (version) VALUES (20260714095435);
INSERT INTO public."schema_migrations" (version) VALUES (20260714095833);
INSERT INTO public."schema_migrations" (version) VALUES (20260714120000);
INSERT INTO public."schema_migrations" (version) VALUES (20260714131000);
INSERT INTO public."schema_migrations" (version) VALUES (20260714182730);
INSERT INTO public."schema_migrations" (version) VALUES (20260715070345);
INSERT INTO public."schema_migrations" (version) VALUES (20260715100322);
INSERT INTO public."schema_migrations" (version) VALUES (20260715144521);
INSERT INTO public."schema_migrations" (version) VALUES (20260715150000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715160000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715170000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715180000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715190000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715200000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715210000);
INSERT INTO public."schema_migrations" (version) VALUES (20260715210001);
INSERT INTO public."schema_migrations" (version) VALUES (20260715210002);
INSERT INTO public."schema_migrations" (version) VALUES (20260716114328);
INSERT INTO public."schema_migrations" (version) VALUES (20260716120000);
INSERT INTO public."schema_migrations" (version) VALUES (20260716140000);
INSERT INTO public."schema_migrations" (version) VALUES (20260716140100);
INSERT INTO public."schema_migrations" (version) VALUES (20260716140200);
INSERT INTO public."schema_migrations" (version) VALUES (20260716140300);
INSERT INTO public."schema_migrations" (version) VALUES (20260716150000);
INSERT INTO public."schema_migrations" (version) VALUES (20260716150100);
INSERT INTO public."schema_migrations" (version) VALUES (20260717170002);
INSERT INTO public."schema_migrations" (version) VALUES (20260717170003);
INSERT INTO public."schema_migrations" (version) VALUES (20260717170004);
INSERT INTO public."schema_migrations" (version) VALUES (20260720180000);
INSERT INTO public."schema_migrations" (version) VALUES (20260720185000);
INSERT INTO public."schema_migrations" (version) VALUES (20260720185500);
INSERT INTO public."schema_migrations" (version) VALUES (20260720193000);
INSERT INTO public."schema_migrations" (version) VALUES (20260720195000);
INSERT INTO public."schema_migrations" (version) VALUES (20260721082527);
INSERT INTO public."schema_migrations" (version) VALUES (20260721085227);
INSERT INTO public."schema_migrations" (version) VALUES (20260721102305);
INSERT INTO public."schema_migrations" (version) VALUES (20260721130000);
