defmodule CorporatePolicy.Corporates.TrnMappingRoleidRoleaccessdetail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trn_mapping_roleid_roleaccessdetails" do
    field :role_id, :integer
    field :module_id, :integer
    field :module_option_id, :integer
    field :selection_status, :boolean, default: false
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [
      :role_id,
      :module_id,
      :module_option_id,
      :selection_status,
      :status,
      :deleted_at
    ])
    |> validate_required([:role_id, :module_id, :module_option_id])
  end
end
