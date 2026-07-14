defmodule CorporatePolicy.Corporates.City do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:city_id, :id, autogenerate: true}
  schema "md_cities" do
    field :city, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(city, attrs) do
    city
    |> cast(attrs, [:city, :status, :deleted_at])
    |> validate_required([:city])
  end
end
