defmodule CorporatePolicy.Policies.IntimateClaimVisibility do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_intimate_claim_visibilities" do
    field :name, :string
    field :display_id, :integer
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy,
      foreign_key: :ref_intimate_claim_visibilities_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(icv, attrs) do
    icv
    |> cast(attrs, [:name, :display_id, :status])
    |> validate_required([:name, :display_id])
    |> validate_inclusion(:status, [0, 1])
  end
end
