defmodule CorporatePolicy.Repo.Migrations.CreatePolicyTables do
  use Ecto.Migration

  def change do
    # Master tables (reference data)
    create table(:md_line_of_businesses, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :line_of_business_value, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:md_line_of_businesses, [:line_of_business_value])

    create table(:md_policy_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :policy_type_value, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:md_policy_types, [:policy_type_value])

    create table(:md_sum_insurer_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_family_definitions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_intimate_claim_visibilities, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_policy_tpas, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_financial_years, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :year_name, :string, size: 50, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :status, :integer, default: 1, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:md_financial_years, [:year_name])

    # Master corporates table (extend existing or create new)
    create table(:master_corporates, primary_key: false) do
      add :corporate_id, :bigserial, primary_key: true
      add :corporate_name, :string, size: 255, null: false
      add :corporate_address, :string, size: 255
      add :corporate_landline, :string, size: 255
      add :coporate_contact_email, :string, size: 255
      add :corporate_group_code, :string, size: 255
      add :industry_type, :string, size: 255
      add :pan_number, :string, size: 15
      add :helpline_no, :string, size: 255
      add :branch_name, :string, size: 255
      add :pincode, :string, size: 10
      add :city, :string, size: 25
      add :state, :string, size: 25
      add :ref_master_logos_corporate_logo, :bigint
      add :ref_master_pincode_pincode_id, :bigint
      add :ref_master_city_city_id, :bigint
      add :ref_master_state_state_id, :bigint
      add :corporate_buffer_visibility, :integer, default: 0, null: false
      add :corporate_status, :integer, default: 0, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Main policy table
    create table(:master_add_policies, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :corporate_name, :string, size: 100, null: false
      add :ref_corporate_id, :bigint, null: false
      add :ref_md_line_of_businesses_id, :bigint, null: false
      add :line_of_business, :string, size: 100, null: false
      add :ref_md_policy_types_id, :bigint, null: false
      add :policy_type, :string, size: 100, null: false
      add :ref_md_sum_insured_types_id, :bigint
      add :sum_insured_type, :string, size: 100
      add :ref_select_insurer_id, :bigint, null: false
      add :select_insurer, :string, size: 255, null: false
      add :select_tpa, :text
      add :ref_tpa_id, :bigint
      add :have_policy_number, :integer, default: 0, null: false
      add :policy_number, :string, size: 100
      add :policy_start_date, :date
      add :policy_end_date, :date
      add :ref_md_family_definitions_id, :bigint
      add :family_definition, :string, size: 100
      add :ref_md_claim_submission_visibilities_id, :bigint, default: 0
      add :claim_submission_additional_email, :text
      add :ref_intimate_claim_visibilities_id, :bigint
      add :intimate_claim_visibility, :string, size: 50
      add :status, :integer, default: 0, null: false
      add :user_id, :bigint
      add :ref_fy_year_id, :bigint, null: false
      add :created_by, :bigint
      add :updated_by, :bigint

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_add_policies, [:ref_corporate_id])
    create index(:master_add_policies, [:ref_fy_year_id])
    create index(:master_add_policies, [:status])
    create index(:master_add_policies, [:policy_number])
    create index(:master_add_policies, [:ref_tpa_id])

    # Policy sum insureds
    create table(:master_sum_insureds, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :sum_insured, :integer, null: false
      add :ref_policy_feature_identifier, :string, size: 100, null: false
      add :ref_template_id, :bigint, null: false
      add :ref_policy_id, :bigint, null: false
      add :status, :integer, default: 0, null: false
      add :ref_feature_identifier_id, :bigint, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_sum_insureds, [:ref_policy_id])

    # Policy feature templates
    create table(:master_policy_feature_templates, primary_key: false) do
      add :template_id, :bigserial, primary_key: true
      add :policy_identifier, :string, size: 100, null: false
      add :set_default, :integer, default: 0, null: false
      add :status, :integer, default: 1, null: false
      add :ref_policy_id, :string, size: 100

      timestamps(type: :utc_datetime_usec)
    end

    create table(:master_policy_feature_template_fields, primary_key: false) do
      add :template_field_id, :bigserial, primary_key: true
      add :policy_feature_template_field_name, :string, size: 100, null: false
      add :policy_feature_template_field_placeholder, :string, size: 255
      add :ref_master_temp_field_type, :bigint, null: false
      add :ref_template_id, :bigint, null: false
      add :status, :integer, default: 0, null: false
      add :is_mandatory, :integer, default: 0, null: false
      add :ref_policyidentifier_id, :bigint
      add :field_description, :text
      add :ref_fieldgrouping_id, :string, size: 255

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_temp_field_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :field_type, :string, size: 50, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Escalation matrices
    create table(:md_escalation_matrices, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :level, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:master_policy_escalation_matrices, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_escalation_matrices_level_id, :bigint
      add :level, :string, size: 100
      add :ref_master_users_id, :bigint
      add :ref_user_fullname, :string, size: 100
      add :ref_policy_id, :bigint
      add :status, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_policy_escalation_matrices, [:ref_policy_id])

    # Policy documents
    create table(:md_document_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :document_type, :string, size: 100, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_document_names, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :document_name, :string, size: 100, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:master_policy_documents, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_document_type_id, :bigint, null: false
      add :document_type, :string, size: 100, null: false
      add :ref_document_name_id, :bigint, null: false
      add :document_name, :string, size: 100, null: false
      add :note, :text
      add :document_file, :string, size: 255, null: false
      add :ref_policy_id, :bigint, null: false
      add :status, :integer, default: 0, null: false
      add :original_file_name, :string, size: 200

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_policy_documents, [:ref_policy_id])

    # CD Accounts
    create table(:master_cd_accounts, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :cd_name, :string, size: 100, null: false
      add :cd_number, :string, size: 100, null: false
      add :ref_corporate_id, :bigint, null: false
      add :corporate_name, :string, size: 100, null: false
      add :ref_insurer_id, :bigint, null: false
      add :insurer_name, :string, size: 100, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # CD Statements
    create table(:master_policy_cd_statements, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :corporate_name, :string, size: 255, null: false
      add :ref_corporate_id, :bigint, null: false
      add :cd_number, :string, size: 255, null: false
      add :ref_master_cd_accounts_id, :bigint, null: false
      add :data_upload_file, :string, size: 255
      add :ref_policy_id, :bigint
      add :status, :integer, default: 0, null: false
      add :is_dataupload, :integer, default: 0, null: false
      add :original_file_name, :string, size: 200

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_policy_cd_statements, [:ref_policy_id])
    create index(:master_policy_cd_statements, [:ref_corporate_id])

    # Corporate buffers
    create table(:master_policy_corporate_buffer_amounts, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :buffer_amount, :decimal, precision: 15, scale: 2
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_policy_corporate_buffer_amounts, [:ref_policy_id])

    create table(:master_policy_corporate_buffer_transactions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :ref_buffer_amount_id, :bigint, null: false
      add :transaction_type, :string, size: 50
      add :amount, :decimal, precision: 15, scale: 2
      add :description, :text
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:master_policy_corporate_buffer_transactions, [:ref_policy_id])

    # Policy completions mapping
    create table(:mapping_policy_completions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :section_id, :integer, null: false
      add :is_completed, :boolean, default: false
      add :completed_by, :bigint
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mapping_policy_completions, [:ref_policy_id, :section_id])

    # User roles
    create table(:md_user_roles, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :user_role_id, :integer, null: false
      add :user_role_information, :string, size: 255, null: false
      add :status, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:md_user_roles, [:user_role_id])

    # Role access details
    create table(:md_role_accessdetails, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: false
      add :feature_id, :integer, null: false
      add :can_view, :boolean, default: false
      add :can_add, :boolean, default: false
      add :can_edit, :boolean, default: false
      add :can_delete, :boolean, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:trn_mapping_roleid_roleaccessdetails, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: false
      add :access_detail_id, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Visibility role mapping
    create table(:md_visibility_role_id_feature_tmps, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_feature_template_field_id, :bigint, null: false
      add :role_id, :integer, null: false
      add :is_visible, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    # Extend users table with additional fields
    alter table(:users) do
      add :mobile_no, :string, size: 20
      add :full_name, :string, size: 255
      add :gender, :string, size: 20
      add :dob, :date
      add :ref_corporate_id, :bigint
      add :ref_md_department_id, :bigint
      add :department_name, :string, size: 50
      add :location, :string, size: 100
      add :onboarding_status_id, :integer, default: 0
      add :reporting, :string, size: 100
      add :ref_reporting_id, :bigint
      add :designation, :string, size: 100
      add :assign_corporate, :string, size: 100
      add :test_user, :integer, default: 0
      add :corporate_username, :string, size: 100
    end

    create index(:users, [:ref_corporate_id])
    create index(:users, [:ref_reporting_id])
    create unique_index(:users, [:corporate_username])
  end
end
