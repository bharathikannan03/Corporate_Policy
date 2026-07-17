defmodule CorporatePolicy.Repo.Migrations.AddRefCorporateIdAndDepartmentIdToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add_if_not_exists :department_id, :integer
      # Drop corporate_id if it exists to clean it up
      remove_if_exists :corporate_id, :integer
    end
  end

  def down do
    alter table(:users) do
      remove_if_exists :department_id, :integer
    end
  end
end
