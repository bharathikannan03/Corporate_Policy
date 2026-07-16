defmodule CorporatePolicy.Repo.Migrations.CreateMasterPolicyDataUploads do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_policy_data_uploads) do
      add :data_type, :string, size: 100, null: false
      add :remark, :string, size: 100
      # modernizing policy_data_upload
      add :file_path, :string, size: 255, null: false
      add :policy_id, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :is_dataupload, :boolean, default: false, null: false
      add :original_file_name, :string, size: 200

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_policy_data_uploads, [:policy_id])
  end
end
