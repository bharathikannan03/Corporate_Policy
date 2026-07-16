defmodule CorporatePolicy.Repo.Migrations.AddLobReferenceToInsurers do
  use Ecto.Migration

  def change do
    alter table(:md_insurer_lists) do
      add :ref_md_line_of_businesses_id, :bigint, null: true
    end

    create_if_not_exists index(:md_insurer_lists, [:ref_md_line_of_businesses_id])
  end
end
