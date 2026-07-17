defmodule CorporatePolicy.Repo.Migrations.CreateMappingPolicyFeatureTemplatesCorporatesPolicies do
  use Ecto.Migration

  def change do
    create table(:mapping_policy_feature_templates_corporates_policies, primary_key: false) do
      add :policy_feature_template_field_value_id, :bigserial, primary_key: true
      add :ref_policy_feature_template_field_name, :string
      add :policy_feature_template_field_value, :text
      add :ref_template_id, :integer
      add :ref_coporate_id, :integer
      add :ref_policy_id, :integer
      add :ref_policy_feature_template_field_id, :integer
      add :ref_policy_feature_template_field_type_id, :integer
      add :policy_feature_template_field_visibility_role_ids, :string
      add :status, :integer, default: 0
      add :deleted_at, :naive_datetime
      add :ref_policyidentifier_id, :integer

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
