defmodule CorporatePolicy.Corporates.MdVisibilityRoleFeature do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:role_id, :id, autogenerate: true}
  schema "md_visibility_role_id_feature_tmps" do
    belongs_to :feature_template_field,
               CorporatePolicy.Policies.MasterPolicyFeatureTemplateField,
               foreign_key: :ref_feature_template_field_id,
               references: :template_field_id

    field :role, :string
    field :is_visible, :integer, default: 2
    timestamps()
  end

  # @required_fields ~w(is_visible)a
  # @optional_fields ~w(role)a

  @required_fields ~w(is_visible)a
  @optional_fields ~w(role ref_feature_template_field_id)a
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
