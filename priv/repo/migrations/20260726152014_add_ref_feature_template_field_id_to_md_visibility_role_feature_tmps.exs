defmodule CorporatePolicy.Repo.Migrations.AddRefFeatureTemplateFieldIdToMdVisibilityRoleFeatureTmps do
  use Ecto.Migration

  def change do
    alter table(:md_visibility_role_id_feature_tmps) do
      add :ref_feature_template_field_id,
          references(
            :master_policy_feature_template_fields,
            column: :template_field_id,
            type: :bigint,
            on_delete: :delete_all
          ),
          null: true
    end

    create_if_not_exists(
      index(
        :md_visibility_role_id_feature_tmps,
        [:ref_feature_template_field_id],
        name: :md_visibility_role_id_feature_tmps_template_field_idx
      )
    )
  end
end
