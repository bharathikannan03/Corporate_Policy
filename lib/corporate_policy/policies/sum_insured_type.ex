defmodule CorporatePolicy.Policies.SumInsuredType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_sum_insured_types" do
    field :name, :string
    field :display_id, :integer
    field :status, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(sum_insured_type, attrs) do
    sum_insured_type
    |> cast(attrs, [:name, :display_id, :status])
    |> validate_required([:name])
  end
end
