defmodule CorporatePolicy.Corporates.MdVisibilityRoleFeature do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_visibility_role_id_feature_tmps" do
    field :role_id, :integer, read_after_writes: true
    field :role, :string
    field :is_visible, :integer, default: 2
    field :status, :integer, default: 0
    field :ref_feature_template_field_id, :integer
    field :deleted_at, :utc_datetime_usec

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :role_id,
      :role,
      :is_visible,
      :status,
      :ref_feature_template_field_id,
      :deleted_at
    ])
    |> validate_required([:role_id, :role])
  end
end
