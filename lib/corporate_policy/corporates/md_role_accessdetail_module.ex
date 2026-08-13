defmodule CorporatePolicy.Corporates.MdRoleAccessdetailModule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_role_accessdetail_modules" do
    field :module_id, :integer
    field :module_name, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [:module_id, :module_name, :status, :deleted_at])
    |> validate_required([:module_id, :module_name])
  end
end
