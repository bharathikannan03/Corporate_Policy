defmodule CorporatePolicy.Policies.CashlessHospital do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_cashless_hospitals" do
    field :ref_insurer_id, :integer
    field :insurer_name, :string
    field :ref_tpa_id, :integer
    field :tpa_name, :string
    field :ch_upload_data, :string
    field :ref_corporate_id, :integer
    field :status, :integer, default: 0
    field :is_dataupload, :integer, default: 0
    field :original_file_name, :string
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(cashless_hospital, attrs) do
    cashless_hospital
    |> cast(attrs, [
      :ref_insurer_id,
      :insurer_name,
      :ref_tpa_id,
      :tpa_name,
      :ch_upload_data,
      :ref_corporate_id,
      :status,
      :is_dataupload,
      :original_file_name,
      :deleted_at
    ])
    |> validate_required([:ref_insurer_id, :insurer_name, :ch_upload_data])
  end
end
