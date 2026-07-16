defmodule CorporatePolicy.Corporates.Pincode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:pincode_id, :id, autogenerate: true}
  schema "md_pincodes" do
    field :pincode, :integer
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(pincode, attrs) do
    pincode
    |> cast(attrs, [:pincode, :status, :deleted_at])
    |> validate_required([:pincode])
  end
end
