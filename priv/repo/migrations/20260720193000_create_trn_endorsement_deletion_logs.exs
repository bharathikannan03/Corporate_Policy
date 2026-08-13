defmodule CorporatePolicy.Repo.Migrations.CreateTrnEndorsementDeletionLogs do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:trn_endorsement_deletion_logs) do
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing), null: false

      add :ref_corporate_id,
          references(:master_corporates, column: :corporate_id, on_delete: :nothing)

      add :employee_code, :string
      add :employee_name, :string
      add :relationship, :string
      add :endorsement_number, :string
      add :endorsement_date, :string
      add :endorsement_type, :string
      add :deletion_category, :string, default: "Dependant Deletion"
      add :deleted_at, :utc_datetime

      add :created_by, :integer
      add :updated_by, :integer

      timestamps()
    end

    create_if_not_exists index(:trn_endorsement_deletion_logs, [:ref_policy_id])
    create_if_not_exists index(:trn_endorsement_deletion_logs, [:ref_corporate_id])
    create_if_not_exists index(:trn_endorsement_deletion_logs, [:employee_code])
  end
end
