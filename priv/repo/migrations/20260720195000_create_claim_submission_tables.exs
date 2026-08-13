defmodule CorporatePolicy.Repo.Migrations.CreateClaimSubmissionTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_claim_submission) do
      add :ref_corporate_id, :integer, null: false
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing), null: false
      add :portal_id, :integer, null: false
      add :claim_number, :string, null: false
      add :intimation_number, :string
      add :corporate_name, :string
      add :policy_number, :string
      add :policy_type, :string
      add :insurer_name, :string
      add :tpa_name, :string
      add :employee_code, :string, null: false
      add :employee_name, :string
      add :patient_name, :string, null: false
      add :relationship, :string
      add :estimated_amount, :decimal, precision: 12, scale: 2, null: false
      add :claim_reason, :text, null: false
      add :claim_type, :string, null: false
      add :hospital_name, :string, null: false
      add :hospital_address, :text, null: false
      add :hospitalization_date, :date, null: false
      add :discharge_date, :date, null: false
      add :city, :string, null: false
      add :state, :string, null: false
      add :pincode, :string, null: false
      add :treatment_details, :text
      add :remarks, :text
      add :claim_status, :string, default: "Draft", null: false
      add :submitted_at, :utc_datetime_usec
      add :submitted_by, :bigint
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:master_claim_submission, [:claim_number])
    create_if_not_exists unique_index(:master_claim_submission, [:intimation_number])
    create_if_not_exists index(:master_claim_submission, [:ref_policy_id])
    create_if_not_exists index(:master_claim_submission, [:ref_corporate_id])
    create_if_not_exists index(:master_claim_submission, [:portal_id])
    create_if_not_exists index(:master_claim_submission, [:employee_code])
    create_if_not_exists index(:master_claim_submission, [:claim_status])

    create_if_not_exists table(:master_claim_submission_documents) do
      add :claim_id, references(:master_claim_submission, on_delete: :delete_all), null: false
      add :policy_id, :integer, null: false
      add :document_name, :string, null: false
      add :original_file_name, :string, null: false
      add :file_path, :string, null: false
      add :mime_type, :string
      add :file_size, :integer
      add :status, :integer, default: 1
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_claim_submission_documents, [:claim_id])
    create_if_not_exists index(:master_claim_submission_documents, [:policy_id])

    create_if_not_exists table(:trp_claim_submission_logs) do
      add :claim_id, references(:master_claim_submission, on_delete: :delete_all), null: false
      add :policy_id, :integer, null: false
      add :portal_id, :integer, null: false
      add :submitted_by, :bigint
      add :action, :string, null: false
      add :remarks, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create_if_not_exists index(:trp_claim_submission_logs, [:claim_id])
    create_if_not_exists index(:trp_claim_submission_logs, [:policy_id])
    create_if_not_exists index(:trp_claim_submission_logs, [:portal_id])
  end
end
