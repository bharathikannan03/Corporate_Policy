defmodule CorporatePolicy.Repo.Migrations.AddStatusToMasterCorporates do
  use Ecto.Migration

  def change do
    alter table(:master_corporates) do
      add :status, :integer, default: 0, null: false
    end

    execute(
      "UPDATE master_corporates SET status = CASE WHEN corporate_status = 1 THEN 1 ELSE 0 END"
    )
  end
end
