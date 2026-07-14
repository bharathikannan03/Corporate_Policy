defmodule CorporatePolicy.Policies.Insurer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "md_insurer_lists" do
    field :name, :string
    field :status, :integer, default: 0

    belongs_to :line_of_business, CorporatePolicy.Policies.LineOfBusiness,
      foreign_key: :ref_md_line_of_businesses_id

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_select_insurer_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(insurer, attrs) do
    insurer
    |> cast(attrs, [:name, :status, :ref_md_line_of_businesses_id])
    |> validate_required([:name])
    |> validate_inclusion(:status, [0, 1])
  end
end
