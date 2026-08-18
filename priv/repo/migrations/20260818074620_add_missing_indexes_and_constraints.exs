defmodule CorporatePolicy.Repo.Migrations.AddMissingIndexesAndConstraints do
  use Ecto.Migration

  def up do
    # 1. Data Cleanup phase (to prevent invalid FK errors during migration)
    execute "UPDATE master_policy_escalation_matrices SET user_id = NULL WHERE user_id NOT IN (SELECT id FROM users);"

    execute "DELETE FROM trn_mapping_corporateid_corporatecontactsids WHERE corporatecontacts_id NOT IN (SELECT id FROM users);"

    execute "UPDATE users SET department_id = NULL WHERE department_id NOT IN (SELECT role_id FROM md_visibility_role_id_feature_tmps);"

    # Allow nulls for location columns in master_corporates (replacing default 0 with nil)
    alter table(:master_corporates) do
      modify :ref_master_city_city_id, :bigint, null: true, default: nil
      modify :ref_master_pincode_pincode_id, :bigint, null: true, default: nil
      modify :ref_master_state_state_id, :bigint, null: true, default: nil
    end

    # Allow nulls for department columns in users (replacing default 0 with nil)
    alter table(:users) do
      modify :department_id, :bigint, null: true, default: nil
      modify :ref_md_department_id, :bigint, null: true, default: nil
    end

    execute "UPDATE master_corporates SET ref_master_city_city_id = NULL WHERE ref_master_city_city_id = 0;"

    execute "UPDATE master_corporates SET ref_master_pincode_pincode_id = NULL WHERE ref_master_pincode_pincode_id = 0;"

    execute "UPDATE master_corporates SET ref_master_state_state_id = NULL WHERE ref_master_state_state_id = 0;"

    execute "UPDATE users SET department_id = NULL WHERE department_id = 0;"
    execute "UPDATE users SET ref_md_department_id = NULL WHERE ref_md_department_id = 0;"

    # Add UNIQUE constraint to md_visibility_role_id_feature_tmps(role_id) using raw SQL
    execute """
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conrelid = 'md_visibility_role_id_feature_tmps'::regclass 
          AND conname = 'md_visibility_role_id_feature_tmps_role_id_unique'
      ) THEN
        ALTER TABLE md_visibility_role_id_feature_tmps 
        ADD CONSTRAINT md_visibility_role_id_feature_tmps_role_id_unique UNIQUE (role_id);
      END IF;
    END $$;
    """

    # 2. Add Foreign Key Constraints (References) for columns in missing_other_relation_ids
    alter table(:mapping_policy_completions) do
      modify :completed_by, references(:users, on_delete: :nilify_all)
    end

    alter table(:mapping_policy_feature_templates_corporates_policies) do
      modify :ref_coporate_id,
             references(:master_corporates,
               column: :corporate_id,
               type: :bigint,
               on_delete: :delete_all
             )

      modify :ref_policy_id,
             references(:master_add_policies, type: :bigint, on_delete: :delete_all)

      modify :ref_template_id,
             references(:master_policy_feature_templates,
               column: :template_id,
               type: :bigint,
               on_delete: :delete_all
             )
    end

    alter table(:master_add_policies) do
      modify :ref_corporate_id,
             references(:master_corporates,
               column: :corporate_id,
               type: :bigint,
               on_delete: :delete_all
             )

      modify :ref_md_line_of_businesses_id,
             references(:md_line_of_businesses, type: :bigint, on_delete: :nothing)

      modify :ref_md_policy_types_id,
             references(:md_policy_types, type: :bigint, on_delete: :nothing)

      modify :ref_md_sum_insured_types_id,
             references(:md_sum_insured_types, type: :bigint, on_delete: :nothing)

      modify :ref_select_insurer_id,
             references(:md_insurer_lists, type: :bigint, on_delete: :nothing)

      modify :user_id, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :ref_fy_year_id, references(:md_financial_years, type: :bigint, on_delete: :nothing)

      modify :ref_md_family_definitions_id,
             references(:md_family_definitions, type: :bigint, on_delete: :nothing)
    end

    alter table(:master_cashless_hospitals) do
      modify :ref_corporate_id,
             references(:master_corporates,
               column: :corporate_id,
               type: :bigint,
               on_delete: :delete_all
             )
    end

    alter table(:master_cd_accounts) do
      modify :ref_insurer_id, references(:md_insurer_lists, type: :bigint, on_delete: :nothing)
    end

    alter table(:master_cd_statement_data_uploads) do
      modify :corporate_id,
             references(:master_corporates,
               column: :corporate_id,
               type: :bigint,
               on_delete: :delete_all
             )
    end

    alter table(:master_claim_submission) do
      modify :submitted_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:master_corporates) do
      modify :ref_master_city_city_id,
             references(:md_cities, column: :city_id, type: :bigint, on_delete: :nothing)

      modify :ref_master_corporate_logos_id,
             references(:master_logos, column: :logo_id, type: :bigint, on_delete: :nilify_all)

      modify :ref_master_pincode_pincode_id,
             references(:md_pincodes, column: :pincode_id, type: :bigint, on_delete: :nothing)

      modify :ref_master_state_state_id,
             references(:md_states, column: :state_id, type: :bigint, on_delete: :nothing)
    end

    alter table(:master_ecards_data_uploads) do
      modify :created_by, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :updated_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:master_endorsement_data_uploads) do
      modify :created_by, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :updated_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:master_inception_data_uploads) do
      modify :created_by, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :updated_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:master_policy_corporate_buffer_transactions) do
      modify :ref_policy_id,
             references(:master_add_policies, type: :bigint, on_delete: :delete_all)

      modify :ref_buffer_amount_id,
             references(:master_policy_corporate_buffer_amounts,
               type: :bigint,
               on_delete: :delete_all
             )
    end

    alter table(:master_policy_documents) do
      modify :document_name_id, references(:md_document_names, type: :bigint, on_delete: :nothing)
      modify :document_type_id, references(:md_document_types, type: :bigint, on_delete: :nothing)
    end

    alter table(:master_policy_escalation_matrices) do
      modify :escalation_level_id,
             references(:md_escalation_matrices, type: :bigint, on_delete: :nothing)

      modify :user_id,
             references(:master_escalation_matrices, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:master_total_claim_reports) do
      modify :created_by, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :updated_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:trn_mapping_corporateid_corporatecontactsids) do
      modify :corporate_id,
             references(:master_corporates,
               column: :corporate_id,
               type: :bigint,
               on_delete: :delete_all
             )

      modify :corporatecontacts_id, references(:users, type: :bigint, on_delete: :delete_all)
    end

    alter table(:trn_mapping_live_employees) do
      modify :created_by, references(:users, type: :bigint, on_delete: :nilify_all)
      modify :updated_by, references(:users, type: :bigint, on_delete: :nilify_all)
    end

    alter table(:users) do
      modify :department_id,
             references(:md_visibility_role_id_feature_tmps,
               column: :role_id,
               type: :bigint,
               on_delete: :nilify_all
             )

      modify :ref_md_department_id,
             references(:md_visibility_role_id_feature_tmps,
               column: :role_id,
               type: :bigint,
               on_delete: :nilify_all
             )
    end

    # 3. Add Unique Constraints (Indexes)
    create_if_not_exists unique_index(:trn_mapping_corporateid_corporatecontactsids, [
                           :corporate_id,
                           :corporatecontacts_id
                         ])

    create_if_not_exists unique_index(:trn_mapping_pincode_city_states, [
                           :pincode_id,
                           :city_id,
                           :state_id
                         ])

    # 4. Add Database Indexes on Candidate Foreign Keys
    create_if_not_exists index(:mapping_policy_completions, [:completed_by])

    # Custom short index names for mapping_policy_feature_templates_corporates_policies to prevent 63-char collisions
    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:created_by], name: :mpftcp_created_by_idx)

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:updated_by], name: :mpftcp_updated_by_idx)

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_coporate_id], name: :mpftcp_ref_coporate_id_idx)

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_policy_feature_template_field_id],
                           name: :mpftcp_ref_policy_field_idx
                         )

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_policy_feature_template_field_type_id],
                           name: :mpftcp_ref_policy_field_type_idx
                         )

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_policy_id], name: :mpftcp_ref_policy_id_idx)

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_policyidentifier_id], name: :mpftcp_ref_policy_ident_idx)

    create_if_not_exists index(
                           :mapping_policy_feature_templates_corporates_policies,
                           [:ref_template_id], name: :mpftcp_ref_template_id_idx)

    create_if_not_exists index(:master_add_policies, [:created_by])
    create_if_not_exists index(:master_add_policies, [:updated_by])
    create_if_not_exists index(:master_add_policies, [:user_id])
    create_if_not_exists index(:master_add_policies, [:ref_intimate_claim_visibilities_id])
    create_if_not_exists index(:master_add_policies, [:ref_md_claim_submission_visibilities_id])
    create_if_not_exists index(:master_add_policies, [:ref_md_family_definitions_id])
    create_if_not_exists index(:master_add_policies, [:ref_md_line_of_businesses_id])
    create_if_not_exists index(:master_add_policies, [:ref_md_policy_types_id])
    create_if_not_exists index(:master_add_policies, [:ref_md_sum_insured_types_id])
    create_if_not_exists index(:master_add_policies, [:ref_select_insurer_id])

    create_if_not_exists index(:master_cashless_hospitals, [:ref_corporate_id])

    create_if_not_exists index(:master_cd_accounts, [:created_by])
    create_if_not_exists index(:master_cd_accounts, [:updated_by])
    create_if_not_exists index(:master_cd_accounts, [:ref_insurer_id])

    create_if_not_exists index(:master_cd_statement_data_uploads, [:created_by])
    create_if_not_exists index(:master_cd_statement_data_uploads, [:updated_by])
    create_if_not_exists index(:master_cd_statement_data_uploads, [:corporate_id])

    create_if_not_exists index(:master_claim_submission, [:created_by])
    create_if_not_exists index(:master_claim_submission, [:updated_by])
    create_if_not_exists index(:master_claim_submission, [:submitted_by])

    create_if_not_exists index(:master_claim_submission_documents, [:created_by])
    create_if_not_exists index(:master_claim_submission_documents, [:updated_by])

    create_if_not_exists index(:master_corporates, [:ref_master_city_city_id])
    create_if_not_exists index(:master_corporates, [:ref_master_corporate_logos_id])
    create_if_not_exists index(:master_corporates, [:ref_master_pincode_pincode_id])
    create_if_not_exists index(:master_corporates, [:ref_master_state_state_id])

    create_if_not_exists index(:master_ecards_data_uploads, [:created_by])
    create_if_not_exists index(:master_ecards_data_uploads, [:updated_by])
    create_if_not_exists index(:master_ecards_data_uploads, [:ref_doc_id])

    create_if_not_exists index(:master_employee_logs, [:employee_id])

    create_if_not_exists index(:master_endorsement_data_uploads, [:created_by])
    create_if_not_exists index(:master_endorsement_data_uploads, [:updated_by])

    create_if_not_exists index(:master_inception_data_uploads, [:created_by])
    create_if_not_exists index(:master_inception_data_uploads, [:updated_by])

    create_if_not_exists index(:master_policy_cd_statements, [:created_by])
    create_if_not_exists index(:master_policy_cd_statements, [:updated_by])

    create_if_not_exists index(:master_policy_corporate_buffer_transactions, [
                           :ref_buffer_amount_id
                         ])

    create_if_not_exists index(:master_policy_data_uploads, [:created_by])
    create_if_not_exists index(:master_policy_data_uploads, [:updated_by])

    create_if_not_exists index(:master_policy_documents, [:created_by])
    create_if_not_exists index(:master_policy_documents, [:updated_by])
    create_if_not_exists index(:master_policy_documents, [:document_name_id])
    create_if_not_exists index(:master_policy_documents, [:document_type_id])

    create_if_not_exists index(:master_policy_escalation_matrices, [:created_by])
    create_if_not_exists index(:master_policy_escalation_matrices, [:updated_by])
    create_if_not_exists index(:master_policy_escalation_matrices, [:escalation_level_id])
    create_if_not_exists index(:master_policy_escalation_matrices, [:user_id])

    create_if_not_exists index(:master_policy_feature_template_fields, [:created_by])
    create_if_not_exists index(:master_policy_feature_template_fields, [:updated_by])
    create_if_not_exists index(:master_policy_feature_template_fields, [:ref_fieldgrouping_id])
    create_if_not_exists index(:master_policy_feature_template_fields, [:ref_policyidentifier_id])

    create_if_not_exists index(:master_policy_feature_templates, [:ref_policy_id])

    create_if_not_exists index(:master_sum_insureds, [:created_by])
    create_if_not_exists index(:master_sum_insureds, [:updated_by])
    create_if_not_exists index(:master_sum_insureds, [:feature_identifier_id])

    create_if_not_exists index(:master_total_claim_reports, [:created_by])
    create_if_not_exists index(:master_total_claim_reports, [:updated_by])

    create_if_not_exists index(:md_document_names, [:created_by])
    create_if_not_exists index(:md_document_names, [:updated_by])

    create_if_not_exists index(:md_document_types, [:created_by])
    create_if_not_exists index(:md_document_types, [:updated_by])

    create_if_not_exists index(:md_escalation_matrices, [:created_by])
    create_if_not_exists index(:md_escalation_matrices, [:updated_by])

    create_if_not_exists index(:md_visibility_role_id_feature_tmps, [
                           :ref_feature_template_field_id
                         ])

    create_if_not_exists index(:trn_endorsement_deletion_logs, [:created_by])
    create_if_not_exists index(:trn_endorsement_deletion_logs, [:updated_by])

    create_if_not_exists index(:trn_mapping_corporateid_corporatecontactsids, [:corporate_id])

    create_if_not_exists index(:trn_mapping_corporateid_corporatecontactsids, [
                           :corporatecontacts_id
                         ])

    create_if_not_exists index(:trn_mapping_live_employees, [:created_by])
    create_if_not_exists index(:trn_mapping_live_employees, [:updated_by])

    create_if_not_exists index(:trp_claim_submission_logs, [:submitted_by])
    create_if_not_exists index(:trp_claim_submission_logs, [:user_id])

    create_if_not_exists index(:users, [:department_id])
    create_if_not_exists index(:users, [:onboarding_status_id])
    create_if_not_exists index(:users, [:ref_md_department_id])
  end

  def down do
    drop_if_exists index(:users, [:ref_md_department_id])
    drop_if_exists index(:users, [:onboarding_status_id])
    drop_if_exists index(:users, [:department_id])
    drop_if_exists index(:trp_claim_submission_logs, [:user_id])
    drop_if_exists index(:trp_claim_submission_logs, [:submitted_by])
    drop_if_exists index(:trn_mapping_live_employees, [:updated_by])
    drop_if_exists index(:trn_mapping_live_employees, [:created_by])
    drop_if_exists index(:trn_mapping_corporateid_corporatecontactsids, [:corporatecontacts_id])
    drop_if_exists index(:trn_mapping_corporateid_corporatecontactsids, [:corporate_id])
    drop_if_exists index(:trn_endorsement_deletion_logs, [:updated_by])
    drop_if_exists index(:trn_endorsement_deletion_logs, [:created_by])
    drop_if_exists index(:md_visibility_role_id_feature_tmps, [:ref_feature_template_field_id])
    drop_if_exists index(:md_escalation_matrices, [:updated_by])
    drop_if_exists index(:md_escalation_matrices, [:created_by])
    drop_if_exists index(:md_document_types, [:updated_by])
    drop_if_exists index(:md_document_types, [:created_by])
    drop_if_exists index(:md_document_names, [:updated_by])
    drop_if_exists index(:md_document_names, [:created_by])
    drop_if_exists index(:master_total_claim_reports, [:updated_by])
    drop_if_exists index(:master_total_claim_reports, [:created_by])
    drop_if_exists index(:master_sum_insureds, [:feature_identifier_id])
    drop_if_exists index(:master_sum_insureds, [:updated_by])
    drop_if_exists index(:master_sum_insureds, [:created_by])
    drop_if_exists index(:master_policy_feature_templates, [:ref_policy_id])
    drop_if_exists index(:master_policy_feature_template_fields, [:ref_policyidentifier_id])
    drop_if_exists index(:master_policy_feature_template_fields, [:ref_fieldgrouping_id])
    drop_if_exists index(:master_policy_feature_template_fields, [:updated_by])
    drop_if_exists index(:master_policy_feature_template_fields, [:created_by])
    drop_if_exists index(:master_policy_escalation_matrices, [:user_id])
    drop_if_exists index(:master_policy_escalation_matrices, [:escalation_level_id])
    drop_if_exists index(:master_policy_escalation_matrices, [:updated_by])
    drop_if_exists index(:master_policy_escalation_matrices, [:created_by])
    drop_if_exists index(:master_policy_documents, [:document_type_id])
    drop_if_exists index(:master_policy_documents, [:document_name_id])
    drop_if_exists index(:master_policy_documents, [:updated_by])
    drop_if_exists index(:master_policy_documents, [:created_by])
    drop_if_exists index(:master_policy_data_uploads, [:updated_by])
    drop_if_exists index(:master_policy_data_uploads, [:created_by])
    drop_if_exists index(:master_policy_corporate_buffer_transactions, [:ref_buffer_amount_id])
    drop_if_exists index(:master_inception_data_uploads, [:updated_by])
    drop_if_exists index(:master_inception_data_uploads, [:created_by])
    drop_if_exists index(:master_endorsement_data_uploads, [:updated_by])
    drop_if_exists index(:master_endorsement_data_uploads, [:created_by])
    drop_if_exists index(:master_employee_logs, [:employee_id])
    drop_if_exists index(:master_ecards_data_uploads, [:ref_doc_id])
    drop_if_exists index(:master_ecards_data_uploads, [:updated_by])
    drop_if_exists index(:master_ecards_data_uploads, [:created_by])
    drop_if_exists index(:master_corporates, [:ref_master_state_state_id])
    drop_if_exists index(:master_corporates, [:ref_master_pincode_pincode_id])
    drop_if_exists index(:master_corporates, [:ref_master_corporate_logos_id])
    drop_if_exists index(:master_corporates, [:ref_master_city_city_id])
    drop_if_exists index(:master_claim_submission_documents, [:updated_by])
    drop_if_exists index(:master_claim_submission_documents, [:created_by])
    drop_if_exists index(:master_claim_submission, [:submitted_by])
    drop_if_exists index(:master_claim_submission, [:updated_by])
    drop_if_exists index(:master_claim_submission, [:created_by])
    drop_if_exists index(:master_cd_statement_data_uploads, [:corporate_id])
    drop_if_exists index(:master_cd_statement_data_uploads, [:updated_by])
    drop_if_exists index(:master_cd_statement_data_uploads, [:created_by])
    drop_if_exists index(:master_cd_accounts, [:ref_insurer_id])
    drop_if_exists index(:master_cd_accounts, [:updated_by])
    drop_if_exists index(:master_cd_accounts, [:created_by])
    drop_if_exists index(:master_cashless_hospitals, [:ref_corporate_id])
    drop_if_exists index(:master_add_policies, [:ref_select_insurer_id])
    drop_if_exists index(:master_add_policies, [:ref_md_sum_insured_types_id])
    drop_if_exists index(:master_add_policies, [:ref_md_policy_types_id])
    drop_if_exists index(:master_add_policies, [:ref_md_line_of_businesses_id])
    drop_if_exists index(:master_add_policies, [:ref_md_family_definitions_id])
    drop_if_exists index(:master_add_policies, [:ref_md_claim_submission_visibilities_id])
    drop_if_exists index(:master_add_policies, [:ref_intimate_claim_visibilities_id])
    drop_if_exists index(:master_add_policies, [:user_id])
    drop_if_exists index(:master_add_policies, [:updated_by])
    drop_if_exists index(:master_add_policies, [:created_by])

    drop_if_exists index(:mapping_policy_feature_templates_corporates_policies, [:created_by],
                     name: :mpftcp_created_by_idx
                   )

    drop_if_exists index(:mapping_policy_feature_templates_corporates_policies, [:updated_by],
                     name: :mpftcp_updated_by_idx
                   )

    drop_if_exists index(
                     :mapping_policy_feature_templates_corporates_policies,
                     [:ref_coporate_id], name: :mpftcp_ref_coporate_id_idx)

    drop_if_exists index(
                     :mapping_policy_feature_templates_corporates_policies,
                     [:ref_policy_feature_template_field_id], name: :mpftcp_ref_policy_field_idx)

    drop_if_exists index(
                     :mapping_policy_feature_templates_corporates_policies,
                     [:ref_policy_feature_template_field_type_id],
                     name: :mpftcp_ref_policy_field_type_idx
                   )

    drop_if_exists index(:mapping_policy_feature_templates_corporates_policies, [:ref_policy_id],
                     name: :mpftcp_ref_policy_id_idx
                   )

    drop_if_exists index(
                     :mapping_policy_feature_templates_corporates_policies,
                     [:ref_policyidentifier_id], name: :mpftcp_ref_policy_ident_idx)

    drop_if_exists index(
                     :mapping_policy_feature_templates_corporates_policies,
                     [:ref_template_id], name: :mpftcp_ref_template_id_idx)

    drop_if_exists index(:mapping_policy_completions, [:completed_by])

    drop_if_exists unique_index(:trn_mapping_pincode_city_states, [
                     :pincode_id,
                     :city_id,
                     :state_id
                   ])

    drop_if_exists unique_index(:trn_mapping_corporateid_corporatecontactsids, [
                     :corporate_id,
                     :corporatecontacts_id
                   ])

    # Remove unique constraint on md_visibility_role_id_feature_tmps(role_id)
    execute "ALTER TABLE md_visibility_role_id_feature_tmps DROP CONSTRAINT IF EXISTS md_visibility_role_id_feature_tmps_role_id_unique;"
  end
end
