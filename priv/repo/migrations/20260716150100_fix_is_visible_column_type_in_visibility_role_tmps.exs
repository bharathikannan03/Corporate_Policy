defmodule CorporatePolicy.Repo.Migrations.FixIsVisibleColumnTypeInVisibilityRoleTmps do
  use Ecto.Migration

  def up do
    # Must drop default first before changing type
    execute "ALTER TABLE md_visibility_role_id_feature_tmps ALTER COLUMN is_visible DROP DEFAULT"

    execute """
    ALTER TABLE md_visibility_role_id_feature_tmps
    ALTER COLUMN is_visible TYPE integer
    USING CASE WHEN is_visible THEN 1 ELSE 0 END
    """

    execute "ALTER TABLE md_visibility_role_id_feature_tmps ALTER COLUMN is_visible SET DEFAULT 2"
  end

  def down do
    execute "ALTER TABLE md_visibility_role_id_feature_tmps ALTER COLUMN is_visible DROP DEFAULT"

    execute """
    ALTER TABLE md_visibility_role_id_feature_tmps
    ALTER COLUMN is_visible TYPE boolean
    USING CASE WHEN is_visible = 1 THEN true ELSE false END
    """

    execute "ALTER TABLE md_visibility_role_id_feature_tmps ALTER COLUMN is_visible SET DEFAULT true"
  end
end
