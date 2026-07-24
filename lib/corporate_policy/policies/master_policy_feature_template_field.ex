defmodule CorporatePolicy.Policies.MasterPolicyFeatureTemplateField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:template_field_id, :id, autogenerate: true}
  schema "master_policy_feature_template_fields" do
    field :policy_feature_template_field_name, :string
    field :policy_feature_template_field_placeholder, :string
    field :ref_master_temp_field_Type, :integer
    field :ref_template_id, :integer
    field :status, :integer, default: 0
    field :is_mandatory, :integer, default: 0
    field :ref_policyidentifier_id, :integer
    field :field_description, :string
    field :ref_fieldgrouping_id, :string
    field :deleted_at, :naive_datetime

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps(inserted_at: :created_at, updated_at: :updated_at)
  end

  @doc false
  def changeset(master_policy_feature_template_field, attrs) do
    master_policy_feature_template_field
    |> cast(attrs, [
      :policy_feature_template_field_name,
      :policy_feature_template_field_placeholder,
      :ref_master_temp_field_Type,
      :ref_template_id,
      :status,
      :is_mandatory,
      :ref_policyidentifier_id,
      :field_description,
      :ref_fieldgrouping_id,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :policy_feature_template_field_name,
      :ref_master_temp_field_Type,
      :ref_template_id
    ])
  end
end
