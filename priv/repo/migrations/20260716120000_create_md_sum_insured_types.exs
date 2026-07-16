defmodule CorporatePolicy.Repo.Migrations.CreateMdSumInsuredTypes do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_sum_insured_types) do
      add :name, :string, null: false
      add :display_id, :integer
      add :status, :integer, default: 1

      timestamps()
    end
  end
end
