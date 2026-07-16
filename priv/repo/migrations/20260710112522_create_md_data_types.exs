defmodule CorporatePolicy.Repo.Migrations.CreateMdDataTypes do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_data_types) do
      add :name, :string, size: 100, null: false
      add :status, :integer, default: 1, null: false

      timestamps()
    end

    create_if_not_exists unique_index(:md_data_types, [:name])
  end
end
