defmodule CorporatePolicy.Policies.LineOfBusiness do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_line_of_businesses" do
    field :line_of_business_value, :string
    field :display_id, :integer
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy,
      foreign_key: :ref_md_line_of_businesses_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(lob, attrs) do
    lob
    |> cast(attrs, [:line_of_business_value, :display_id, :status])
    |> validate_required([:line_of_business_value, :display_id])
    |> validate_inclusion(:status, [0, 1])
    |> unique_constraint(:line_of_business_value)
  end
end
