defmodule CorporatePolicy.Repo.Migrations.CreateMdVisibilityRoleIdFeatureTmps do
  use Ecto.Migration

  def change do
    create table(:md_visibility_role_id_feature_tmps, primary_key: false) do
      add :role_id, :bigserial, primary_key: true
      add :role, :string, size: 255, null: true
      add :is_visible, :integer, null: false, default: 2
      add :status, :integer, null: false, default: 1
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(:md_visibility_role_id_feature_tmps, [:role_id])
    create index(:md_visibility_role_id_feature_tmps, [:is_visible])

    create unique_index(
             :md_visibility_role_id_feature_tmps,
             [:role_id, :is_visible],
             name: :unique_roles
           )
  end
end
