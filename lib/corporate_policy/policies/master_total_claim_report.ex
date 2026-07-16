defmodule CorporatePolicy.Policies.MasterTotalClaimReport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_total_claim_reports" do
    field :employee_code, :string
    field :employee_name, :string
    field :patient_name, :string
    field :relationship, :string
    field :claim_type, :string
    field :tpa_claim_no, :string
    field :date_of_hospitalization, :string
    field :date_of_discharge, :string
    field :hospital_name, :string
    field :amount_claimed, :float
    field :amount_sanctioned, :float
    field :claim_status, :string
    field :patient_gender, :string
    field :hospital_state, :string
    field :network_status, :string
    field :treatment_type, :string
    field :level_of_care, :string
    field :cause, :string
    field :city, :string
    field :age, :integer
    field :claim_file_submitted_dt, :string
    field :claim_settled_date, :string
    field :disease_category, :string
    field :claim_registered_date, :string
    field :intimation_method, :string
    field :sum_insured, :float
    field :tds_amount, :float
    field :deduction_amount, :float
    field :deduction_reason, :string
    field :deficiency_intimated_date, :string
    field :deficiency_submission_date, :string
    field :icd_code, :string
    field :claim_paid_amount, :float
    field :close_reasons, :string
    field :deficiency_reason, :string
    field :claim_sub_status, :string
    field :insurance_claim_no, :string
    field :status, :integer, default: 0
    
    field :created_by, :integer
    field :updated_by, :integer
    field :deleted_at, :utc_datetime

    belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id

    timestamps()
  end

  @doc false
  def changeset(master_total_claim_report, attrs) do
    master_total_claim_report
    |> cast(attrs, [
      :employee_code, :employee_name, :patient_name, :relationship, :claim_type,
      :tpa_claim_no, :date_of_hospitalization, :date_of_discharge, :hospital_name,
      :amount_claimed, :amount_sanctioned, :claim_status, :patient_gender,
      :hospital_state, :network_status, :treatment_type, :level_of_care, :cause,
      :city, :age, :claim_file_submitted_dt, :claim_settled_date, :disease_category,
      :claim_registered_date, :intimation_method, :sum_insured, :tds_amount,
      :deduction_amount, :deduction_reason, :deficiency_intimated_date,
      :deficiency_submission_date, :icd_code, :claim_paid_amount, :close_reasons,
      :deficiency_reason, :claim_sub_status, :insurance_claim_no, :status,
      :created_by, :updated_by, :deleted_at, :ref_policy_id
    ])
    |> validate_required([:ref_policy_id, :employee_code])
  end
end
