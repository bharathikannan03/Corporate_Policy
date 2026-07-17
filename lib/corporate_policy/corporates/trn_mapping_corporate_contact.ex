defmodule CorporatePolicy.Corporates.TrnMappingCorporateContact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trn_mapping_corporateid_corporatecontactsids" do
    field :corporate_id, :integer
    field :corporatecontacts_id, :integer
    field :status, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [:corporate_id, :corporatecontacts_id, :status])
    |> validate_required([:corporate_id, :corporatecontacts_id])
  end
end
