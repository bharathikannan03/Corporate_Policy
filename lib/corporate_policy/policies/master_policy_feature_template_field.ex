defmodule CorporatePolicy.Policies.MasterPolicyFeatureTemplateField do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_policy_feature_template_fields" do
    field :name, :string
    field :placeholder, :string
    field :field_type_id, :integer
    field :template_id, :integer
    field :status, :integer, default: 0
    field :is_mandatory, :boolean, default: false
    field :policy_identifier_id, :integer
    field :description, :string
    field :field_grouping_id, :string
    field :deleted_at, :naive_datetime

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
  end

  @doc false
  def changeset(master_policy_feature_template_field, attrs) do
    master_policy_feature_template_field
    |> cast(attrs, [
      :name,
      :placeholder,
      :field_type_id,
      :template_id,
      :status,
      :is_mandatory,
      :policy_identifier_id,
      :description,
      :field_grouping_id,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([:name, :field_type_id, :template_id, :status, :is_mandatory])
  end
end
