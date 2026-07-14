defmodule CorporatePolicy.Repo.Migrations.AddLobReferenceToPolicyTypes do
  use Ecto.Migration

  def change do
    alter table(:md_policy_types) do
      add :ref_md_line_of_businesses_id, :bigint, null: true
    end

    create index(:md_policy_types, [:ref_md_line_of_businesses_id])
  end
end
