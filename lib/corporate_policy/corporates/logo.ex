defmodule CorporatePolicy.Corporates.Logo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:logo_id, :id, autogenerate: true}
  schema "master_logos" do
    field :logo, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(logo, attrs) do
    logo
    |> cast(attrs, [:logo, :status])
    |> validate_required([:logo])
  end
end
