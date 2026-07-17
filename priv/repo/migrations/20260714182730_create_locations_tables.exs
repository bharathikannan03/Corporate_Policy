defmodule CorporatePolicy.Repo.Migrations.CreateLocationsTables do
  use Ecto.Migration

  def change do
    create table(:md_cities, primary_key: false) do
      add :city_id, :bigserial, primary_key: true
      add :city, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_states, primary_key: false) do
      add :state_id, :bigserial, primary_key: true
      add :state, :string, size: 255, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create table(:md_pincodes, primary_key: false) do
      add :pincode_id, :bigserial, primary_key: true
      add :pincode, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create table(:trn_mapping_pincode_city_states) do
      add :pincode_id, :integer, null: false
      add :city_id, :integer, null: false
      add :state_id, :integer, null: false
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:trn_mapping_pincode_city_states, [:pincode_id])
    create index(:trn_mapping_pincode_city_states, [:city_id])
    create index(:trn_mapping_pincode_city_states, [:state_id])
  end
end
