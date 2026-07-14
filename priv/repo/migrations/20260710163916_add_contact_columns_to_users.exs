defmodule CorporatePolicy.Repo.Migrations.AddContactColumnsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists :full_name, :string, null: true
      add_if_not_exists :mobile_no, :string, null: true
      add_if_not_exists :corporate_username, :string, null: true
      add_if_not_exists :department_name, :string, null: true
      add_if_not_exists :location, :string, null: true
    end
  end
end
