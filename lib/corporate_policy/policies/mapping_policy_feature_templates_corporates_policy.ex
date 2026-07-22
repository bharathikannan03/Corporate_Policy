defmodule CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:policy_feature_template_field_value_id, :id, autogenerate: true}
  schema "mapping_policy_feature_templates_corporates_policies" do
    field :ref_policy_feature_template_field_name, :string
    field :policy_feature_template_field_value, :string
    field :ref_template_id, :integer
    field :ref_coporate_id, :integer
    field :ref_policy_feature_template_field_id, :integer
    field :ref_policy_feature_template_field_type_id, :integer
    field :policy_feature_template_field_visibility_role_ids, :string
    field :status, :integer, default: 0
    field :deleted_at, :naive_datetime
    field :ref_policyidentifier_id, :integer

    belongs_to :policy_ref, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
  end

  @doc false
  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [
      :ref_policy_feature_template_field_name,
      :policy_feature_template_field_value,
      :ref_template_id,
      :ref_coporate_id,
      :ref_policy_id,
      :ref_policy_feature_template_field_id,
      :ref_policy_feature_template_field_type_id,
      :policy_feature_template_field_visibility_role_ids,
      :status,
      :deleted_at,
      :ref_policyidentifier_id,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :ref_policy_feature_template_field_name,
      :policy_feature_template_field_value,
      :ref_template_id,
      :ref_coporate_id,
      :ref_policy_id,
      :ref_policy_feature_template_field_id,
      :ref_policy_feature_template_field_type_id
    ])
  end
end
