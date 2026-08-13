defmodule CorporatePolicy.Repo.Migrations.CreateMasterCdstatementUploadErrors do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_cdstatement_upload_errors) do
      add :ref_doc_id, :bigint, null: false
      add :row, :integer, null: false
      add :column_name, :string, size: 100, null: false
      add :errors, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_cdstatement_upload_errors, [:ref_doc_id])
  end
end
