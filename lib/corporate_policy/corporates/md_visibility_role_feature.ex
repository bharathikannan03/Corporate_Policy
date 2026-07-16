defmodule CorporatePolicy.Corporates.MdVisibilityRoleFeature do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:role_id, :id, autogenerate: true}
  schema "md_visibility_role_id_feature_tmps" do
    field :role, :string
    field :is_visible, :integer, default: 2
    field :status, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(is_visible)a
  @optional_fields ~w(role status)a

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
