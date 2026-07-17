defmodule CorporatePolicy.Repo.Migrations.CreateMasterEcardsDataUploads do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_ecards_data_uploads) do
      add :ref_doc_id, :integer
      add :employee_code, :string
      add :ecard_data_originalname, :string
      add :ecards_data_url, :string, null: false
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing), null: false
      add :data_upload, :integer, default: 0
      add :status, :integer, default: 0
      add :created_by, :integer
      add :updated_by, :integer
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create_if_not_exists index(:master_ecards_data_uploads, [:ref_policy_id])
    create_if_not_exists index(:master_ecards_data_uploads, [:employee_code])
  end
end
