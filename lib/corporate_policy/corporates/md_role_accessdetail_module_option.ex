defmodule CorporatePolicy.Corporates.MdRoleAccessdetailModuleOption do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_role_accessdetail_module_options" do
    field :module_option_id, :integer
    field :module_option_name, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:module_option_id, :module_option_name, :status, :deleted_at])
    |> validate_required([:module_option_id, :module_option_name])
  end
end
