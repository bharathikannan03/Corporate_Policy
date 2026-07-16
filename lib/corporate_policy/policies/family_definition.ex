defmodule CorporatePolicy.Policies.FamilyDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_family_definitions" do
    field :name, :string
    field :display_id, :integer
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy,
      foreign_key: :ref_md_family_definitions_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(fd, attrs) do
    fd
    |> cast(attrs, [:name, :display_id, :status])
    |> validate_required([:name, :display_id])
    |> validate_inclusion(:status, [0, 1])
  end
end
