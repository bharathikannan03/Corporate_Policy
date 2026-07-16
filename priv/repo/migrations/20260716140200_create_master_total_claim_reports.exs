defmodule CorporatePolicy.Repo.Migrations.CreateMasterTotalClaimReports do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_total_claim_reports) do
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing)
      add :employee_code, :string
      add :employee_name, :string
      add :patient_name, :string
      add :relationship, :string
      add :claim_type, :string
      add :tpa_claim_no, :string
      add :date_of_hospitalization, :string
      add :date_of_discharge, :string
      add :hospital_name, :string
      add :amount_claimed, :float
      add :amount_sanctioned, :float
      add :claim_status, :string
      add :patient_gender, :string
      add :hospital_state, :string
      add :network_status, :string
      add :treatment_type, :string
      add :level_of_care, :string
      add :cause, :string
      add :city, :string
      add :age, :integer
      add :claim_file_submitted_dt, :string
      add :claim_settled_date, :string
      add :disease_category, :string
      add :claim_registered_date, :string
      add :intimation_method, :string
      add :sum_insured, :float
      add :tds_amount, :float
      add :deduction_amount, :float
      add :deduction_reason, :string
      add :deficiency_intimated_date, :string
      add :deficiency_submission_date, :string
      add :icd_code, :string
      add :claim_paid_amount, :float
      add :close_reasons, :string
      add :deficiency_reason, :text
      add :claim_sub_status, :string
      add :insurance_claim_no, :string
      add :status, :integer, default: 0
      
      add :created_by, :integer
      add :updated_by, :integer
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create_if_not_exists index(:master_total_claim_reports, [:ref_policy_id])
    create_if_not_exists index(:master_total_claim_reports, [:employee_code])
  end
end
