defmodule CorporatePolicy.Repo.Migrations.CreateMasterPolicyFeatureTemplateFields do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_policy_feature_template_fields) do
      add :name, :string, size: 100, null: false
      add :placeholder, :string, size: 255
      add :field_type_id, :integer, null: false
      add :template_id, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :is_mandatory, :boolean, default: false, null: false
      add :policy_identifier_id, :integer
      add :description, :text
      add :field_grouping_id, :string
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end

    create_if_not_exists index(:master_policy_feature_template_fields, [:template_id])
  end
end
