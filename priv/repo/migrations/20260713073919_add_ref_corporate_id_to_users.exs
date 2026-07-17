defmodule CorporatePolicy.Repo.Migrations.AddRefCorporateIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists :ref_corporate_id, :integer
    end
  end
end
