defmodule CorporatePolicy.Repo.Migrations.CreatePolicyTables do
  use Ecto.Migration

  def change do
    # Master tables (reference data)
    create_if_not_exists table(:md_sum_insurer_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:md_family_definitions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:md_intimate_claim_visibilities, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:md_policy_tpas, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:md_financial_years, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :year_name, :string, size: 50, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :status, :integer, default: 1, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:md_financial_years, [:year_name])

    # Main policy table
    create_if_not_exists table(:master_add_policies, primary_key: false) do
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

    create_if_not_exists index(:master_add_policies, [:ref_corporate_id])
    create_if_not_exists index(:master_add_policies, [:ref_fy_year_id])
    create_if_not_exists index(:master_add_policies, [:status])
    create_if_not_exists index(:master_add_policies, [:policy_number])
    create_if_not_exists index(:master_add_policies, [:ref_tpa_id])

    # Policy feature templates
    create_if_not_exists table(:master_policy_feature_templates, primary_key: false) do
      add :template_id, :bigserial, primary_key: true
      add :policy_identifier, :string, size: 100, null: false
      add :set_default, :integer, default: 0, null: false
      add :status, :integer, default: 1, null: false
      add :ref_policy_id, :string, size: 100

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:md_temp_field_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :field_type, :string, size: 50, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Corporate buffers
    create_if_not_exists table(:master_policy_corporate_buffer_amounts, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :buffer_amount, :decimal, precision: 15, scale: 2
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_policy_corporate_buffer_amounts, [:ref_policy_id])

    create_if_not_exists table(:master_policy_corporate_buffer_transactions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :ref_buffer_amount_id, :bigint, null: false
      add :transaction_type, :string, size: 50
      add :amount, :decimal, precision: 15, scale: 2
      add :description, :text
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_policy_corporate_buffer_transactions, [:ref_policy_id])

    # Policy completions mapping
    create_if_not_exists table(:mapping_policy_completions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_policy_id, :bigint, null: false
      add :section_id, :integer, null: false
      add :is_completed, :boolean, default: false
      add :completed_by, :bigint
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:mapping_policy_completions, [:ref_policy_id, :section_id])

    # User roles
    create_if_not_exists table(:md_user_roles, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :user_role_id, :integer, null: false
      add :user_role_information, :string, size: 255, null: false
      add :status, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:md_user_roles, [:user_role_id])

    # Role access details
    create_if_not_exists table(:md_role_accessdetails, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: false
      add :feature_id, :integer, null: false
      add :can_view, :boolean, default: false
      add :can_add, :boolean, default: false
      add :can_edit, :boolean, default: false
      add :can_delete, :boolean, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:trn_mapping_roleid_roleaccessdetails, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: false
      add :access_detail_id, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Visibility role mapping
    create_if_not_exists table(:md_visibility_role_id_feature_tmps, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_feature_template_field_id, :bigint, null: false
      add :role_id, :integer, null: false
      add :is_visible, :boolean, default: true

      timestamps(type: :utc_datetime_usec)
    end

    # Extend users table with additional fields
    alter table(:users) do
      add_if_not_exists :mobile_no, :string, size: 20
      add_if_not_exists :full_name, :string, size: 255
      add_if_not_exists :gender, :string, size: 20
      add_if_not_exists :dob, :date
      add_if_not_exists :ref_corporate_id, :bigint
      add_if_not_exists :ref_md_department_id, :bigint
      add_if_not_exists :department_name, :string, size: 50
      add_if_not_exists :location, :string, size: 100
      add_if_not_exists :onboarding_status_id, :integer, default: 0
      add_if_not_exists :reporting, :string, size: 100
      add_if_not_exists :ref_reporting_id, :bigint
      add_if_not_exists :designation, :string, size: 100
      add_if_not_exists :assign_corporate, :string, size: 100
      add_if_not_exists :test_user, :integer, default: 0
      add_if_not_exists :corporate_username, :string, size: 100
    end

    create_if_not_exists index(:users, [:ref_corporate_id])
    create_if_not_exists index(:users, [:ref_reporting_id])
    create_if_not_exists unique_index(:users, [:corporate_username])
  end
end
