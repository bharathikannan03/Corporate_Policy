defmodule CorporatePolicy.Repo.Migrations.CreateMdDocumentNames do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_document_names) do
      add :document_type_id, references(:md_document_types, on_delete: :nothing)
      add :document_name, :string, size: 100
      add :status, :integer, default: 0

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:md_document_names, [:document_type_id])
  end
end
