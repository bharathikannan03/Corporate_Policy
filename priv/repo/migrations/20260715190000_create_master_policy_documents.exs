defmodule CorporatePolicy.Repo.Migrations.CreateMasterPolicyDocuments do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_policy_documents) do
      add :document_type_id, :integer
      add :document_type, :string, size: 100
      add :document_name_id, :integer
      add :document_name, :string, size: 100
      add :note, :text
      add :file_path, :string, size: 255, null: false
      add :policy_id, :integer, null: false
      add :status, :integer, default: 0
      add :original_file_name, :string, size: 200

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_policy_documents, [:policy_id])
  end
end
