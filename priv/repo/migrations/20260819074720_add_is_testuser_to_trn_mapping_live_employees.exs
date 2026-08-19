defmodule CorporatePolicy.Repo.Migrations.AddIsTestuserToTrnMappingLiveEmployees do
  use Ecto.Migration

  def change do
    alter table(:trn_mapping_live_employees) do
      add :is_testuser, :integer, default: 0, null: false
    end
  end
end
