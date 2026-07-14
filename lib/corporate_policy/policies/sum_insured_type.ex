defmodule CorporatePolicy.Policies.SumInsuredType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_sum_insurer_types" do
    field :name, :string
    field :display_id, :integer
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_md_sum_insured_types_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(sit, attrs) do
    sit
    |> cast(attrs, [:name, :display_id, :status])
    |> validate_required([:name, :display_id])
    |> validate_inclusion(:status, [0, 1])
  end
end
