defmodule CorporatePolicy.Corporates.MdVisibilityRoleFeature do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:role_id, :id, autogenerate: true}
  schema "md_visibility_role_id_feature_tmps" do
    field :role, :string
    field :is_visible, :integer, default: 2
    timestamps()
  end

  @required_fields ~w(is_visible)a
  @optional_fields ~w(role)a

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
