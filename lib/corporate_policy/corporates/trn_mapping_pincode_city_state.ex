defmodule CorporatePolicy.Corporates.TrnMappingPincodeCityState do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trn_mapping_pincode_city_states" do
    field :pincode_id, :integer
    field :city_id, :integer
    field :state_id, :integer
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [:pincode_id, :city_id, :state_id, :status, :deleted_at])
    |> validate_required([:pincode_id, :city_id, :state_id])
  end
end
