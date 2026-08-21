# scratch_list_tables.exs
defmodule ScratchDbInspector do
  def run do
    # Ensure application is started
    Application.ensure_all_started(:corporate_policy)

    drops = [
      {"mapping_policy_completions", "mapping_policy_completions_completed_by_fkey"},
      {"mapping_policy_feature_templates_corporates_policies",
       "mapping_policy_feature_templates_corporates_policies_ref_copora"},
      {"mapping_policy_feature_templates_corporates_policies",
       "mapping_policy_feature_templates_corporates_policies_ref_policy"},
      {"mapping_policy_feature_templates_corporates_policies",
       "mapping_policy_feature_templates_corporates_policies_ref_templa"},
      {"master_add_policies", "master_add_policies_ref_corporate_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_md_line_of_businesses_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_md_policy_types_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_md_sum_insured_types_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_select_insurer_id_fkey"},
      {"master_add_policies", "master_add_policies_user_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_fy_year_id_fkey"},
      {"master_add_policies", "master_add_policies_ref_md_family_definitions_id_fkey"},
      {"master_cashless_hospitals", "master_cashless_hospitals_ref_corporate_id_fkey"},
      {"master_cd_accounts", "master_cd_accounts_ref_insurer_id_fkey"},
      {"master_cd_statement_data_uploads", "master_cd_statement_data_uploads_corporate_id_fkey"},
      {"master_claim_submission", "master_claim_submission_submitted_by_fkey"},
      {"master_corporates", "master_corporates_ref_master_city_city_id_fkey"},
      {"master_corporates", "master_corporates_ref_master_corporate_logos_id_fkey"},
      {"master_corporates", "master_corporates_ref_master_pincode_pincode_id_fkey"},
      {"master_corporates", "master_corporates_ref_master_state_state_id_fkey"},
      {"master_ecards_data_uploads", "master_ecards_data_uploads_created_by_fkey"},
      {"master_ecards_data_uploads", "master_ecards_data_uploads_updated_by_fkey"},
      {"master_endorsement_data_uploads", "master_endorsement_data_uploads_created_by_fkey"},
      {"master_endorsement_data_uploads", "master_endorsement_data_uploads_updated_by_fkey"},
      {"master_inception_data_uploads", "master_inception_data_uploads_created_by_fkey"},
      {"master_inception_data_uploads", "master_inception_data_uploads_updated_by_fkey"},
      {"master_policy_corporate_buffer_transactions",
       "master_policy_corporate_buffer_transactions_ref_policy_id_fkey"},
      {"master_policy_corporate_buffer_transactions",
       "master_policy_corporate_buffer_transactions_ref_buffer_amount_i"},
      {"master_policy_documents", "master_policy_documents_document_name_id_fkey"},
      {"master_policy_documents", "master_policy_documents_document_type_id_fkey"},
      {"master_policy_escalation_matrices",
       "master_policy_escalation_matrices_escalation_level_id_fkey"},
      {"master_policy_escalation_matrices", "master_policy_escalation_matrices_user_id_fkey"},
      {"master_total_claim_reports", "master_total_claim_reports_created_by_fkey"},
      {"master_total_claim_reports", "master_total_claim_reports_updated_by_fkey"},
      {"trn_mapping_corporateid_corporatecontactsids",
       "trn_mapping_corporateid_corporatecontactsids_corporate_id_fkey"},
      {"trn_mapping_corporateid_corporatecontactsids",
       "trn_mapping_corporateid_corporatecontactsids_corporatecontacts_"},
      {"trn_mapping_live_employees", "trn_mapping_live_employees_created_by_fkey"},
      {"trn_mapping_live_employees", "trn_mapping_live_employees_updated_by_fkey"},
      {"users", "users_department_id_fkey"},
      {"users", "users_ref_md_department_id_fkey"}
    ]

    Enum.each(drops, fn {table, constraint} ->
      query = "ALTER TABLE \"#{table}\" DROP CONSTRAINT IF EXISTS \"#{constraint}\";"
      Ecto.Adapters.SQL.query!(CorporatePolicy.Repo, query)
    end)

    IO.puts("Successfully dropped all constraints.")
  end
end

ScratchDbInspector.run()
