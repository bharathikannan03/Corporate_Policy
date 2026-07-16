defmodule CorporatePolicy.Repo.Migrations.AddInsurerListsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_insurer_lists, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :name, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:md_insurer_lists, [:name])
  end
end
