defmodule CorporatePolicy.Repo.Migrations.DropAndRecreateMasterPolicyFeatureTemplateFields do
  use Ecto.Migration

  def up do
    drop_if_exists table(:master_policy_feature_template_fields)

    create table(:master_policy_feature_template_fields, primary_key: false) do
      add :template_field_id, :bigserial, primary_key: true
      add :policy_feature_template_field_name, :string, size: 100, null: false
      add :policy_feature_template_field_placeholder, :string, size: 255
      add :ref_master_temp_field_Type, :integer, null: false
      add :ref_template_id, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :naive_datetime
      add :is_mandatory, :integer, default: 0, null: false
      add :ref_policyidentifier_id, :integer
      add :field_description, :text, null: false
      add :ref_fieldgrouping_id, :string, size: 255
      add :created_by, :bigint
      add :updated_by, :bigint

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :naive_datetime)
    end

    create index(:master_policy_feature_template_fields, [:ref_template_id])
  end

  def down do
    drop_if_exists table(:master_policy_feature_template_fields)
  end
end
