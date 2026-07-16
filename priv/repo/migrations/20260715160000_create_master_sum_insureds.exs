defmodule CorporatePolicy.Repo.Migrations.CreateMasterSumInsureds do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_sum_insureds) do
      add :sum_insured, :integer, null: false
      add :policy_feature_identifier, :string, size: 100, null: false
      add :template_id, :integer, null: false
      add :policy_id, :integer, null: false
      add :feature_identifier_id, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_sum_insureds, [:policy_id])
    create_if_not_exists index(:master_sum_insureds, [:template_id])
  end
end
