defmodule CorporatePolicy.Repo.Migrations.AddRefFeatureTemplateFieldIdToMdVisibilityRoleFeatureTmps do
  use Ecto.Migration

  def up do
    has_column =
      repo().query!(
        "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'md_visibility_role_id_feature_tmps' AND column_name = 'ref_feature_template_field_id')"
      ).rows
      |> List.first()
      |> List.first()

    if has_column do
      alter table(:md_visibility_role_id_feature_tmps) do
        modify :ref_feature_template_field_id,
               references(
                 :master_policy_feature_template_fields,
                 column: :template_field_id,
                 type: :bigint,
                 on_delete: :delete_all
               ),
               null: true
      end
    else
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
    end

    create_if_not_exists(
      index(
        :md_visibility_role_id_feature_tmps,
        [:ref_feature_template_field_id],
        name: :md_visibility_role_id_feature_tmps_template_field_idx
      )
    )
  end

  def down do
    drop_if_exists(
      index(
        :md_visibility_role_id_feature_tmps,
        [:ref_feature_template_field_id],
        name: :md_visibility_role_id_feature_tmps_template_field_idx
      )
    )

    alter table(:md_visibility_role_id_feature_tmps) do
      remove :ref_feature_template_field_id
    end
  end
end
