defmodule CorporatePolicy.Repo.Migrations.CreateMasterPolicyCdStatements do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_policy_cd_statements) do
      add :corporate_name, :string, size: 255, null: false
      add :corporate_id, :integer, null: false
      add :cd_number, :string, size: 255, null: false
      add :cd_account_id, :integer, null: false
      add :data_upload_file, :string, size: 255
      add :policy_id, :integer
      add :is_dataupload, :boolean, default: true

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_policy_cd_statements, [:policy_id])
    create_if_not_exists index(:master_policy_cd_statements, [:corporate_id])
    create_if_not_exists index(:master_policy_cd_statements, [:cd_account_id])
  end
end
