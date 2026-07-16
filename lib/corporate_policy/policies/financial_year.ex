defmodule CorporatePolicy.Policies.FinancialYear do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "md_financial_years" do
    field :year_name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_fy_year_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(fy, attrs) do
    fy
    |> cast(attrs, [:year_name, :start_date, :end_date, :status])
    |> validate_required([:year_name, :start_date, :end_date])
    |> validate_inclusion(:status, [0, 1])
    |> unique_constraint(:year_name)
  end

  def is_default?(fy), do: fy.status == 1

  def get_default(repo \\ CorporatePolicy.Repo) do
    from(fy in __MODULE__,
      where: fy.status == 1,
      order_by: [desc: fy.year_name],
      limit: 1
    )
    |> repo.one()
  end

  def get_by_year(year, repo \\ CorporatePolicy.Repo) do
    from(fy in __MODULE__,
      where: fy.year_name == ^to_string(year),
      limit: 1
    )
    |> repo.one()
  end
end
