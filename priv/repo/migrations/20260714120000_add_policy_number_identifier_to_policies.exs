defmodule CorporatePolicy.Repo.Migrations.AddPolicyNumberIdentifierToPolicies do
  use Ecto.Migration

  def change do
    alter table(:master_add_policies) do
      add :policy_number_identifier, :string, size: 100
    end

    create_if_not_exists index(:master_add_policies, [:policy_number_identifier])
  end
end
