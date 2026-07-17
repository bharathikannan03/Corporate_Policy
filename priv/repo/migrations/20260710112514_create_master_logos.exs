defmodule CorporatePolicy.Repo.Migrations.CreateMasterLogos do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_logos, primary_key: false) do
      add :logo_id, :bigserial, primary_key: true
      add :logo, :string, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end
  end
end
