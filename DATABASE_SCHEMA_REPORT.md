# Database Schema Report

Generated from Laravel migration files in `database/migrations`, applied in filename timestamp order. This report documents the final schema state declared by the migrations, not intermediate migration states.

## Table of Contents

- [Executive Summary](#executive-summary)
- [Tables](#tables)
  - [`users`](#users)
  - [`password_reset_tokens`](#password-reset-tokens)
  - [`sessions`](#sessions)
  - [`cache`](#cache)
  - [`cache_locks`](#cache-locks)
  - [`jobs`](#jobs)
  - [`job_batches`](#job-batches)
  - [`failed_jobs`](#failed-jobs)
  - [`md_user_roles`](#md-user-roles)
  - [`master_cities`](#master-cities)
  - [`master_states`](#master-states)
  - [`master_pincodes`](#master-pincodes)
  - [`trn_mapping_pincode_city_states`](#trn-mapping-pincode-city-states)
  - [`master_corporates`](#master-corporates)
  - [`master_branches`](#master-branches)
  - [`master_logos`](#master-logos)
  - [`oauth_auth_codes`](#oauth-auth-codes)
  - [`oauth_access_tokens`](#oauth-access-tokens)
  - [`oauth_refresh_tokens`](#oauth-refresh-tokens)
  - [`oauth_clients`](#oauth-clients)
  - [`oauth_personal_access_clients`](#oauth-personal-access-clients)
  - [`mapping_policy_feature_templates_corporates_policies`](#mapping-policy-feature-templates-corporates-policies)
  - [`master_policy_feature_template_fields`](#master-policy-feature-template-fields)
  - [`master_policy_feature_templates`](#master-policy-feature-templates)
  - [`md_temp_field_types`](#md-temp-field-types)
  - [`md_field_type_ids`](#md-field-type-ids)
  - [`md_line_of_businesses`](#md-line-of-businesses)
  - [`md_policy_types`](#md-policy-types)
  - [`md_family_definitions`](#md-family-definitions)
  - [`md_intimate_claim_visibilities`](#md-intimate-claim-visibilities)
  - [`trn_mapping_line_of_business_policy_types`](#trn-mapping-line-of-business-policy-types)
  - [`md_sum_insurer_types`](#md-sum-insurer-types)
  - [`master_add_policies`](#master-add-policies)
  - [`master_sum_insureds`](#master-sum-insureds)
  - [`master_policy_data_uploads`](#master-policy-data-uploads)
  - [`master_policy_escalation_matrices`](#master-policy-escalation-matrices)
  - [`md_escalation_matrices`](#md-escalation-matrices)
  - [`master_policy_documents`](#master-policy-documents)
  - [`md_document_types`](#md-document-types)
  - [`md_document_names`](#md-document-names)
  - [`master_policy_cd_statements`](#master-policy-cd-statements)
  - [`master_cd_accounts`](#master-cd-accounts)
  - [`master_policy_corporate_buffer_transactions`](#master-policy-corporate-buffer-transactions)
  - [`master_policy_corporate_buffer_amounts`](#master-policy-corporate-buffer-amounts)
  - [`trn_mapping_corporateid_corporatecontactsids`](#trn-mapping-corporateid-corporatecontactsids)
  - [`md_insurer_lists`](#md-insurer-lists)
  - [`md_policy_data_types`](#md-policy-data-types)
  - [`md_policy_tpas`](#md-policy-tpas)
  - [`mapping_policy_completions`](#mapping-policy-completions)
  - [`md_policy_sections`](#md-policy-sections)
  - [`md_visibility_role_id_feature_tmps`](#md-visibility-role-id-feature-tmps)
  - [`logs`](#logs)
  - [`md_role_accessdetails`](#md-role-accessdetails)
  - [`trn_mapping_roleid_roleaccessdetails`](#trn-mapping-roleid-roleaccessdetails)
  - [`master_cashless_hospitals`](#master-cashless-hospitals)
  - [`md_sample_documents`](#md-sample-documents)
  - [`md_claim_types`](#md-claim-types)
  - [`master_intimateclaims`](#master-intimateclaims)
  - [`master_nonlife_claimintimations`](#master-nonlife-claimintimations)
  - [`master_nonlife_documentuploads`](#master-nonlife-documentuploads)
  - [`master_nonlife_trackclaims`](#master-nonlife-trackclaims)
  - [`master_nonlife_claimsettlements`](#master-nonlife-claimsettlements)
  - [`master_claimsubmissions`](#master-claimsubmissions)
  - [`master_claimsubmission_documents`](#master-claimsubmission-documents)
  - [`master_escalation_matrices`](#master-escalation-matrices)
  - [`master_cashless_hospital_uploads`](#master-cashless-hospital-uploads)
  - [`master_cd_statement_transactions`](#master-cd-statement-transactions)
  - [`master_inception_data_uploads`](#master-inception-data-uploads)
  - [`master_total_claim_reports`](#master-total-claim-reports)
  - [`master_cd_statement_data_uploads`](#master-cd-statement-data-uploads)
  - [`master_intimateclaim_documents`](#master-intimateclaim-documents)
  - [`md_enrollment_types`](#md-enrollment-types)
  - [`master_enrollment_uploads`](#master-enrollment-uploads)
  - [`master_cashlesshospital_upload_errors`](#master-cashlesshospital-upload-errors)
  - [`master_dataupload_endorsement_upload_errors`](#master-dataupload-endorsement-upload-errors)
  - [`master_endorsement_data_uploads`](#master-endorsement-data-uploads)
  - [`master_dynamic_templates`](#master-dynamic-templates)
  - [`master_welcome_mailers`](#master-welcome-mailers)
  - [`master_welcomemail_email_sendings`](#master-welcomemail-email-sendings)
  - [`master_endorsementcalculation_rackrates`](#master-endorsementcalculation-rackrates)
  - [`master_endorsementcalculation_rackrates_suminsureds`](#master-endorsementcalculation-rackrates-suminsureds)
  - [`master_rackrates_suminsured_values`](#master-rackrates-suminsured-values)
  - [`master_employee_logs`](#master-employee-logs)
  - [`policyfeature_identifiers`](#policyfeature-identifiers)
  - [`master_ecards_data_uploads`](#master-ecards-data-uploads)
  - [`master_ecards_data_upload_errors`](#master-ecards-data-upload-errors)
  - [`trn_mapping_corporate_employee_otps`](#trn-mapping-corporate-employee-otps)
  - [`master_notification_templates`](#master-notification-templates)
  - [`trn_mapping_notifications`](#trn-mapping-notifications)
  - [`md_financial_year_logics`](#md-financial-year-logics)
  - [`md_financial_years`](#md-financial-years)
  - [`log_master_endorsement_calculations_datauploads`](#log-master-endorsement-calculations-datauploads)
  - [`log_endorsement_calculations_dataupload_calculations`](#log-endorsement-calculations-dataupload-calculations)
  - [`temp_endorsement_calculations_import_data`](#temp-endorsement-calculations-import-data)
  - [`master_endorsement_calculations_details`](#master-endorsement-calculations-details)
  - [`md_dynamic_template_variables`](#md-dynamic-template-variables)
  - [`dynamic_template_email_categories`](#dynamic-template-email-categories)
  - [`master_online_enrollment_notes`](#master-online-enrollment-notes)
  - [`master_online_enrollment_validationforms`](#master-online-enrollment-validationforms)
  - [`master_online_enrollment_employeedetails`](#master-online-enrollment-employeedetails)
  - [`trn_mapping_emp_detail_suminsureds`](#trn-mapping-emp-detail-suminsureds)
  - [`master_online_enrollment_gmc_policies`](#master-online-enrollment-gmc-policies)
  - [`trn_mapping_gmc_policies_suminsureds`](#trn-mapping-gmc-policies-suminsureds)
  - [`master_online_enrollment_voluntary_parent_policies`](#master-online-enrollment-voluntary-parent-policies)
  - [`trn_mapping_voluntary_parent_policies_suminsureds`](#trn-mapping-voluntary-parent-policies-suminsureds)
  - [`master_online_enrollment_topup_policies`](#master-online-enrollment-topup-policies)
  - [`trn_mapping_topup_policies_suminsureds`](#trn-mapping-topup-policies-suminsureds)
  - [`master_online_enrollment_opd_policies`](#master-online-enrollment-opd-policies)
  - [`trn_mapping_opd_policies_suminsureds`](#trn-mapping-opd-policies-suminsureds)
  - [`master_online_enrollment_gpa_policies`](#master-online-enrollment-gpa-policies)
  - [`master_online_enrollment_gtl_policies`](#master-online-enrollment-gtl-policies)
  - [`add_column_to_master_online_enrollment_notes`](#add-column-to-master-online-enrollment-notes)
  - [`master_online_enrollment_escalation_matrices`](#master-online-enrollment-escalation-matrices)
  - [`master_online_enrollment_empportal_form_uploads`](#master-online-enrollment-empportal-form-uploads)
  - [`master_log_online_enrollment_empportal_form_upload_data_errors`](#master-log-online-enrollment-empportal-form-upload-data-errors)
  - [`master_online_enrollment_empportal_form_upload_data`](#master-online-enrollment-empportal-form-upload-data)
  - [`master_log_online_enrollment_emp_mailsendings`](#master-log-online-enrollment-emp-mailsendings)
  - [`master_log_online_enrollment_empportal_addition_changes`](#master-log-online-enrollment-empportal-addition-changes)
  - [`master_log_emp_upload_audits`](#master-log-emp-upload-audits)
  - [`md_policyfeature_groupings`](#md-policyfeature-groupings)
  - [`master_nominee_data_uploads`](#master-nominee-data-uploads)
  - [`master_corporate_edit_employee_uploads`](#master-corporate-edit-employee-uploads)
  - [`master_log_corporate_edit_employees`](#master-log-corporate-edit-employees)
  - [`master_corporate_edit_employees_upload_errors`](#master-corporate-edit-employees-upload-errors)
  - [`md_tp_vendors`](#md-tp-vendors)
  - [`trn_mapping_corporate_tp_vendors`](#trn-mapping-corporate-tp-vendors)
  - [`md_gst_percentages`](#md-gst-percentages)
  - [`telescope_entries`](#telescope-entries)
  - [`telescope_entries_tags`](#telescope-entries-tags)
  - [`telescope_monitoring`](#telescope-monitoring)
- [Views](#views)
- [Foreign Key Relationships](#foreign-key-relationships)
- [Indexes](#indexes)
- [Composite Keys and Indexes](#composite-keys-and-indexes)
- [Unique Constraints](#unique-constraints)
- [Design Observations and Recommendations](#design-observations-and-recommendations)

## Executive Summary

| Metric | Count |
| --- | --- |
| Migration files analyzed | 258 |
| Final tables reconstructed | 130 |
| Columns documented | 1463 |
| Database views detected | 10 |
| Declared foreign keys | 21 |
| Declared secondary indexes | 14 |
| Declared unique constraints | 2 |

Notes:
- Laravel helper columns are expanded: `timestamps()` is shown as `created_at` and `updated_at`; `softDeletes()` is shown as `deleted_at`; `rememberToken()` is shown as `remember_token`.
- `change()` migrations are merged into the affected column definition where the source can be inferred.
- Most application reference columns are plain integers rather than declared foreign keys. Those are listed under design observations as missing FK candidates.

## Tables

### `users`

Migration sources: `database/migrations/0001_01_01_000000_create_users_table.php`, `database/migrations/2024_10_19_124621_alter_mobile_no_column_in_users_table.php`, `database/migrations/2024_10_22_072957_add__corporate_username_to_users_table.php`, `database/migrations/2024_10_22_150900_remove_countrycode_from_table_users.php`, `database/migrations/2024_11_05_054458_add_column_employeecode_gender_dob_to_users_table.php`, `database/migrations/2024_11_05_072354_modify_column_corporate_username_nullable_in_users_table.php`, `database/migrations/2024_11_08_113317_add_column_users_table.php`, `database/migrations/2024_12_05_105019_alter_users_table_column_name.php`, `database/migrations/2024_12_09_142052_dropcolumn_ref_md_visibility_role_id_feature_temps_id.php`, `database/migrations/2025_01_27_123415_create_add_column_broker_user_table.php`, `database/migrations/2025_01_28_093207_modify_column_fullname_nullable.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| first_name | varchar | 255 | No |  |  |  |  |  |
| last_name | varchar | 255 | No |  |  |  |  |  |
| full_name | varchar | 255 | Yes |  |  |  |  |  |
| mobile_no | varchar | 255 | No |  |  |  |  |  |
| email_address | varchar | 255 | No |  |  |  |  |  |
| password | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| remember_token | varchar | 100 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| corporate_username | varchar | 100 | Yes |  |  |  |  |  |
|               | varchar | 20 | Yes |  |  |  |  |  |
| gender | varchar | 20 | Yes |  |  |  |  |  |
| dob | varchar | 20 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| ref_md_department_id | integer |  | Yes |  |  |  |  |  |
| department_name | varchar | 50 | Yes |  |  |  |  |  |
| location | varchar | 100 | Yes |  |  |  |  |  |
| onboarding_status_id | integer |  | Yes | 0 |  |  |  |  |
| reporting | varchar | 100 | Yes |  |  |  |  |  |
| ref_reporting_id | integer |  | Yes |  |  |  |  |  |
| designation | varchar | 100 | Yes |  |  |  |  |  |
| assign_corporate | varchar | 100 | Yes |  |  |  |  |  |
| test_user | integer |  | No | 0 |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `password_reset_tokens`

Migration sources: `database/migrations/0001_01_01_000000_create_users_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| email | varchar | 255 | No |  | Yes |  |  |  |
| token | varchar | 255 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `email`
Audit / soft delete columns: `created_at`

### `sessions`

Migration sources: `database/migrations/0001_01_01_000000_create_users_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 255 | No |  | Yes |  |  |  |
| user_id | unsignedBigInteger |  | Yes |  |  |  |  |  |
| ip_address | varchar | 45 | Yes |  |  |  |  |  |
| user_agent | text |  | Yes |  |  |  |  |  |
| payload | longText |  | No |  |  |  |  |  |
| last_activity | integer |  | No |  |  |  |  |  |

Primary key: `id`
Indexes: `sessions_user_id_index` (user_id); `sessions_last_activity_index` (last_activity)

### `cache`

Migration sources: `database/migrations/0001_01_01_000001_create_cache_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| key | varchar | 255 | No |  | Yes |  |  |  |
| value | mediumText |  | No |  |  |  |  |  |
| expiration | integer |  | No |  |  |  |  |  |

Primary key: `key`

### `cache_locks`

Migration sources: `database/migrations/0001_01_01_000001_create_cache_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| key | varchar | 255 | No |  | Yes |  |  |  |
| owner | varchar | 255 | No |  |  |  |  |  |
| expiration | integer |  | No |  |  |  |  |  |

Primary key: `key`

### `jobs`

Migration sources: `database/migrations/0001_01_01_000002_create_jobs_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| queue | varchar | 255 | No |  |  |  |  |  |
| payload | longText |  | No |  |  |  |  |  |
| attempts | unsignedTinyInteger |  | No |  |  |  |  |  |
| reserved_at | unsignedInteger |  | Yes |  |  |  |  |  |
| available_at | unsignedInteger |  | No |  |  |  |  |  |
| created_at | unsignedInteger |  | No |  |  |  |  |  |

Primary key: `id`
Indexes: `jobs_queue_index` (queue)
Audit / soft delete columns: `created_at`

### `job_batches`

Migration sources: `database/migrations/0001_01_01_000002_create_jobs_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 255 | No |  | Yes |  |  |  |
| name | varchar | 255 | No |  |  |  |  |  |
| total_jobs | integer |  | No |  |  |  |  |  |
| pending_jobs | integer |  | No |  |  |  |  |  |
| failed_jobs | integer |  | No |  |  |  |  |  |
| failed_job_ids | longText |  | No |  |  |  |  |  |
| options | mediumText |  | Yes |  |  |  |  |  |
| cancelled_at | integer |  | Yes |  |  |  |  |  |
| created_at | integer |  | No |  |  |  |  |  |
| finished_at | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`

### `failed_jobs`

Migration sources: `database/migrations/0001_01_01_000002_create_jobs_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| uuid | varchar | 255 | No |  |  |  |  |  |
| connection | text |  | No |  |  |  |  |  |
| queue | text |  | No |  |  |  |  |  |
| payload | longText |  | No |  |  |  |  |  |
| exception | longText |  | No |  |  |  |  |  |
| failed_at | timestamp |  | No |  |  |  |  |  |

Primary key: `id`
Unique constraints: `failed_jobs_uuid_unique` (uuid)

### `md_user_roles`

Migration sources: `database/migrations/2024_10_17_075243_md_user_roles_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| user_role_id | integer |  | No |  |  |  |  |  |
| user_role_information | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cities`

Migration sources: `database/migrations/2024_10_17_085326_master_cities_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| city_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| city | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `city_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_states`

Migration sources: `database/migrations/2024_10_17_085409_master_states_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| state_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| state | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `state_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_pincodes`

Migration sources: `database/migrations/2024_10_17_085450_master_pincodes_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| pincode_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| pincode | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `pincode_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_pincode_city_states`

Migration sources: `database/migrations/2024_10_17_090134_trn_mapping_pincode_city_states_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| pincode_id | integer |  | No |  |  |  |  |  |
| city_id | integer |  | No |  |  |  |  |  |
| state_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_corporates`

Migration sources: `database/migrations/2024_10_17_092802_master_corporates_table.php`, `database/migrations/2024_10_22_065706_add_pincode_city_state_to_master_corporates_table.php`, `database/migrations/2024_10_24_070754_add_column_helpline_to_master_corporates_table.php`, `database/migrations/2024_10_24_084649_modify_ref_master_corporate_logos_id_nullable_in_master_corporates.php`, `database/migrations/2024_10_25_152846_modify_master_corporates_nullable.php`, `database/migrations/2024_11_08_101420_modify_master_corporates_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| corporate_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_name | varchar | 255 | No |  |  |  |  |  |
| ref_master_corporate_logos_id | integer |  | Yes |  |  |  |  |  |
| coporate_contact_email | varchar | 255 | Yes |  |  |  |  |  |
| corporate_landline | varchar | 255 | Yes |  |  |  |  |  |
| ref_master_pincode_pincode_id | integer |  | No |  |  |  |  |  |
| ref_master_city_city_id | integer |  | No |  |  |  |  |  |
| ref_master_state_state_id | integer |  | No |  |  |  |  |  |
| corporate_address | varchar | 255 | No |  |  |  |  |  |
| corporate_group_code | varchar | 255 | Yes |  |  |  |  |  |
| industry_type | varchar | 255 | Yes |  |  |  |  |  |
| corporate_buffer_visibility | integer |  | No | 0 |  |  |  |  |
| corporate_status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| pincode | varchar | 10 | No |  |  |  |  |  |
| city | varchar | 25 | No |  |  |  |  |  |
| state | varchar | 25 | No |  |  |  |  |  |
| helpline_no | varchar | 255 | Yes |  |  |  |  |  |
| pan_number | varchar | 15 | Yes |  |  |  |  |  |
| branch_name | varchar | 255 | Yes |  |  |  |  |  |

Primary key: `corporate_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_branches`

Migration sources: `database/migrations/2024_10_17_094107_master_branches.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| branch_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| branch_name | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `branch_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_logos`

Migration sources: `database/migrations/2024_10_17_094518_master_logos_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| logo_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| logo | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `logo_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `oauth_auth_codes`

Migration sources: `database/migrations/2024_10_18_035816_create_oauth_auth_codes_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 100 | No |  | Yes |  |  |  |
| user_id | unsignedBigInteger |  | No |  |  |  |  |  |
| client_id | uuid |  | No |  |  |  |  |  |
| scopes | text |  | Yes |  |  |  |  |  |
| revoked | boolean |  | No |  |  |  |  |  |
| expires_at | dateTime |  | Yes |  |  |  |  |  |

Primary key: `id`
Indexes: `oauth_auth_codes_user_id_index` (user_id)

### `oauth_access_tokens`

Migration sources: `database/migrations/2024_10_18_035817_create_oauth_access_tokens_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 100 | No |  | Yes |  |  |  |
| user_id | unsignedBigInteger |  | Yes |  |  |  |  |  |
| client_id | uuid |  | No |  |  |  |  |  |
| name | varchar | 255 | Yes |  |  |  |  |  |
| scopes | text |  | Yes |  |  |  |  |  |
| revoked | boolean |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| expires_at | dateTime |  | Yes |  |  |  |  |  |

Primary key: `id`
Indexes: `oauth_access_tokens_user_id_index` (user_id)
Audit / soft delete columns: `created_at`, `updated_at`

### `oauth_refresh_tokens`

Migration sources: `database/migrations/2024_10_18_035818_create_oauth_refresh_tokens_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 100 | No |  | Yes |  |  |  |
| access_token_id | varchar | 100 | No |  |  |  |  |  |
| revoked | boolean |  | No |  |  |  |  |  |
| expires_at | dateTime |  | Yes |  |  |  |  |  |

Primary key: `id`
Indexes: `oauth_refresh_tokens_access_token_id_index` (access_token_id)

### `oauth_clients`

Migration sources: `database/migrations/2024_10_18_035819_create_oauth_clients_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | varchar | 255 | No |  |  |  |  |  |
| user_id | unsignedBigInteger |  | Yes |  |  |  |  |  |
| name | varchar | 255 | No |  |  |  |  |  |
| secret | varchar | 100 | Yes |  |  |  |  |  |
| provider | varchar | 255 | Yes |  |  |  |  |  |
| redirect | text |  | No |  |  |  |  |  |
| personal_access_client | boolean |  | No |  |  |  |  |  |
| password_client | boolean |  | No |  |  |  |  |  |
| revoked | boolean |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: none declared
Indexes: `oauth_clients_user_id_index` (user_id)
Audit / soft delete columns: `created_at`, `updated_at`

### `oauth_personal_access_clients`

Migration sources: `database/migrations/2024_10_18_035820_create_oauth_personal_access_clients_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| client_id | varchar | 255 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`

### `mapping_policy_feature_templates_corporates_policies`

Migration sources: `database/migrations/2024_10_23_073612_create_mapping_policy_feature_templates_corporates_policies_table.php`, `database/migrations/2024_10_28_042623_alter_column_in_mapping_policy_feature_templates_corporates_policies_table.php`, `database/migrations/2025_03_28_054401_create_add_column_to_mapping_policy_feature_templates_corporates_policies.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| policy_feature_template_field_value_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_feature_template_field_name | varchar | 100 | No |  |  |  |  |  |
| policy_feature_template_field_value | varchar | 100 | No |  |  |  |  |  |
| ref_template_id | integer |  | No |  |  |  |  |  |
| ref_coporate_id | integer |  | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| ref_policy_feature_template_field_id | integer |  | No |  |  |  |  |  |
| ref_policy_feature_template_field_type_id | integer |  | No |  |  |  |  |  |
| policy_feature_template_field_visibility_role_ids | varchar | 10 | No | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_policyidentifier_id | integer |  | Yes |  |  |  |  |  |

Primary key: `policy_feature_template_field_value_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_feature_template_fields`

Migration sources: `database/migrations/2024_10_23_070634_create_policy_feature_template_fields_table.php`, `database/migrations/2024_10_23_115252_rename_policy_feature_template_fields_to_master_policy_feature_template_fields.php`, `database/migrations/2024_10_26_090424_modify_master_policy_feature_template_fields_nullable.php`, `database/migrations/2024_10_26_111834_add_column_is_migration_to_master_policy_feature_template_fields.php`, `database/migrations/2025_03_21_092435_add_policyidentifierid_column_to_table.php`, `database/migrations/2025_05_28_095519_add_column_field_description_to_table_master_policy_feature_template_fields.php`, `database/migrations/2025_08_26_071119_dropcolumn_policy_feature_template_field_info_in_master_policy_feature_template_fields.php`, `database/migrations/2025_08_28_064857_add_column_to_master_policy_feature_template_fields.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| template_field_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| policy_feature_template_field_name | varchar | 100 | No |  |  |  |  |  |
| policy_feature_template_field_placeholder | varchar | 255 | Yes |  |  |  |  |  |
| ref_master_temp_field_Type | integer |  | No |  |  |  |  |  |
| ref_template_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| is_mandatory | integer |  | No | 0 |  |  |  |  |
| ref_policyidentifier_id | integer |  | Yes |  |  |  |  |  |
| field_description | text |  | No |  |  |  |  |  |
| ref_fieldgrouping_id | varchar | 255 | Yes |  |  |  |  |  |

Primary key: `template_field_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_feature_templates`

Migration sources: `database/migrations/2024_10_23_072802_create_policy_feature_templates_table.php`, `database/migrations/2024_10_23_121734_rename_policy_feature_templates_to_master_policy_feature_templates.php`, `database/migrations/2024_11_20_074440_add_ref_policy_id_to_master_policy_feature_templates.php`, `database/migrations/2024_11_26_133752_modify_status_in_policy_feature_templates.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| template_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| policy_identifier | varchar | 100 | No |  |  |  |  |  |
| set_default | integer |  | No | 0 |  |  |  |  |
| status | integer |  | No | 1 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_policy_id | varchar | 100 | Yes |  |  |  |  |  |

Primary key: `template_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_temp_field_types`

Migration sources: `database/migrations/2024_10_25_072207_create_md_temp_field_type_table.php`, `database/migrations/2024_10_25_073442_rename_md_temp_field_type_to_md_temp_field_types.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| field_type | varchar | 50 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_field_type_ids`

Migration sources: `database/migrations/2024_10_26_105014_create_md_field_type_ids_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| field_type_id | integer |  | No |  |  |  |  |  |
| field_type_information | varchar | 255 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`

### `md_line_of_businesses`

Migration sources: `database/migrations/2024_10_28_160930_create_md_line_of_businesses_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| line_of_business_value | varchar | 100 | No |  |  |  |  |  |
| display_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_policy_types`

Migration sources: `database/migrations/2024_10_28_161623_create_md_policy_types_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| policy_type_value | varchar | 100 | No |  |  |  |  |  |
| display_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_family_definitions`

Migration sources: `database/migrations/2024_10_28_161744_create_md_family_definitions_table.php`, `database/migrations/2024_10_29_070738_rename_family_defination_to_name_in_md_family_definitions.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| display_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| name | varchar | 100 | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_intimate_claim_visibilities`

Migration sources: `database/migrations/2024_10_28_161955_create_md_intimate_claim_visibilities_table.php`, `database/migrations/2024_10_29_065057_rename_intimate_claim_visibility_to_name_in_md_intimate_claim_visibilities.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| display_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| name | varchar | 100 | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_line_of_business_policy_types`

Migration sources: `database/migrations/2024_10_28_162051_create_trn_mapping_line_of_business_policy_types.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| line_of_business_id | varchar | 100 | No |  |  |  |  |  |
| policy_type_id | varchar | 100 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_sum_insurer_types`

Migration sources: `database/migrations/2024_10_28_162615_create_md_sum_insurer_types_table.php`, `database/migrations/2024_10_29_065427_rename_md_sum_insurer_type_to_name_in_md_sum_insurer_types.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| display_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| name | varchar | 100 | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_add_policies`

Migration sources: `database/migrations/2024_10_30_081831_create_master_add_policies_table.php`, `database/migrations/2024_11_19_120340_add_ref_tpa_id_column_to_master_add_policies.php`, `database/migrations/2024_11_26_065149_modify_add_policy_details_column_nullable.php`, `database/migrations/2025_03_01_103612_add_column_user_id_to_master_add_policies_table.php`, `database/migrations/2025_06_20_142506_add_ref_fy_year_id_column_to_add_policy_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_name | varchar | 100 | No |  |  |  |  |  |
| ref_md_line_of_businesses_id | integer |  | No |  |  |  |  |  |
| line_of_business | varchar | 100 | No |  |  |  |  |  |
| ref_md_policy_types_id | integer |  | No |  |  |  |  |  |
| policy_type | varchar | 100 | No |  |  |  |  |  |
| ref_md_sum_insured_types_id | integer |  | Yes |  |  |  |  |  |
| sum_insured_type | varchar | 100 | Yes |  |  |  |  |  |
| ref_select_insurer_id | integer |  | No |  |  |  |  |  |
| select_insurer | varchar | 255 | No |  |  |  |  |  |
| select_tpa | text |  | Yes |  |  |  |  |  |
| have_policy_number | integer |  | No | 0 |  |  |  |  |
| policy_number | varchar | 100 | Yes |  |  |  |  |  |
| policy_start_date | varchar | 50 | Yes |  |  |  |  |  |
| policy_end_date | varchar | 50 | Yes |  |  |  |  |  |
| ref_md_family_definitions_id | integer |  | Yes |  |  |  |  |  |
| family_definition | varchar | 100 | Yes |  |  |  |  |  |
| ref_md_claim_submission_visibilities_id | integer |  | Yes | 0 |  |  |  |  |
| claim_submission_additional_email | text |  | Yes |  |  |  |  |  |
| ref_intimate_claim_visibilities_id | integer |  | Yes |  |  |  |  |  |
| intimate_claim_visibility | varchar | 50 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_tpa_id | integer |  | Yes |  |  |  |  |  |
| ref_corporate_id | varchar | 150 | Yes |  |  |  |  |  |
| user_id | integer |  | Yes |  |  |  |  |  |
| ref_fy_year_id | integer |  | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_sum_insureds`

Migration sources: `database/migrations/2024_10_30_133104_create_master_sum_insureds_table.php`, `database/migrations/2025_04_23_130029_create_add_reffeatureidentifierid_column_to_master_sum_insureds.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| sum_insured | integer |  | No |  |  |  |  |  |
| ref_policy_feature_identifier | varchar | 100 | No |  |  |  |  |  |
| ref_template_id | integer |  | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_feature_identifier_id | integer |  | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_data_uploads`

Migration sources: `database/migrations/2024_11_01_062254_create_master_policy_data_uploads_table.php`, `database/migrations/2025_02_15_104928_create_add_column_is_dataupload_to_master_policy_data_uploads.php`, `database/migrations/2025_02_15_124809_create_alter_column_remark_null_table.php`, `database/migrations/2025_09_02_143142_add_column_to_master_policy_data_upload.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| data_type | varchar | 100 | No |  |  |  |  |  |
| remark | varchar | 100 | Yes |  |  |  |  |  |
| policy_data_upload | varchar | 100 | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| is_dataupload | integer |  | No | 0 |  |  |  |  |
| original_file_name | varchar | 200 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_escalation_matrices`

Migration sources: `database/migrations/2024_11_01_111459_create_master_policy_escalation_matrices_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_escalation_matrices_level_id | integer |  | Yes |  |  |  |  |  |
| level | varchar | 100 | Yes |  |  |  |  |  |
| ref_master_users_id | integer |  | Yes |  |  |  |  |  |
| ref_user_fullname | varchar | 100 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_escalation_matrices`

Migration sources: `database/migrations/2024_11_01_112010_create_md_escalation_matrices_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| level | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_documents`

Migration sources: `database/migrations/2024_11_01_132335_create_master_policy_documents_table.php`, `database/migrations/2025_09_02_144538_add_column_to_master_policy_documents.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_document_type_id | integer |  | No |  |  |  |  |  |
| document_type | varchar | 100 | No |  |  |  |  |  |
| ref_document_name_id | integer |  | No |  |  |  |  |  |
| document_name | varchar | 100 | No |  |  |  |  |  |
| note | text |  | Yes |  |  |  |  |  |
| document_file | varchar | 255 | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| original_file_name | varchar | 200 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_document_types`

Migration sources: `database/migrations/2024_11_01_133002_create_md_document_types_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| document_type | varchar | 100 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_document_names`

Migration sources: `database/migrations/2024_11_01_133311_create_md_document_names_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| document_name | varchar | 100 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_cd_statements`

Migration sources: `database/migrations/2024_11_02_085557_create_master_policy_cd_statements_table.php`, `database/migrations/2024_12_13_131918_alter_column_ref_policy_id_to_nullable.php`, `database/migrations/2025_02_17_045739_create_add_column_is_dataupload_to_master_policy_cd_statements.php`, `database/migrations/2025_09_02_152018_add_column_to_master_policy_cd_statements.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_name | varchar | 255 | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| cd_number | varchar | 255 | No |  |  |  |  |  |
| ref_master_cd_accounts_id | integer |  | No |  |  |  |  |  |
| data_upload_file | varchar | 255 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| is_dataupload | integer |  | No | 0 |  |  |  |  |
| original_file_name | varchar | 200 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cd_accounts`

Migration sources: `database/migrations/2024_11_02_104644_create_master_cd_accounts_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| cd_name | varchar | 100 | No |  |  |  |  |  |
| cd_number | varchar | 100 | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| corporate_name | varchar | 100 | No |  |  |  |  |  |
| ref_insurer_id | integer |  | No |  |  |  |  |  |
| insurer_name | varchar | 100 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_corporate_buffer_transactions`

Migration sources: `database/migrations/2024_11_04_101557_create_master_policy_corporate_buffer_transactions_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| employee_code | varchar | 100 | No |  |  |  |  |  |
| ref_master_users_id | integer |  | No |  |  |  |  |  |
| patient_name | varchar | 100 | No |  |  |  |  |  |
| ref_master_family_members_id | integer |  | No |  |  |  |  |  |
| contact_no | varchar | 15 | Yes |  |  |  |  |  |
| email_address | varchar | 100 | Yes |  |  |  |  |  |
| claim_amount | integer |  | Yes |  |  |  |  |  |
| salted_amount | integer |  | Yes |  |  |  |  |  |
| employee_si_utilized | varchar | 100 | Yes |  |  |  |  |  |
| corporate_buffer_used | varchar | 100 | No |  |  |  |  |  |
| aliment | varchar | 100 | Yes |  |  |  |  |  |
| attach_document | varchar | 100 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_policy_corporate_buffer_amounts`

Migration sources: `database/migrations/2024_11_04_103413_create_master_policy_corporate_buffer_amounts_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| buffer_amount | varchar | 100 | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_corporateid_corporatecontactsids`

Migration sources: `database/migrations/2024_10_25_071400_create_trn_mapping_corporateid_hrid_table.php`, `database/migrations/2024_10_25_073205_rename_trn_mapping_corporateid_hrid_to_trn_mapping_corporateid_hrids.php`, `database/migrations/2024_11_08_131953_rename_trn_mapping_corporateid_hrids_to_trn_mapping_corporateid_corporatecontactsids.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| corporatecontacts_id | integer |  | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_insurer_lists`

Migration sources: `database/migrations/2024_11_15_111643_create_md_insurer_lists_table.php`, `database/migrations/2025_04_04_133016_add_logo_column_to_md_insurer_lists_table.php`, `database/migrations/2025_05_19_133716_add_column_to_md_insurer_list.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| code | varchar | 50 | Yes |  |  |  |  |  |
| name | varchar | 255 | Yes |  |  |  |  |  |
| display_id | integer |  | No | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| logo | varchar | 255 | Yes |  |  |  |  |  |
| LOB_type | integer |  | No | 0 |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_policy_data_types`

Migration sources: `database/migrations/2024_11_18_052020_create_md_policy_data_types_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| name | varchar | 150 | Yes |  |  |  |  |  |
| display_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_policy_tpas`

Migration sources: `database/migrations/2024_11_18_053929_create_md_policy_tpas_table.php`, `database/migrations/2025_08_28_173521_add_column_to_md_policy_tpas.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| name | varchar | 150 | Yes |  |  |  |  |  |
| display_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| tpa_logo_url | varchar | 150 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `mapping_policy_completions`

Migration sources: `database/migrations/2024_11_22_072320_create_mapping_policy_completions_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| columns_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| policy_id | integer |  | No |  |  |  |  |  |
| section_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `columns_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_policy_sections`

Migration sources: `database/migrations/2024_11_22_095952_create_md_policy_sections_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| section_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| name | varchar | 100 | No |  |  |  |  |  |
| mandatory | boolean |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `section_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_visibility_role_id_feature_tmps`

Migration sources: `database/migrations/2024_11_26_130400_create_md_visibility_role_id_feature_tmps_table.php`, `database/migrations/2024_12_05_055835_alter_md_visibility_role_idfeature_tmps.php`, `database/migrations/2025_06_10_060739_add_column_is_visible_to_md_visibiltiy_role_id_feature_tmps.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| role | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| role_id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| is_visible | integer |  | No | 0 |  |  |  |  |

Primary key: `role_id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `logs`

Migration sources: `database/migrations/2024_12_03_132032_create_logs_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| action | varchar | 255 | No |  |  |  |  |  |
| description | text |  | Yes |  |  |  |  |  |
| user_id | unsignedBigInteger |  | Yes |  |  | Yes | users(id) |  |
| ip_address | varchar | 255 | Yes |  |  |  |  |  |
| created_at | timestamp |  | No |  |  |  |  |  |

Primary key: `id`
Foreign keys: `user_id` -> `users`(id)
Audit / soft delete columns: `created_at`

### `md_role_accessdetails`

Migration sources: `database/migrations/2024_12_04_072204_create_md_role_accessdetails.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| module_id | integer |  | Yes |  |  |  |  |  |
| module_name | varchar | 255 | Yes |  |  |  |  |  |
| module_option_id | integer |  | Yes |  |  |  |  |  |
| module_option_name | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_roleid_roleaccessdetails`

Migration sources: `database/migrations/2024_12_04_111124_create_trn_mapping_roleid_roleaccessdetails_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| role_id | integer |  | Yes |  |  |  |  |  |
| module_id | integer |  | Yes |  |  |  |  |  |
| module_option_id | integer |  | Yes |  |  |  |  |  |
| selection_status | integer |  | No | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cashless_hospitals`

Migration sources: `database/migrations/2024_12_12_103621_create_master_cashless_hospitals_table.php`, `database/migrations/2024_12_16_143111_change_column_name_staus_to_status.php`, `database/migrations/2025_02_17_051308_create_add_column_is_dataupload_to_master_cashless_hospitals.php`, `database/migrations/2025_09_02_153044_add_column_to_master_cashless_hospitals.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_insurer_id | integer |  | No |  |  |  |  |  |
| insurer_name | varchar | 255 | No |  |  |  |  |  |
| ref_tpa_id | integer |  | Yes |  |  |  |  |  |
| tpa_name | varchar | 255 | Yes |  |  |  |  |  |
| ch_upload_data | varchar | 255 | No |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| is_dataupload | integer |  | No | 0 |  |  |  |  |
| original_file_name | varchar | 200 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_sample_documents`

Migration sources: `database/migrations/2024_12_23_070755_create_md_sample_documents_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| insurance_type | varchar | 15 | Yes |  |  |  |  |  |
| insurance_provider | varchar | 50 | Yes |  |  |  |  |  |
| document_name | varchar | 50 | Yes |  |  |  |  |  |
| document | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_claim_types`

Migration sources: `database/migrations/2025_01_20_082938_create_md_claim_types_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| claim_type_name | varchar | 50 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_intimateclaims`

Migration sources: `database/migrations/2025_01_20_115832_create_master_intimateclaims_table.php`, `database/migrations/2025_01_23_060247_create_add_column_portal_type_in_master_intimateclaims_table.php`, `database/migrations/2025_01_28_091915_add_userid_column_to_master_intimateclaims_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_name | varchar | 100 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| policy_no | varchar | 255 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 50 | Yes |  |  |  |  |  |
| ref_user_id | integer |  | Yes |  |  |  |  |  |
| patient_name | varchar | 255 | Yes |  |  |  |  |  |
| reason_claim | text |  | Yes |  |  |  |  |  |
| estimated_amount | float | 15 | Yes |  |  |  |  |  |
| hospitalization_date | varchar | 20 | Yes |  |  |  |  |  |
| discharge_date | varchar | 20 | Yes |  |  |  |  |  |
| mobile_number | varchar | 15 | Yes |  |  |  |  |  |
| email_id | varchar | 50 | Yes |  |  |  |  |  |
| date_of_consultation | varchar | 20 | Yes |  |  |  |  |  |
| consultation_amount | float | 15 | Yes |  |  |  |  |  |
| medicine_bill_amount | float | 15 | Yes |  |  |  |  |  |
| diagnostic_bill_amount | float | 15 | Yes |  |  |  |  |  |
| total_claim_amount | float | 15 | Yes |  |  |  |  |  |
| document_type | varchar | 20 | Yes |  |  |  |  |  |
| doc_upload | varchar | 255 | Yes |  |  |  |  |  |
| hospital_name | varchar | 100 | Yes |  |  |  |  |  |
| hospital_address | text |  | Yes |  |  |  |  |  |
| pincode | integer |  | Yes |  |  |  |  |  |
| city | varchar | 100 | Yes |  |  |  |  |  |
| state | varchar | 100 | Yes |  |  |  |  |  |
| claim_type | varchar | 50 | Yes |  |  |  |  |  |
| remarks | text |  | Yes |  |  |  |  |  |
| claim_intimate_type | varchar | 10 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| portal_type | varchar | 20 | Yes |  |  |  |  |  |
| userid | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_nonlife_claimintimations`

Migration sources: `database/migrations/2025_01_20_190923_create_master_nonlife_claimintimations_table.php`, `database/migrations/2025_01_28_091651_add_userid_column_to_nonlife_claimintimations_table.php`, `database/migrations/2025_01_29_125223_add_ref_policy_id_column_to_nonlife_claimintimations_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| intimation_number | varchar | 20 | Yes |  |  |  |  |  |
| corporate_name | varchar | 100 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| policy_type | varchar | 50 | Yes |  |  |  |  |  |
| policy_type_id | integer |  | Yes |  |  |  |  |  |
| policy_number | varchar | 100 | Yes |  |  |  |  |  |
| date_of_loss | varchar | 50 | Yes |  |  |  |  |  |
| location_loss | varchar | 100 | Yes |  |  |  |  |  |
| loss_type | varchar | 100 | Yes |  |  |  |  |  |
| estimated_claim_amount | float |  | Yes |  |  |  |  |  |
| nature_of_claim | varchar | 100 | Yes |  |  |  |  |  |
| remark | varchar | 100 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| userid | integer |  | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_nonlife_documentuploads`

Migration sources: `database/migrations/2025_01_20_191000_create_master_nonlife_documentuploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| title | varchar | 100 | Yes |  |  |  |  |  |
| description | varchar | 100 | Yes |  |  |  |  |  |
| date | varchar | 100 | Yes |  |  |  |  |  |
| attached_document | varchar | 255 | Yes |  |  |  |  |  |
| ref_claimintimation_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_nonlife_trackclaims`

Migration sources: `database/migrations/2025_01_20_191117_create_master_nonlife_trackclaims_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| claim_received_date | varchar | 100 | Yes |  |  |  |  |  |
| claim_intimation_date | varchar | 100 | Yes |  |  |  |  |  |
| claim_survey_date | varchar | 100 | Yes |  |  |  |  |  |
| current_status | varchar | 255 | Yes |  |  |  |  |  |
| final_status | integer |  | Yes |  |  |  |  |  |
| contact_person | varchar | 150 | Yes |  |  |  |  |  |
| surveyor_details | varchar | 150 | Yes |  |  |  |  |  |
| surveyor_contact_details | varchar | 150 | Yes |  |  |  |  |  |
| remark | varchar | 100 | Yes |  |  |  |  |  |
| contact_person_broker | varchar | 150 | Yes |  |  |  |  |  |
| ref_claimintimation_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_nonlife_claimsettlements`

Migration sources: `database/migrations/2025_01_20_191155_create_master_nonlife_claimsettlements_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| repair_costs | varchar | 100 | Yes |  |  |  |  |  |
| non_allowable_items | varchar | 100 | Yes |  |  |  |  |  |
| salvage | varchar | 100 | Yes |  |  |  |  |  |
| net_assessed_loss | varchar | 255 | Yes |  |  |  |  |  |
| approval_documents | varchar | 100 | Yes |  |  |  |  |  |
| payment_received_date | varchar | 150 | Yes |  |  |  |  |  |
| remark | varchar | 100 | Yes |  |  |  |  |  |
| ref_claimintimation_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_claimsubmissions`

Migration sources: `database/migrations/2025_01_21_093941_create_master_claimsubmissions_table.php`, `database/migrations/2025_01_29_124012_create_add_userid_column_to_master_claimsubmissions.php`, `database/migrations/2025_02_25_151430_create_add_column_portal_type_to_master_claimsubmissions.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| intimation_number | varchar | 20 | Yes |  |  |  |  |  |
| claim_number | varchar | 50 | Yes |  |  |  |  |  |
| corporate_name | varchar | 100 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| policy_no | varchar | 255 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 50 | Yes |  |  |  |  |  |
| ref_user_id | integer |  | Yes |  |  |  |  |  |
| patient_name | varchar | 255 | Yes |  |  |  |  |  |
| reason_claim | text |  | Yes |  |  |  |  |  |
| estimated_amount | float | 15 | Yes |  |  |  |  |  |
| hospitalization_date | varchar | 20 | Yes |  |  |  |  |  |
| discharge_date | varchar | 20 | Yes |  |  |  |  |  |
| hospital_name | varchar | 100 | Yes |  |  |  |  |  |
| hospital_address | text |  | Yes |  |  |  |  |  |
| pincode | integer |  | Yes |  |  |  |  |  |
| city | varchar | 100 | Yes |  |  |  |  |  |
| state | varchar | 100 | Yes |  |  |  |  |  |
| claim_type | varchar | 50 | Yes |  |  |  |  |  |
| remarks | text |  | Yes |  |  |  |  |  |
| userid | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| portal_type | varchar | 50 | No | 1 |  |  |  |  |
| employee_id | varchar | 50 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_claimsubmission_documents`

Migration sources: `database/migrations/2025_01_22_051335_create_master_claimsubmission_documents_table.php`, `database/migrations/2025_02_05_121355_alter_master_claimsubmission_documents.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| medicine_bill | varchar | 50 | Yes |  |  |  |  |  |
| medicine_bill_doc | varchar | 255 | Yes |  |  |  |  |  |
| doctor_consultation | varchar | 50 | Yes |  |  |  |  |  |
| doctor_consultation_doc | varchar | 255 | Yes |  |  |  |  |  |
| lab_report | varchar | 50 | Yes |  |  |  |  |  |
| lab_report_doc | varchar | 255 | Yes |  |  |  |  |  |
| paid_receipt | varchar | 50 | Yes |  |  |  |  |  |
| paid_receipt_doc | varchar | 255 | Yes |  |  |  |  |  |
| discharge_card | varchar | 50 | Yes |  |  |  |  |  |
| discharge_card_doc | varchar | 255 | Yes |  |  |  |  |  |
| indoor_case_paper | varchar | 50 | Yes |  |  |  |  |  |
| indoor_case_paper_doc | varchar | 255 | Yes |  |  |  |  |  |
| report | varchar | 50 | Yes |  |  |  |  |  |
| report_doc | varchar | 255 | Yes |  |  |  |  |  |
| hospital_bill | varchar | 50 | Yes |  |  |  |  |  |
| hospital_bill_doc | varchar | 255 | Yes |  |  |  |  |  |
| other_document | varchar | 50 | Yes |  |  |  |  |  |
| other_document_doc | varchar | 255 | Yes |  |  |  |  |  |
| ref_claimsubmission_id | integer |  | No |  |  |  |  |  |
| portal_type | varchar | 20 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| document_name | varchar | 200 | Yes |  |  |  |  |  |
| file_name | varchar | 200 | Yes |  |  |  |  |  |
| document_path | varchar | 255 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_escalation_matrices`

Migration sources: `database/migrations/2025_01_23_110401_create_master_escalation_matrices_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| fullname | varchar | 150 | Yes |  |  |  |  |  |
| phone_number | varchar | 15 | Yes |  |  |  |  |  |
| mobile_number | varchar | 15 | Yes |  |  |  |  |  |
| email_id | varchar | 50 | Yes |  |  |  |  |  |
| alt_email_id | varchar | 50 | Yes |  |  |  |  |  |
| send_mail_alt_email | boolean |  | Yes |  |  |  |  |  |
| company_fulladdress | text |  | Yes |  |  |  |  |  |
| type | varchar | 30 | Yes |  |  |  |  |  |
| type_id | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 1 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cashless_hospital_uploads`

Migration sources: `database/migrations/2025_01_24_135216_create_master_cashless_hospital_uploads_table.php`, `database/migrations/2025_09_23_152708_add_lat_lng_to_master_cashless_hospital_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| hospital_name | varchar | 255 | Yes |  |  |  |  |  |
| hospital_address | text |  | Yes |  |  |  |  |  |
| location | varchar | 255 | Yes |  |  |  |  |  |
| landmark | varchar | 255 | Yes |  |  |  |  |  |
| city | varchar | 150 | Yes |  |  |  |  |  |
| state | varchar | 150 | Yes |  |  |  |  |  |
| pincode | integer |  | Yes |  |  |  |  |  |
| email | varchar | 150 | Yes |  |  |  |  |  |
| stdcode | varchar | 150 | Yes |  |  |  |  |  |
| phone | varchar | 15 | Yes |  |  |  |  |  |
| insurer_name | varchar | 150 | Yes |  |  |  |  |  |
| ref_insurer_id | integer |  | Yes |  |  |  |  |  |
| tpa_name | varchar | 255 | Yes |  |  |  |  |  |
| ref_tpa_id | varchar | 255 | Yes |  |  |  |  |  |
| status | varchar | 255 | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| latitude | decimal | 10, 7 | Yes |  |  |  |  |  |
| longitude | decimal | 10, 7 | Yes |  |  |  |  |  |

Primary key: `id`
Indexes: `mchu_lat_index` (latitude); `mchu_lng_index` (longitude)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cd_statement_transactions`

Migration sources: `database/migrations/2025_01_28_053049_master_create_cd_statement_transactions_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate_name | varchar | 255 | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| cd_number | varchar | 255 | No |  |  |  |  |  |
| ref_cd_number_id | integer |  | Yes |  |  |  |  |  |
| policy_number | varchar | 255 | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| particular | varchar | 255 | No |  |  |  |  |  |
| ref_transaction_type_id | integer |  | No |  |  |  |  |  |
| transaction_type | varchar | 255 | No |  |  |  |  |  |
| policy_endorsement_no | varchar | 255 | Yes |  |  |  |  |  |
| employee_count | integer |  | Yes |  |  |  |  |  |
| dependant_count | integer |  | Yes |  |  |  |  |  |
| endorsement_issue_date | varchar | 255 | Yes |  |  |  |  |  |
| debit_amount | double |  | Yes |  |  |  |  |  |
| credit_amount | double |  | Yes |  |  |  |  |  |
| bank_name | varchar | 255 | Yes |  |  |  |  |  |
| check_no | varchar | 255 | Yes |  |  |  |  |  |
| remark | text |  | Yes |  |  |  |  |  |
| cd_document | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_inception_data_uploads`

Migration sources: `database/migrations/2025_01_28_155144_create_master_inception_data_uploads_table.php`, `database/migrations/2025_02_25_115638_add_column_for_master_inception_data_uploads_table.php`, `database/migrations/2025_04_30_063235_create_add_column_to_master_inception_data_upload.php`, `database/migrations/2025_05_16_131907_add_mail_send_column_to_master_inception_data_uploads.php`, `database/migrations/2025_06_23_112858_add_column_is_testuser_to_master_inception_data_uploads.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| employee_code | varchar | 100 | Yes |  |  |  |  |  |
| employee_name | varchar | 200 | Yes |  |  |  |  |  |
| gender | varchar | 50 | Yes |  |  |  |  |  |
| relationship | varchar | 150 | Yes |  |  |  |  |  |
| dob | varchar | 30 | Yes |  |  |  |  |  |
| age | integer |  | Yes |  |  |  |  |  |
| mobile_number | varchar | 15 | Yes |  |  |  |  |  |
| email | varchar | 150 | Yes |  |  |  |  |  |
| sum_insured | double |  | Yes |  |  |  |  |  |
| doj | varchar | 30 | Yes |  |  |  |  |  |
| endorsement_number | varchar | 50 | Yes |  |  |  |  |  |
| endorsement_date | varchar | 70 | Yes |  |  |  |  |  |
| endorsement_type | varchar | 50 | Yes |  |  |  |  |  |
| dol | varchar | 30 | Yes |  |  |  |  |  |
| member_card_number | varchar | 100 | Yes |  |  |  |  |  |
| designation | varchar | 70 | Yes |  |  |  |  |  |
| status | varchar | 255 | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| otp | integer |  | Yes |  |  |  |  |  |
| otp_expires_at | timestamp |  | Yes |  |  |  |  |  |
| is_register | integer |  | No | 0 |  |  |  |  |
| is_mail_send | integer |  | No | 0 |  |  |  |  |
| is_testuser | integer |  | No | 0 |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_total_claim_reports`

Migration sources: `database/migrations/2025_01_30_103410_create_master_total_claim_reports_table.php`, `database/migrations/2025_05_15_164640_alter_datatypes_from_double_to_string_master_total_claim_reports.php`, `database/migrations/2025_05_21_142018_changed_column_string_to_double_master_total_claim_reports.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 100 | Yes |  |  |  |  |  |
| employee_name | varchar | 150 | Yes |  |  |  |  |  |
| patient_name | varchar | 150 | Yes |  |  |  |  |  |
| relationship | varchar | 100 | Yes |  |  |  |  |  |
| claim_type | varchar | 100 | Yes |  |  |  |  |  |
| tpa_claim_no | varchar | 100 | Yes |  |  |  |  |  |
| date_of_hospitalization | varchar | 50 | Yes |  |  |  |  |  |
| date_of_discharge | varchar | 50 | Yes |  |  |  |  |  |
| hospital_name | varchar | 150 | Yes |  |  |  |  |  |
| amount_claimed | double | 255 | Yes |  |  |  |  |  |
| amount_sanctioned | double | 255 | Yes |  |  |  |  |  |
| claim_status | varchar | 50 | Yes |  |  |  |  |  |
| patient_gender | varchar | 10 | Yes |  |  |  |  |  |
| hospital_state | varchar | 50 | Yes |  |  |  |  |  |
| network_status | varchar | 50 | Yes |  |  |  |  |  |
| treatment_type | varchar | 50 | Yes |  |  |  |  |  |
| level_of_care | varchar | 50 | Yes |  |  |  |  |  |
| cause | varchar | 150 | Yes |  |  |  |  |  |
| city | varchar | 100 | Yes |  |  |  |  |  |
| age | integer |  | Yes |  |  |  |  |  |
| claim_file_submitted_dt | varchar | 50 | Yes |  |  |  |  |  |
| claim_settled_date | varchar | 20 | Yes |  |  |  |  |  |
| disease_category | varchar | 200 | Yes |  |  |  |  |  |
| claim_registered_date | varchar | 20 | Yes |  |  |  |  |  |
| intimation_method | varchar | 50 | Yes |  |  |  |  |  |
| sum_insured | double | 255 | Yes |  |  |  |  |  |
| tds_amount | double | 255 | Yes |  |  |  |  |  |
| deduction_amount | double | 255 | Yes |  |  |  |  |  |
| deduction_reason | varchar | 200 | Yes |  |  |  |  |  |
| deficiency_intimated_date | varchar | 20 | Yes |  |  |  |  |  |
| deficiency_submission_date | varchar | 20 | Yes |  |  |  |  |  |
| icd_code | varchar | 50 | Yes |  |  |  |  |  |
| claim_paid_amount | double | 255 | Yes |  |  |  |  |  |
| close_reasons | varchar | 200 | Yes |  |  |  |  |  |
| deficiency_reason | text |  | Yes |  |  |  |  |  |
| claim_sub_status | varchar | 50 | Yes |  |  |  |  |  |
| insurance_claim_no | varchar | 50 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cd_statement_data_uploads`

Migration sources: `database/migrations/2025_01_30_180728_create_master_cd_statement_data_uploads_table.php`, `database/migrations/2025_02_27_071401_add_column_to_master_cd_statement_data_uploads.php`, `database/migrations/2025_08_07_144713_add_column_to_master_cd_statement_data_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| particular | varchar | 100 | Yes |  |  |  |  |  |
| transaction_type | varchar | 50 | Yes |  |  |  |  |  |
| employee_count | integer |  | Yes |  |  |  |  |  |
| dependant_count | integer |  | Yes |  |  |  |  |  |
| policy_endorsement_no | varchar | 150 | Yes |  |  |  |  |  |
| endorsement_issued_date | varchar | 30 | Yes |  |  |  |  |  |
| debit_amount | double |  | Yes |  |  |  |  |  |
| credit_amount | double |  | Yes |  |  |  |  |  |
| bank_name | varchar | 150 | Yes |  |  |  |  |  |
| cheque_no | varchar | 15 | Yes |  |  |  |  |  |
| policy_number | varchar | 30 | Yes |  |  |  |  |  |
| remark | text |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| cd_number | varchar | 255 | Yes |  |  |  |  |  |
| corporate_name | varchar | 150 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| attachments | varchar | 255 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_intimateclaim_documents`

Migration sources: `database/migrations/2025_01_31_061632_create_master_intimateclaim_documents_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_intimateclaim_id | integer |  | No |  |  |  |  |  |
| document_type | varchar | 100 | Yes |  |  |  |  |  |
| doc_upload | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_enrollment_types`

Migration sources: `database/migrations/2025_02_04_180328_create_md_enrollment_types_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| enrollment_type | varchar | 70 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_enrollment_uploads`

Migration sources: `database/migrations/2025_02_05_120803_create_master_enrollment_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_type_id | integer |  | No |  |  |  |  |  |
| policy_type | varchar | 50 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| policy_number | varchar | 100 | Yes |  |  |  |  |  |
| enrollment_type | varchar | 50 | Yes |  |  |  |  |  |
| ref_enrollment_type_id | integer |  | Yes |  |  |  |  |  |
| description | varchar | 255 | Yes |  |  |  |  |  |
| enrollment_doc_upload | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_cashlesshospital_upload_errors`

Migration sources: `database/migrations/2025_02_17_064042_create_master_cashlesshospital_upload_errors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_id | integer |  | No |  |  |  |  |  |
| row | integer |  | No |  |  |  |  |  |
| column_name | varchar | 100 | No |  |  |  |  |  |
| errors | varchar | 100 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_dataupload_endorsement_upload_errors`

Migration sources: `database/migrations/2025_02_17_111052_create_master_dataupload_endorsement_upload_errors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_id | integer |  | No |  |  |  |  |  |
| row | integer |  | No |  |  |  |  |  |
| column_name | varchar | 100 | No |  |  |  |  |  |
| errors | varchar | 100 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_endorsement_data_uploads`

Migration sources: `database/migrations/2025_02_17_112027_create_master_endorsement_data_uploads_table.php`, `database/migrations/2025_02_18_095330_create_add_column_ref_policy_id_to_master_endorsement_data_uploads_table.php`, `database/migrations/2025_02_19_063751_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_02_19_072825_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_02_19_072941_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_02_19_073123_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_02_19_073228_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_02_19_073517_rename_columns_for_table_master_endorsement_data_uploads.php`, `database/migrations/2025_05_31_110943_add_column_isregister_to_master_endorsement_data_upload.php`, `database/migrations/2025_06_23_112956_add_column_is_testuser_to_master_endorsement_data_uploads.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| employee_name | varchar | 50 | Yes |  |  |  |  |  |
| gender | varchar | 50 | Yes |  |  |  |  |  |
| relationship | varchar | 50 | Yes |  |  |  |  |  |
| age | varchar | 50 | Yes |  |  |  |  |  |
| mobile_number | varchar | 50 | Yes |  |  |  |  |  |
| sum_insured | varchar | 50 | Yes |  |  |  |  |  |
| endorsement_date | varchar | 50 | Yes |  |  |  |  |  |
| endorsement_type | varchar | 50 | Yes |  |  |  |  |  |
| member_card_number | varchar | 50 | Yes |  |  |  |  |  |
| designation | varchar | 50 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| employee_code | varchar | 50 | Yes |  |  |  |  |  |
| dob | varchar | 50 | Yes |  |  |  |  |  |
| email | varchar | 50 | Yes |  |  |  |  |  |
| doj | varchar | 50 | Yes |  |  |  |  |  |
| dol | varchar | 50 | Yes |  |  |  |  |  |
| endorsement_number | varchar | 50 | Yes |  |  |  |  |  |
| is_register | integer |  | No | 0 |  |  |  |  |
| is_mail_send | integer |  | No | 0 |  |  |  |  |
| is_testuser | integer |  | No | 0 |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_dynamic_templates`

Migration sources: `database/migrations/2025_03_03_073411_create_master_dynamic_templates_table.php`, `database/migrations/2025_03_06_133400_create_modify_column_datatype_to_table_master_dynamic_templates.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| template_name | varchar | 100 | Yes |  |  |  |  |  |
| email_category | varchar | 100 | Yes |  |  |  |  |  |
| subject | varchar | 150 | Yes |  |  |  |  |  |
| attachment | varchar | 200 | Yes |  |  |  |  |  |
| ref_user_id | integer |  | Yes |  |  |  |  |  |
| template | text | 255 | Yes |  |  |  |  |  |
| status | varchar | 255 | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_welcome_mailers`

Migration sources: `database/migrations/2025_03_03_074327_create_master_welcome_mailer_table.php`, `database/migrations/2025_03_06_131443_create_add_column_to_table_master_welcome_mailers.php`, `database/migrations/2025_04_05_064802_add_groupcode_column_to_master_welcome_mailers.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| corporate | varchar | 100 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| policy_number | varchar | 15 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| template_name | varchar | 100 | Yes |  |  |  |  |  |
| ref_template_id | varchar | 255 | Yes |  |  |  |  |  |
| employee_details | varchar | 100 | Yes |  |  |  |  |  |
| escalation_matrix | varchar | 150 | Yes |  |  |  |  |  |
| policy_start_date | varchar | 70 | Yes |  |  |  |  |  |
| policy_end_date | varchar | 70 | Yes |  |  |  |  |  |
| policy_type | varchar | 100 | Yes |  |  |  |  |  |
| attach_ecards | boolean |  | Yes |  |  |  |  |  |
| ref_user_id | integer |  | Yes |  |  |  |  |  |
| is_data_upload | varchar | 255 | Yes |  |  |  |  |  |
| status | varchar | 255 | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| bcc | varchar | 255 | Yes |  |  |  |  |  |
| cc | varchar | 255 | Yes |  |  |  |  |  |
| subject | varchar | 255 | Yes |  |  |  |  |  |
| template_content | text |  | Yes |  |  |  |  |  |
| group_code | varchar | 100 | Yes |  |  |  |  |  |
| start-date-end-date | varchar | 100 | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_welcomemail_email_sendings`

Migration sources: `database/migrations/2025_03_03_092427_create_master_welcomemail_email_sendings_table.php`, `database/migrations/2025_03_07_093133_create_add_column_to_table_master_welcomemail_email_sendings.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 255 | Yes |  |  |  |  |  |
| name | varchar | 255 | Yes |  |  |  |  |  |
| email | varchar | 255 | Yes |  |  |  |  |  |
| phone_number | varchar | 255 | Yes |  |  |  |  |  |
| email_status | varchar | 255 | No | 0 |  |  |  |  |
| email_sent_at | varchar | 255 | Yes |  |  |  |  |  |
| email_error | varchar | 255 | Yes |  |  |  |  |  |
| status | varchar | 255 | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_endorsementcalculation_rackrates`

Migration sources: `database/migrations/2025_03_13_032106_create_master_endorsementcalculation_rackrates_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| corporate | varchar | 150 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| policy_number | varchar | 150 | Yes |  |  |  |  |  |
| ref_enrollment_type_id | integer |  | Yes |  |  |  |  |  |
| enrollment_type | varchar | 100 | Yes |  |  |  |  |  |
| ref_policy_type_id | integer |  | Yes |  |  |  |  |  |
| policy_type | varchar | 100 | Yes |  |  |  |  |  |
| ref_user_id | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_endorsementcalculation_rackrates_suminsureds`

Migration sources: `database/migrations/2025_03_13_033513_create_master_endorsementcalculation_rackrates_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| ref_rackrates_suminsured_values_id | integer |  | Yes |  |  |  |  |  |
| sum_insured_value | varchar | 255 | Yes |  |  |  |  |  |
| age_from | integer |  | Yes |  |  |  |  |  |
| age_to | integer |  | Yes |  |  |  |  |  |
| annual_premium | float |  | Yes |  |  |  |  |  |
| total_mille_rate | varchar | 150 | Yes |  |  |  |  |  |
| pure_mille_rate | varchar | 150 | Yes |  |  |  |  |  |
| terminal_illness_mille_rate | varchar | 150 | Yes |  |  |  |  |  |
| critical_illness_mille_rate | varchar | 150 | Yes |  |  |  |  |  |
| ref_rackrates_id | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_rackrates_suminsured_values`

Migration sources: `database/migrations/2025_03_14_060803_create_master_rackrates_suminsured_values_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_rackrates_id | integer |  | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| ref_suminsured_id | integer |  | No |  |  |  |  |  |
| suminsured_value | integer |  | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_employee_logs`

Migration sources: `database/migrations/2025_03_15_120511_create_master_employee_logs_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| employee_id | varchar | 255 | Yes |  |  |  |  |  |
| action | varchar | 255 | Yes |  |  |  |  |  |
| ip_address | varchar | 255 | Yes |  |  |  |  |  |
| user_agent | varchar | 255 | Yes |  |  |  |  |  |
| details | varchar | 255 | Yes |  |  |  |  |  |
| device_type | varchar | 255 | No | 1 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `policyfeature_identifiers`

Migration sources: `database/migrations/2025_03_21_091021_create_policyfeature_identifiers_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| feature_identifier_value | varchar | 255 | No |  |  |  |  |  |
| ref_template_id | integer |  | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_ecards_data_uploads`

Migration sources: `database/migrations/2025_04_04_125139_create_master_ecards_data_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 100 | Yes |  |  |  |  |  |
| ecard_data_originalname | varchar | 100 | Yes |  |  |  |  |  |
| ecards_data_url | varchar | 255 | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| data_upload | integer |  | No | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_ecards_data_upload_errors`

Migration sources: `database/migrations/2025_04_14_092547_create_master_ecards_data_upload_errors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_id | integer |  | Yes |  |  |  |  |  |
| errors | varchar | 100 | Yes |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_corporate_employee_otps`

Migration sources: `database/migrations/2025_06_02_035500_create_trn_mapping_corporate_employee_otps_table.php`, `database/migrations/2025_09_09_053750_add_column_to_trn_mapping_corporate_employee_otps.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| employee_code | varchar | 20 | No |  |  |  |  |  |
| mobile_number | varchar | 20 | No |  |  |  |  |  |
| email | varchar | 255 | No |  |  |  |  |  |
| otp | integer |  | Yes |  |  |  |  |  |
| otp_expires_at | timestamp |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| is_deletion_user | integer |  | No | 0 |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_notification_templates`

Migration sources: `database/migrations/2025_06_06_115542_create_master_notification_templates_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| template_key | varchar | 255 | No |  |  |  |  |  |
| template | text |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_notifications`

Migration sources: `database/migrations/2025_06_06_134158_create_trn_mapping_notifications_table.php`, `database/migrations/2025_06_09_122341_rename_column_trn_mapping_notifications.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| template_key | varchar | 100 | No |  |  |  |  |  |
| template | text |  | No |  |  |  |  |  |
| ref_user_id | integer |  | No |  |  |  |  |  |
| author | varchar | 100 | No |  |  |  |  |  |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| portal_type | integer |  | No | 0 |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| is_read | integer |  | No | 0 |  |  |  |  |
| is_admin_read | integer |  | No | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| ref_template_key_id | integer |  | No |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_financial_year_logics`

Migration sources: `database/migrations/2025_06_20_064459_create_md_financial_year_logics_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fy_id | unsignedBigInteger |  | Yes |  |  |  |  |  |
| fy_start_date | varchar | 15 | No |  |  |  |  |  |
| fy_end_date | varchar | 15 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: none declared
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_financial_years`

Migration sources: `database/migrations/2025_06_20_143033_create_md_financial_years_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| fy_start_year | varchar | 15 | No |  |  |  |  |  |
| fy_end_year | varchar | 15 | No |  |  |  |  |  |
| default_year | boolean |  | No | false |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `log_master_endorsement_calculations_datauploads`

Migration sources: `database/migrations/2025_07_09_184444_create_log_master_endorsement_calculations_datauploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| endorsment_calculation_data_uploads | varchar | 255 | Yes |  |  |  |  |  |
| ref_policy_id | unsignedBigInteger |  | No |  |  | Yes | master_add_policies(id) |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_policy_id` -> `master_add_policies`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `log_endorsement_calculations_dataupload_calculations`

Migration sources: `database/migrations/2025_07_09_193852_create_log_endorsement_calculations_dataupload_calculations_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_endorsment_calculation_data_upload_id | unsignedBigInteger |  | No |  |  |  |  |  |
| ref_policy_id | unsignedBigInteger |  | No |  |  | Yes | master_add_policies(id) |  |
| age_group | varchar | 15 | Yes |  |  |  |  |  |
| sum_insured | varchar | 15 | Yes |  |  |  |  |  |
| annual_premium | varchar | 15 | Yes |  |  |  |  |  |
| premium_per_day | float | 15, 3 | Yes |  |  |  |  |  |
| total_days | varchar | 15 | Yes |  |  |  |  |  |
| member_count | varchar | 15 | Yes |  |  |  |  |  |
| premium_value | float | 15, 3 | Yes |  |  |  |  |  |
| premium_type_id | integer |  | Yes |  |  |  |  |  |
| premium_type | varchar | 20 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_policy_id` -> `master_add_policies`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `temp_endorsement_calculations_import_data`

Migration sources: `database/migrations/2025_07_10_133813_create_temp_endorsement_calculations_imports_table.php`, `database/migrations/2025_07_16_133011_create_add_column_ref_endorsement_calculation_data_upload_id_to_temp_endorsement_calculations_import_data.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| employee_code | varchar | 255 | No |  |  |  |  |  |
| employee_name | varchar | 255 | No |  |  |  |  |  |
| relation | varchar | 255 | No |  |  |  |  |  |
| endorsement_type | varchar | 255 | No |  |  |  |  |  |
| date_of_joining_or_leaving | varchar | 255 | No |  |  |  |  |  |
| date_of_birth | varchar | 255 | Yes |  |  |  |  |  |
| gender | varchar | 255 | Yes |  |  |  |  |  |
| age | integer |  | Yes |  |  |  |  |  |
| sum_insured | integer |  | No |  |  |  |  |  |
| age_group | varchar | 255 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| ref_endorsment_calculation_data_upload_id | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`

### `master_endorsement_calculations_details`

Migration sources: `database/migrations/2025_07_11_210318_create_master_endorsement_calculations_details_table.php`, `database/migrations/2025_07_15_064701_alter_column_name_endorsement_type_master_endorsement_calculations_details.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_endorsment_calculation_data_upload_id | unsignedBigInteger |  | No |  |  |  |  |  |
| ref_policy_id | unsignedBigInteger |  | No |  |  | Yes | master_add_policies(id) |  |
| policy_number | varchar | 150 | Yes |  |  |  |  |  |
| ref_corporate_id | integer |  | Yes |  |  |  |  |  |
| corporate_name | varchar | 150 | Yes |  |  |  |  |  |
| policy_start_date | varchar | 150 | Yes |  |  |  |  |  |
| policy_end_date | varchar | 150 | Yes |  |  |  |  |  |
| ref_policy_types_id | integer |  | Yes |  |  |  |  |  |
| policy_type | varchar | 20 | Yes |  |  |  |  |  |
| total_addition_premium | float | 15, 3 | Yes |  |  |  |  |  |
| total_deletion_premium | float | 15, 3 | Yes |  |  |  |  |  |
| net_premium | float | 15, 3 | Yes |  |  |  |  |  |
| endorsement_title | varchar | 20 | Yes |  |  |  |  |  |
| endorsement_number | varchar | 20 | Yes |  |  |  |  |  |
| transaction_statements | varchar | 20 | Yes |  |  |  |  |  |
| created_by | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| enrollment_type | varchar | 150 | Yes |  |  |  |  |  |
| ref_enrollment_type_id | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_policy_id` -> `master_add_policies`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_dynamic_template_variables`

Migration sources: `database/migrations/2025_07_16_142323_create_md_dynamic_template_variables_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| dynamic_variables | varchar | 100 | No |  |  |  |  |  |
| description | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `dynamic_template_email_categories`

Migration sources: `database/migrations/2025_07_18_144625_create_dynamic_template_email_categories_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| email_category | varchar | 255 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_notes`

Migration sources: `database/migrations/2025_07_21_030446_create_master_online_enrollment_notes_table.php`, `database/migrations/2025_07_28_073708_add_column_to_master_online_enrollment_notes.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| header_name | varchar | 255 | No |  |  |  |  |  |
| remark | varchar | 255 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| note_check | boolean |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_validationforms`

Migration sources: `database/migrations/2025_07_21_033315_create_master_online_enrollment_validationforms_table.php`, `database/migrations/2025_08_11_033935_add_slot_name_column_to_master_online_enrollment_validationform.php`, `database/migrations/2025_08_15_032231_add_column_to_master_online_enrollment_validationforms.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| corporate_name | varchar | 150 | No |  |  |  |  |  |
| ref_policy_id | integer |  | No |  |  |  |  |  |
| policy_number | varchar | 150 | No |  |  |  |  |  |
| ref_insurer_id | integer |  | No |  |  |  |  |  |
| select_insurer | varchar | 150 | No |  |  |  |  |  |
| ref_tpa_id | integer |  | No |  |  |  |  |  |
| select_tpa | varchar | 150 | No |  |  |  |  |  |
| policy_start_date | varchar | 15 | No |  |  |  |  |  |
| policy_end_date | varchar | 15 | No |  |  |  |  |  |
| window_period_start_date | varchar | 15 | No |  |  |  |  |  |
| window_period_end_date | varchar | 15 | No |  |  |  |  |  |
| enrollment_draft | varchar | 50 | No |  |  |  |  |  |
| acknowledgement_draft | varchar | 50 | No |  |  |  |  |  |
| employee_details_editable | boolean |  | No |  |  |  |  |  |
| main_heading | varchar | 50 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| slot_name | varchar | 255 | Yes |  |  |  |  |  |
| enrollment_draft_id | integer |  | Yes |  |  |  |  |  |
| acknowledgement_draft_id | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_employeedetails`

Migration sources: `database/migrations/2025_07_28_050925_create_master_online_enrollment_employeedetails_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| employee_details_show_hide | boolean |  | Yes |  |  |  |  |  |
| emp_suminsured_change_option | boolean |  | Yes |  |  |  |  |  |
| emp_suminsured_premium_ageband_ops | varchar | 10 | Yes |  |  |  |  |  |
| emp_suminsured_premium_ops | varchar | 10 | Yes |  |  |  |  |  |
| emp_suminsuredpremium_gst_type | boolean |  | Yes |  |  |  |  |  |
| allowed_upgrade_limit | varchar | 20 | Yes |  |  |  |  |  |
| alt_email_access | boolean |  | Yes |  |  |  |  |  |
| alt_content_no_access | boolean |  | Yes |  |  |  |  |  |
| official_contact_no_access | boolean |  | Yes |  |  |  |  |  |
| official_email_access | boolean |  | Yes |  |  |  |  |  |
| dateofbirth_access | boolean |  | Yes |  |  |  |  |  |
| gender_access | boolean |  | Yes |  |  |  |  |  |
| suminsured_access | boolean |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_emp_detail_suminsureds`

Migration sources: `database/migrations/2025_07_28_052235_create_trn_emp_detail_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_empdetails_id | integer |  | Yes |  |  |  |  |  |
| suminsured | varchar | 10 | Yes |  |  |  |  |  |
| age_band_min | varchar | 10 | Yes |  |  |  |  |  |
| age_band_max | varchar | 10 | Yes |  |  |  |  |  |
| premium | varchar | 10 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_gmc_policies`

Migration sources: `database/migrations/2025_07_28_053723_create_master_online_enrollment_gmc_policies_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| gmc_policy_check | boolean |  | Yes |  |  |  |  |  |
| gmc_header_name | varchar | 50 | Yes |  |  |  |  |  |
| gmcmember_add | boolean |  | Yes |  |  |  |  |  |
| gmcmember_edit | boolean |  | Yes |  |  |  |  |  |
| gmcmember_delete | boolean |  | Yes |  |  |  |  |  |
| gmc_nameedit_access | boolean |  | Yes |  |  |  |  |  |
| gmc_genderedit_access | boolean |  | Yes |  |  |  |  |  |
| gmc_dob_edit_access | boolean |  | Yes |  |  |  |  |  |
| gmc_note_header_name | varchar | 50 | Yes |  |  |  |  |  |
| gmc_note_message | varchar | 150 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_gmc_policies_suminsureds`

Migration sources: `database/migrations/2025_07_28_054542_create_trn_mapping_gmc_policies_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_gmcpolicies_id | integer |  | Yes |  |  |  |  |  |
| relation | varchar | 20 | Yes |  |  |  |  |  |
| max_age | integer |  | Yes |  |  |  |  |  |
| relation_category | json |  | Yes |  |  |  |  |  |
| max_count | integer |  | Yes |  |  |  |  |  |
| cross_combination | boolean |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_voluntary_parent_policies`

Migration sources: `database/migrations/2025_07_28_055722_create_master_online_enrollment_voluntary_parent_policies_table.php`, `database/migrations/2025_08_13_132931_adding_null_value_to_relations_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| parent_policy_check | boolean |  | Yes |  |  |  |  |  |
| voluntary_parents_header_name | varchar | 50 | No |  |  |  |  |  |
| voluntary_add | boolean |  | No |  |  |  |  |  |
| voluntary_edit | boolean |  | No |  |  |  |  |  |
| voluntary_delete | boolean |  | No |  |  |  |  |  |
| voluntary_name_editaccess | boolean |  | No |  |  |  |  |  |
| voluntary_gender_editaccess | boolean |  | No |  |  |  |  |  |
| voluntay_dobedit_access | boolean |  | No |  |  |  |  |  |
| volunrary_parents_age | integer |  | No |  |  |  |  |  |
| relations | json |  | Yes |  |  |  |  |  |
| voluntary_parents_count | integer |  | No |  |  |  |  |  |
| voluntary_parents_cross_combination_check | boolean |  | No |  |  |  |  |  |
| parents_gst_type | integer |  | No |  |  |  |  |  |
| volunrary_parents_combination_type | integer |  | No |  |  |  |  |  |
| volunrary_parents_note_header_name | varchar | 150 | No |  |  |  |  |  |
| volunrary_parents_note_message | varchar | 150 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_voluntary_parent_policies_suminsureds`

Migration sources: `database/migrations/2025_07_28_060931_create_trn_mapping_voluntary_parent_policies_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_voluntary_parent_id | integer |  | Yes |  |  |  |  |  |
| relation | varchar | 20 | Yes |  |  |  |  |  |
| suminsured | varchar | 20 | Yes |  |  |  |  |  |
| premium | varchar | 20 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_topup_policies`

Migration sources: `database/migrations/2025_07_28_061908_create_master_online_enrollment_topup_policies_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| topup_policy_check | boolean |  | Yes |  |  |  |  |  |
| topup_header_name | varchar | 50 | Yes |  |  |  |  |  |
| topup_gst_type | integer |  | Yes |  |  |  |  |  |
| topup_note_header_name | varchar | 150 | Yes |  |  |  |  |  |
| topup_note_message | varchar | 150 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_topup_policies_suminsureds`

Migration sources: `database/migrations/2025_07_28_062757_create_trn_mapping_voluntary_topup_policies_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_topup_policies_id | integer |  | Yes |  |  |  |  |  |
| suminsured | varchar | 20 | Yes |  |  |  |  |  |
| premium | varchar | 20 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_opd_policies`

Migration sources: `database/migrations/2025_07_28_063159_create_master_online_enrollment_opd_policies_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| opd_policy_check | boolean |  | Yes |  |  |  |  |  |
| opd_header_name | varchar | 50 | Yes |  |  |  |  |  |
| opd_gst_type | integer |  | Yes |  |  |  |  |  |
| opd_note_header_name | varchar | 150 | Yes |  |  |  |  |  |
| opd_note_message | varchar | 150 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_opd_policies_suminsureds`

Migration sources: `database/migrations/2025_07_28_063746_create_trn_mapping_voluntary_opd_policies_suminsureds_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_opd_policy_id | integer |  | Yes |  |  |  |  |  |
| suminsured | varchar | 20 | Yes |  |  |  |  |  |
| premium | varchar | 20 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_gpa_policies`

Migration sources: `database/migrations/2025_07_28_064114_create_master_online_enrollment_gpa_policies_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| gpa_policy_check | boolean |  | Yes |  |  |  |  |  |
| gpa_policyheadder_name | varchar | 50 | Yes |  |  |  |  |  |
| gpa_note_header_name | varchar | 150 | Yes |  |  |  |  |  |
| gpa_note_message | varchar | 150 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_gtl_policies`

Migration sources: `database/migrations/2025_07_28_064717_create_master_online_enrollment_gtl_policies_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| gtl_policy_check | boolean |  | Yes |  |  |  |  |  |
| gtl_policyheadder_name | varchar | 50 | Yes |  |  |  |  |  |
| gtl_note_header_name | varchar | 150 | Yes |  |  |  |  |  |
| gtl_note_message | varchar | 150 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `add_column_to_master_online_enrollment_notes`

Migration sources: `database/migrations/2025_07_28_065740_create_add_column_to_master_online_enrollment_notes_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| note_check | boolean |  | Yes |  |  |  |  |  |

Primary key: none declared

### `master_online_enrollment_escalation_matrices`

Migration sources: `database/migrations/2025_08_11_134008_create_master_online_enrollment_escalation_matrices_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validationform_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_em_user_id | integer |  | Yes |  |  |  |  |  |
| name | varchar | 150 | Yes |  |  |  |  |  |
| email | varchar | 150 | Yes |  |  |  |  |  |
| contact | varchar | 15 | Yes |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validationform_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_empportal_form_uploads`

Migration sources: `database/migrations/2025_08_13_061041_create_master_online_enrollment_empportal_form_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| online_enrollment_form_check | boolean |  | No | false |  |  |  |  |
| ref_validation_form_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_validationforms(id) |  |
| ref_data_type_id | integer |  | Yes |  |  |  |  |  |
| data_type | varchar | 150 | Yes |  |  |  |  |  |
| original_filename | varchar | 150 | Yes |  |  |  |  |  |
| attachment | varchar | 150 | Yes |  |  |  |  |  |
| window_period_start_date | varchar | 15 | Yes |  |  |  |  |  |
| window_period_end_date | varchar | 15 | Yes |  |  |  |  |  |
| slot_name | varchar | 50 | Yes |  |  |  |  |  |
| email_send_count | integer |  | Yes |  |  |  |  |  |
| is_dataupload | integer |  | No | 1 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_validation_form_id` -> `master_online_enrollment_validationforms`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_log_online_enrollment_empportal_form_upload_data_errors`

Migration sources: `database/migrations/2025_08_13_200803_create_master_log_online_enrollment_empportal_form_upload_data_errors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validation_form_id | integer |  | Yes |  |  |  |  |  |
| ref_empportal_form_uploads_id | integer |  | Yes |  |  |  |  |  |
| message | text |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_online_enrollment_empportal_form_upload_data`

Migration sources: `database/migrations/2025_08_13_201717_create_master_online_enrollment_empportal_form_upload_data_table.php`, `database/migrations/2025_08_18_061125_add_column_to_master_online_enrollment_empportal_form_upload_data.php`, `database/migrations/2025_08_20_230611_add_column_to_master_online_enrollment_empportal_form_upload_data.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validation_form_id | integer |  | Yes |  |  |  |  |  |
| ref_empportal_form_uploads_id | unsignedBigInteger |  | No |  |  | Yes | master_online_enrollment_empportal_form_uploads(id) |  |
| employee_code | varchar | 100 | Yes |  |  |  |  |  |
| employee_name | varchar | 255 | Yes |  |  |  |  |  |
| relation | varchar | 50 | Yes |  |  |  |  |  |
| gender | varchar | 10 | Yes |  |  |  |  |  |
| age | integer |  | Yes |  |  |  |  |  |
| dob | varchar | 15 | Yes |  |  |  |  |  |
| marital_status | varchar | 10 | Yes |  |  |  |  |  |
| blood_group | varchar | 20 | Yes |  |  |  |  |  |
| suminsured | varchar | 10 | Yes |  |  |  |  |  |
| email_id | varchar | 150 | Yes |  |  |  |  |  |
| contact_no | varchar | 15 | Yes |  |  |  |  |  |
| verification_status | integer |  | No | 1 |  |  |  |  |
| verified_date | varchar | 15 | Yes |  |  |  |  |  |
| alternate_email_id | varchar | 150 | Yes |  |  |  |  |  |
| alternate_contact_no | varchar | 15 | Yes |  |  |  |  |  |
| topup_suminsured | varchar | 10 | Yes |  |  |  |  |  |
| topup_suminsured_premium | varchar | 10 | Yes |  |  |  |  |  |
| opd_suminsured | varchar | 10 | Yes |  |  |  |  |  |
| opd_suminsured_premium | varchar | 10 | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |
| slot_name | varchar | 255 | Yes |  |  |  |  |  |
| mail_count | integer |  | Yes |  |  |  |  |  |

Primary key: `id`
Foreign keys: `ref_empportal_form_uploads_id` -> `master_online_enrollment_empportal_form_uploads`(id)
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_log_online_enrollment_emp_mailsendings`

Migration sources: `database/migrations/2025_08_18_133623_create_master_log_online_enrollment_emp_mailsendings_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validation_form_id | integer |  | Yes |  |  |  |  |  |
| emp_name | varchar | 255 | Yes |  |  |  |  |  |
| to_mail | varchar | 255 | Yes |  |  |  |  |  |
| bcc | varchar | 255 | Yes |  |  |  |  |  |
| cc | varchar | 255 | Yes |  |  |  |  |  |
| subject | varchar | 255 | Yes |  |  |  |  |  |
| template_content | text |  | Yes |  |  |  |  |  |
| mail_type | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_log_online_enrollment_empportal_addition_changes`

Migration sources: `database/migrations/2025_08_20_150929_create_master_log_online_enrollment_empportal_addition_deletion_corrections_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_validation_form_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 50 | Yes |  |  |  |  |  |
| employee_name | varchar | 200 | Yes |  |  |  |  |  |
| relation | varchar | 30 | Yes |  |  |  |  |  |
| gender | varchar | 15 | Yes |  |  |  |  |  |
| dob | varchar | 30 | Yes |  |  |  |  |  |
| email_id | varchar | 150 | Yes |  |  |  |  |  |
| contact_no | varchar | 15 | Yes |  |  |  |  |  |
| field_name | varchar | 100 | Yes |  |  |  |  |  |
| previous_data | varchar | 100 | Yes |  |  |  |  |  |
| updated_data | varchar | 100 | Yes |  |  |  |  |  |
| action_type | integer |  | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_log_emp_upload_audits`

Migration sources: `database/migrations/2025_08_21_182949_create_master_log_emp_upload_audits_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| employee_code | varchar | 100 | No |  |  |  |  |  |
| ref_validationform_id | integer |  | No |  |  |  |  |  |
| function_name | varchar | 255 | Yes |  |  |  |  |  |
| log_details | text |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_policyfeature_groupings`

Migration sources: `database/migrations/2025_08_26_065107_create_md_policyfeature_groupings.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| display_name | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_nominee_data_uploads`

Migration sources: `database/migrations/2025_09_02_121958_create_master_nominee_data_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_policy_id | integer |  | Yes |  |  |  |  |  |
| employee_code | varchar | 150 | Yes |  |  |  |  |  |
| employee_name | varchar | 255 | Yes |  |  |  |  |  |
| nominee_name | varchar | 255 | Yes |  |  |  |  |  |
| nominee_relationship | varchar | 150 | Yes |  |  |  |  |  |
| nominee_dob | varchar | 30 | Yes |  |  |  |  |  |
| nominee_percentage | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_corporate_edit_employee_uploads`

Migration sources: `database/migrations/2025_09_03_134113_create_master_corporate_edit_employee_uploads_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| corporate_name | varchar | 150 | Yes |  |  |  |  |  |
| file_original_name | varchar | 255 | Yes |  |  |  |  |  |
| file_path | varchar | 255 | Yes |  |  |  |  |  |
| is_dataupload | integer |  | Yes |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_log_corporate_edit_employees`

Migration sources: `database/migrations/2025_09_03_144358_create_master_log_corporate_edit_employees_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_doc_upload_id | integer |  | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| employee_code | varchar | 150 | No |  |  |  |  |  |
| mobile_number | varchar | 15 | No |  |  |  |  |  |
| email_id | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `master_corporate_edit_employees_upload_errors`

Migration sources: `database/migrations/2025_09_03_145155_create_master_corporate_edit_employees_upload_errors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| ref_doc_upload_id | integer |  | No |  |  |  |  |  |
| row | integer |  | No |  |  |  |  |  |
| column_name | varchar | 155 | No |  |  |  |  |  |
| errors | varchar | 255 | No |  |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_tp_vendors`

Migration sources: `database/migrations/2025_09_05_064512_create_md_tp_vendor_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| vendor_name | varchar | 150 | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `trn_mapping_corporate_tp_vendors`

Migration sources: `database/migrations/2025_09_05_073415_create_trn_mapping_corporate_tp_vendors_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| ref_vendor_id | integer |  | No |  |  |  |  |  |
| ref_corporate_id | integer |  | No |  |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `md_gst_percentages`

Migration sources: `database/migrations/2025_09_15_114353_create_md_gst_percentages_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| name | varchar | 200 | Yes |  |  |  |  |  |
| percentage | integer |  | Yes | 0 |  |  |  |  |
| status | integer |  | No | 0 |  |  |  |  |
| created_at | timestamp |  | Yes |  |  |  |  |  |
| updated_at | timestamp |  | Yes |  |  |  |  |  |
| deleted_at | timestamp |  | Yes |  |  |  |  |  |

Primary key: `id`
Audit / soft delete columns: `created_at`, `updated_at`, `deleted_at`

### `telescope_entries`

Migration sources: `database/migrations/2025_09_29_101735_create_telescope_entries_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sequence | unsignedBigInteger |  | No |  | Yes |  |  | Yes |
| uuid | uuid |  | No |  |  |  |  |  |
| batch_id | uuid |  | No |  |  |  |  |  |
| family_hash | varchar | 255 | Yes |  |  |  |  |  |
| should_display_on_index | boolean |  | No | true |  |  |  |  |
| type | varchar | 20 | No |  |  |  |  |  |
| content | longText |  | No |  |  |  |  |  |
| created_at | dateTime |  | Yes |  |  |  |  |  |

Primary key: `sequence`
Unique constraints: `telescope_entries_uuid_unique` (uuid)
Indexes: `telescope_entries_batch_id_index` (batch_id); `telescope_entries_family_hash_index` (family_hash); `telescope_entries_created_at_index` (created_at); `telescope_entries_type_should_display_on_index_index` (type, should_display_on_index)
Audit / soft delete columns: `created_at`

### `telescope_entries_tags`

Migration sources: `database/migrations/2025_09_29_101735_create_telescope_entries_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| entry_uuid | uuid |  | No |  | Yes | Yes | telescope_entries(uuid) |  |
| tag | varchar | 255 | No |  | Yes |  |  |  |

Primary key: `entry_uuid, tag`
Indexes: `telescope_entries_tags_tag_index` (tag)
Foreign keys: `entry_uuid` -> `telescope_entries`(uuid)

### `telescope_monitoring`

Migration sources: `database/migrations/2025_09_29_101735_create_telescope_entries_table.php`

| Column | Data Type | Length / Precision | Nullable | Default | PK | FK | References | Auto Increment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tag | varchar | 255 | No |  | Yes |  |  |  |

Primary key: `tag`

## Views

| View | Detected Select Columns | Latest Migration |
| --- | --- | --- |
| view_corporate_bufferlists | corporate_id, policy_type, policy_details | database/migrations/2025_02_28_123906_create_view_corporate_bufferlist_table.php |
| master_view_corporate_dashboards | corporate_id, policy_type, policy_details, claim_paid_amount | database/migrations/2025_03_17_153903_create_master_view_corporate_dashboards_table.php |
| view_admindashboards |  | database/migrations/2025_06_11_102752_update_view_admindashboards.php |
| view_corporate_active_employees | employee_code, employee_name, mobile_number, email, status, is_register, is_mail_send, ref_policy_id, is_testuser | database/migrations/2025_06_23_115636_update_view_corporate_active_employees.php |
| view_corporate_reports_agewisereports | corporate_id, policy_type, financial_year, policy_details | database/migrations/2025_07_01_155548_update_view_corporate_reports_agewisereports.php |
| view_corporate_enrollment_listviews | corporate_id, policy_type, financial_year_id, policy_details | database/migrations/2025_07_03_122938_update_view_corporate_enrollment_listviews.php |
| view_corporate_claimdetails | corporate_id, policy_type, financial_year_id, policy_details, claim_paid_amount | database/migrations/2025_07_03_133822_update_view_corporate_claimdetails.php |
| view_escalation_matrices | corporate_id, policy_type, financial_year_id, escalation_matrix | database/migrations/2025_07_03_174508_update_view_escalation_matrices.php |
| view_policy_details | policy_id, corporate_id, status, policy_details, policy_sum_insured, policy_data_upload, policy_escalation_matrix, policy_document, policy_cd_statement, policy_corporate_buffer_transaction, policy_corporate_buffer_account, policy_feature_template, policy_feature_template_values, policy_feature_identifiers | database/migrations/2025_08_07_074043_update_view_policy_details_table.php |
| view_policy_enrollment_details | corporate_id, policy_type, financial_year_id, policy_details | database/migrations/2025_09_17_074337_update_policy_enrollment_details.php |

## Foreign Key Relationships

| Table | Column(s) | Referenced Table | Referenced Column(s) | On Delete | Constraint Name | Migration |
| --- | --- | --- | --- | --- | --- | --- |
| logs | user_id | users | id | cascade |  | database/migrations/2024_12_03_132032_create_logs_table.php |
| log_master_endorsement_calculations_datauploads | ref_policy_id | master_add_policies | id | cascade | fk_log_endorsement_policy | database/migrations/2025_07_09_184444_create_log_master_endorsement_calculations_datauploads_table.php |
| log_endorsement_calculations_dataupload_calculations | ref_policy_id | master_add_policies | id | cascade | fk_log_endorsement_policy | database/migrations/2025_07_09_193852_create_log_endorsement_calculations_dataupload_calculations_table.php |
| master_endorsement_calculations_details | ref_policy_id | master_add_policies | id | cascade | fk_master_endorsement_policy | database/migrations/2025_07_11_210318_create_master_endorsement_calculations_details_table.php |
| master_online_enrollment_notes | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_21_030446_create_master_online_enrollment_notes_table.php |
| master_online_enrollment_employeedetails | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_050925_create_master_online_enrollment_employeedetails_table.php |
| trn_mapping_emp_detail_suminsureds | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_052235_create_trn_emp_detail_suminsureds_table.php |
| master_online_enrollment_gmc_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_053723_create_master_online_enrollment_gmc_policies_table.php |
| trn_mapping_gmc_policies_suminsureds | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_054542_create_trn_mapping_gmc_policies_suminsureds_table.php |
| master_online_enrollment_voluntary_parent_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_055722_create_master_online_enrollment_voluntary_parent_policies_table.php |
| trn_mapping_voluntary_parent_policies_suminsureds | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_060931_create_trn_mapping_voluntary_parent_policies_suminsureds_table.php |
| master_online_enrollment_topup_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_061908_create_master_online_enrollment_topup_policies_table.php |
| trn_mapping_topup_policies_suminsureds | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_062757_create_trn_mapping_voluntary_topup_policies_suminsureds_table.php |
| master_online_enrollment_opd_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_063159_create_master_online_enrollment_opd_policies_table.php |
| trn_mapping_opd_policies_suminsureds | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_063746_create_trn_mapping_voluntary_opd_policies_suminsureds_table.php |
| master_online_enrollment_gpa_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_064114_create_master_online_enrollment_gpa_policies_table.php |
| master_online_enrollment_gtl_policies | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_07_28_064717_create_master_online_enrollment_gtl_policies_table.php |
| master_online_enrollment_escalation_matrices | ref_validationform_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_08_11_134008_create_master_online_enrollment_escalation_matrices_table.php |
| master_online_enrollment_empportal_form_uploads | ref_validation_form_id | master_online_enrollment_validationforms | id | cascade | fk_master_online_enrollment_validationform | database/migrations/2025_08_13_061041_create_master_online_enrollment_empportal_form_uploads_table.php |
| master_online_enrollment_empportal_form_upload_data | ref_empportal_form_uploads_id | master_online_enrollment_empportal_form_uploads | id | cascade | fk_master_online_enrollment_empportal_form_uploads | database/migrations/2025_08_13_201717_create_master_online_enrollment_empportal_form_upload_data_table.php |
| telescope_entries_tags | entry_uuid | telescope_entries | uuid | cascade |  | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |

## Indexes

| Table | Index Name | Type | Column(s) | Migration |
| --- | --- | --- | --- | --- |
| sessions | sessions_user_id_index | index | user_id | database/migrations/0001_01_01_000000_create_users_table.php |
| sessions | sessions_last_activity_index | index | last_activity | database/migrations/0001_01_01_000000_create_users_table.php |
| jobs | jobs_queue_index | index | queue | database/migrations/0001_01_01_000002_create_jobs_table.php |
| oauth_auth_codes | oauth_auth_codes_user_id_index | index | user_id | database/migrations/2024_10_18_035816_create_oauth_auth_codes_table.php |
| oauth_access_tokens | oauth_access_tokens_user_id_index | index | user_id | database/migrations/2024_10_18_035817_create_oauth_access_tokens_table.php |
| oauth_refresh_tokens | oauth_refresh_tokens_access_token_id_index | index | access_token_id | database/migrations/2024_10_18_035818_create_oauth_refresh_tokens_table.php |
| oauth_clients | oauth_clients_user_id_index | index | user_id | database/migrations/2024_10_18_035819_create_oauth_clients_table.php |
| master_cashless_hospital_uploads | mchu_lat_index | index | latitude | database/migrations/2025_09_23_152708_add_lat_lng_to_master_cashless_hospital_uploads_table.php |
| master_cashless_hospital_uploads | mchu_lng_index | index | longitude | database/migrations/2025_09_23_152708_add_lat_lng_to_master_cashless_hospital_uploads_table.php |
| telescope_entries | telescope_entries_batch_id_index | index | batch_id | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |
| telescope_entries | telescope_entries_family_hash_index | index | family_hash | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |
| telescope_entries | telescope_entries_created_at_index | index | created_at | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |
| telescope_entries | telescope_entries_type_should_display_on_index_index | index | type, should_display_on_index | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |
| telescope_entries_tags | telescope_entries_tags_tag_index | index | tag | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |

## Composite Keys and Indexes

| Table | Name | Type | Column(s) |
| --- | --- | --- | --- |
| telescope_entries | telescope_entries_type_should_display_on_index_index | index | type, should_display_on_index |
| telescope_entries_tags | PRIMARY | primary | entry_uuid, tag |

## Unique Constraints

| Table | Constraint / Index | Column(s) | Migration |
| --- | --- | --- | --- |
| failed_jobs | failed_jobs_uuid_unique | uuid | database/migrations/0001_01_01_000002_create_jobs_table.php |
| telescope_entries | telescope_entries_uuid_unique | uuid | database/migrations/2025_09_29_101735_create_telescope_entries_table.php |

## Design Observations and Recommendations

### Missing foreign keys

The following columns look like relationship columns but are not declared as database-level foreign keys. Review these first because they affect referential integrity and delete/update behavior.

| Table | Column | Suggested Reference |
| --- | --- | --- |
| users | ref_corporate_id | master_corporates(corporate_id) |
| sessions | user_id | users(id) |
| oauth_auth_codes | user_id | users(id) |
| oauth_access_tokens | user_id | users(id) |
| oauth_clients | user_id | users(id) |
| mapping_policy_feature_templates_corporates_policies | ref_policy_id | master_add_policies(id) |
| mapping_policy_feature_templates_corporates_policies | ref_policy_feature_template_field_id | master_policy_feature_template_fields(template_field_id) |
| master_policy_feature_templates | ref_policy_id | master_add_policies(id) |
| master_add_policies | ref_md_line_of_businesses_id | md_line_of_businesses(id) |
| master_add_policies | ref_md_policy_types_id | md_policy_types(id) |
| master_add_policies | ref_md_family_definitions_id | md_family_definitions(id) |
| master_add_policies | ref_intimate_claim_visibilities_id | md_intimate_claim_visibilities(id) |
| master_add_policies | ref_corporate_id | master_corporates(corporate_id) |
| master_add_policies | user_id | users(id) |
| master_sum_insureds | ref_policy_id | master_add_policies(id) |
| master_policy_data_uploads | ref_policy_id | master_add_policies(id) |
| master_policy_escalation_matrices | ref_policy_id | master_add_policies(id) |
| master_policy_documents | ref_document_type_id | md_document_types(id) |
| master_policy_documents | ref_document_name_id | md_document_names(id) |
| master_policy_documents | ref_policy_id | master_add_policies(id) |
| master_policy_cd_statements | ref_corporate_id | master_corporates(corporate_id) |
| master_policy_cd_statements | ref_master_cd_accounts_id | master_cd_accounts(id) |
| master_policy_cd_statements | ref_policy_id | master_add_policies(id) |
| master_cd_accounts | ref_corporate_id | master_corporates(corporate_id) |
| master_policy_corporate_buffer_transactions | ref_policy_id | master_add_policies(id) |
| master_policy_corporate_buffer_amounts | ref_corporate_id | master_corporates(corporate_id) |
| master_policy_corporate_buffer_amounts | ref_policy_id | master_add_policies(id) |
| trn_mapping_corporateid_corporatecontactsids | corporate_id | master_corporates(corporate_id) |
| master_cashless_hospitals | ref_corporate_id | master_corporates(corporate_id) |
| master_intimateclaims | ref_corporate_id | master_corporates(corporate_id) |
| master_intimateclaims | ref_policy_id | master_add_policies(id) |
| master_intimateclaims | ref_user_id | users(id) |
| master_intimateclaims | userid | users(id) |
| master_nonlife_claimintimations | ref_corporate_id | master_corporates(corporate_id) |
| master_nonlife_claimintimations | userid | users(id) |
| master_nonlife_claimintimations | ref_policy_id | master_add_policies(id) |
| master_claimsubmissions | ref_corporate_id | master_corporates(corporate_id) |
| master_claimsubmissions | ref_policy_id | master_add_policies(id) |
| master_claimsubmissions | ref_user_id | users(id) |
| master_claimsubmissions | userid | users(id) |
| master_claimsubmission_documents | ref_claimsubmission_id | master_claimsubmissions(id) |
| master_cd_statement_transactions | ref_corporate_id | master_corporates(corporate_id) |
| master_cd_statement_transactions | ref_policy_id | master_add_policies(id) |
| master_inception_data_uploads | ref_policy_id | master_add_policies(id) |
| master_total_claim_reports | ref_policy_id | master_add_policies(id) |
| master_cd_statement_data_uploads | ref_corporate_id | master_corporates(corporate_id) |
| master_intimateclaim_documents | ref_intimateclaim_id | master_intimateclaims(id) |
| master_enrollment_uploads | ref_policy_type_id | md_policy_types(id) |
| master_enrollment_uploads | ref_policy_id | master_add_policies(id) |
| master_enrollment_uploads | ref_enrollment_type_id | md_enrollment_types(id) |
| master_endorsement_data_uploads | ref_policy_id | master_add_policies(id) |
| master_dynamic_templates | ref_user_id | users(id) |
| master_welcome_mailers | ref_corporate_id | master_corporates(corporate_id) |
| master_welcome_mailers | ref_policy_id | master_add_policies(id) |
| master_welcome_mailers | ref_user_id | users(id) |
| master_endorsementcalculation_rackrates | ref_corporate_id | master_corporates(corporate_id) |
| master_endorsementcalculation_rackrates | ref_policy_id | master_add_policies(id) |
| master_endorsementcalculation_rackrates | ref_enrollment_type_id | md_enrollment_types(id) |
| master_endorsementcalculation_rackrates | ref_policy_type_id | md_policy_types(id) |
| master_endorsementcalculation_rackrates | ref_user_id | users(id) |
| master_endorsementcalculation_rackrates_suminsureds | ref_policy_id | master_add_policies(id) |
| master_endorsementcalculation_rackrates_suminsureds | ref_rackrates_suminsured_values_id | master_rackrates_suminsured_values(id) |
| master_rackrates_suminsured_values | ref_policy_id | master_add_policies(id) |
| policyfeature_identifiers | ref_policy_id | master_add_policies(id) |
| master_ecards_data_uploads | ref_policy_id | master_add_policies(id) |
| master_ecards_data_upload_errors | ref_policy_id | master_add_policies(id) |
| trn_mapping_notifications | ref_user_id | users(id) |
| trn_mapping_notifications | ref_policy_id | master_add_policies(id) |
| trn_mapping_notifications | ref_corporate_id | master_corporates(corporate_id) |
| temp_endorsement_calculations_import_data | ref_policy_id | master_add_policies(id) |
| master_endorsement_calculations_details | ref_corporate_id | master_corporates(corporate_id) |
| master_endorsement_calculations_details | ref_policy_types_id | md_policy_types(id) |
| master_endorsement_calculations_details | ref_enrollment_type_id | md_enrollment_types(id) |
| master_online_enrollment_validationforms | ref_corporate_id | master_corporates(corporate_id) |
| master_online_enrollment_validationforms | ref_policy_id | master_add_policies(id) |
| master_nominee_data_uploads | ref_policy_id | master_add_policies(id) |
| master_corporate_edit_employee_uploads | ref_corporate_id | master_corporates(corporate_id) |
| master_log_corporate_edit_employees | ref_corporate_id | master_corporates(corporate_id) |
| master_corporate_edit_employees_upload_errors | ref_corporate_id | master_corporates(corporate_id) |
| trn_mapping_corporate_tp_vendors | ref_corporate_id | master_corporates(corporate_id) |

### Duplicate indexes

No duplicate indexes with identical type and column list were detected in the reconstructed schema.

### Redundant and denormalized columns

- Several transactional tables store both foreign-reference IDs and display labels, for example policy, corporate, insurer, TPA, city, state, and employee names. This may be intentional snapshotting, but if the labels are expected to stay synchronized it creates update anomalies.
- Many upload/error/log tables repeat large employee and policy payloads. That is acceptable for audit/import history, but should be separated from authoritative master data in application logic.
- `status` appears widely as an integer without a common enum/check constraint. Consider a shared status reference table or constrained enum strategy for domain-critical tables.

### Normalization and type consistency

- Numerous date fields are stored as `varchar`/`string` rather than `date` or `datetime`, especially in policy, employee, claim, and upload tables. This limits date validation, indexing, and range queries.
- Monetary and numeric values are often represented as `string`, `double`, or mixed types. Prefer `decimal(precision, scale)` for premiums, balances, GST, and claim amounts.
- Reference columns use mixed integer sizes: many are `integer` while Laravel `id()` creates `unsignedBigInteger`. Align FK candidate columns with the referenced PK type before adding constraints.
- Naming inconsistencies are present, such as `coporate_contact_email`, `staus` renamed to `status`, singular/plural table variants, and both `userid` and `user_id`. Standardizing names will reduce query and model errors.

### Schema consistency recommendations

- Add database-level foreign keys for high-value relationships first: users, corporates, policies, validation forms, and upload parent-child tables.
- Add unique constraints where business keys must be unique, such as master names/codes, policy numbers per corporate/insurer, employee code per corporate, and OTP identity windows if applicable.
- Add indexes on frequent filters and joins after reviewing query plans. Likely candidates include `ref_policy_id`, `ref_corporate_id`, `ref_validationform_id`, `employee_code`, `mobile_no`, and status/date columns used in dashboards.
- Consider splitting import staging/error schemas from operational schemas so temporary upload columns do not blur the core domain model.
