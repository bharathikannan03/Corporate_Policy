defmodule CorporatePolicy.Policies.CashlessHospitalUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_cashless_hospital_uploads" do
    field :hospital_name, :string
    field :hospital_address, :string
    field :location, :string
    field :landmark, :string
    field :city, :string
    field :state, :string
    field :pincode, :integer
    field :email, :string
    field :stdcode, :string
    field :phone, :string
    field :insurer_name, :string
    field :ref_insurer_id, :integer
    field :tpa_name, :string
    field :ref_tpa_id, :string
    field :status, :string, default: "0"
    field :latitude, :decimal
    field :longitude, :decimal
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(cashless_hospital_upload, attrs) do
    cashless_hospital_upload
    |> cast(attrs, [
      :hospital_name,
      :hospital_address,
      :location,
      :landmark,
      :city,
      :state,
      :pincode,
      :email,
      :stdcode,
      :phone,
      :insurer_name,
      :ref_insurer_id,
      :tpa_name,
      :ref_tpa_id,
      :status,
      :latitude,
      :longitude,
      :deleted_at
    ])
    |> validate_required([:hospital_name, :ref_insurer_id])
  end
end
