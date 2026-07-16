defmodule CorporatePolicy.Repo.Migrations.AddRoleColumnToVisibilityRoleTmps do
  use Ecto.Migration

  def change do
    alter table(:md_visibility_role_id_feature_tmps) do
      add_if_not_exists :role, :string, size: 255
    end
  end
end
