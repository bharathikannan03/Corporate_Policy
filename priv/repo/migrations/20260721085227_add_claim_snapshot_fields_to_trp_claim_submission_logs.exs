defmodule CorporatePolicy.Repo.Migrations.AddClaimSnapshotFieldsToTrpClaimSubmissionLogs do
  use Ecto.Migration

  def change do
    alter table(:trp_claim_submission_logs) do
      add :claim_number, :string
      add :policy_number, :string
      add :corporate_name, :string
      add :policy_type, :string
      add :insurer_name, :string
      add :employee_code, :string
      add :patient_name, :string
      add :relationship, :string
      add :claim_status, :string
      add :estimated_amount, :decimal, precision: 12, scale: 2
      add :hospital_name, :string
      add :city, :string
      add :state, :string
    end
  end
end
