defmodule CorporatePolicy.Repo.Migrations.CreateTrnMappingCorporateidCorporatecontactsids do
  use Ecto.Migration

  def change do
    create table(:trn_mapping_corporateid_corporatecontactsids) do
      add :corporate_id, :integer, null: false
      add :corporatecontacts_id, :integer, null: false
      add :status, :integer, null: false, default: 1
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
