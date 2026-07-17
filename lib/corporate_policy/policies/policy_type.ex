defmodule CorporatePolicy.Policies.PolicyType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_policy_types" do
    field :policy_type_value, :string
    field :display_id, :integer
    field :status, :integer, default: 0

    belongs_to :line_of_business, CorporatePolicy.Policies.LineOfBusiness,
      foreign_key: :ref_md_line_of_businesses_id

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_md_policy_types_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(pt, attrs) do
    pt
    |> cast(attrs, [:policy_type_value, :display_id, :status, :ref_md_line_of_businesses_id])
    |> validate_required([:policy_type_value, :display_id])
    |> validate_inclusion(:status, [0, 1])
    |> unique_constraint(:policy_type_value)
  end
end
