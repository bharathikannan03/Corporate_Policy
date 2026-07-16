defmodule CorporatePolicy.Repo.Migrations.CreateMasterPolicyEscalationMatrices do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_policy_escalation_matrices) do
      add :escalation_level_id, :integer
      add :level, :string, size: 100
      add :user_id, :integer
      add :user_fullname, :string, size: 100
      add :policy_id, :integer
      add :status, :integer, default: 0

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_policy_escalation_matrices, [:policy_id])
  end
end
