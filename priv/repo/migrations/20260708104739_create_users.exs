defmodule CorporatePolicy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email_address, :string, null: false
      add :password, :string, null: false
      add :status, :integer, default: 0, null: false
      add :remember_token, :string
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:users, :email_address)
  end
end
