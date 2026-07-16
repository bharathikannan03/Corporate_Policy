defmodule CorporatePolicy.Repo.Migrations.CreateMdPolicyTypes do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_policy_types, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :policy_type_value, :string, size: 100, null: false
      add :display_id, :integer, null: false
      add :status, :integer, default: 0, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists unique_index(:md_policy_types, [:policy_type_value])
  end
end
