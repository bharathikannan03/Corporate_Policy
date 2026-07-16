defmodule CorporatePolicy.Policies.Tpa do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_policy_tpas" do
    field :name, :string
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_tpa_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(tpa, attrs) do
    tpa
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> validate_inclusion(:status, [0, 1])
  end
end
