# Corporate Policy CRM Project Analysis

Generated from the provided repository source, migrations, and documents in `F:\Vibe_elixir\Corporate_Policy`. Conclusions below are based only on files present in this workspace. Where behavior was not present in source code, this report states "Not found in provided files".

## Source Coverage

Documents reviewed:
- `AGENTS.md`
- `README.md`
- `structure.md`
- `Add_Policy_Workflow.md`
- `DATABASE_SCHEMA_REPORT.md`
- `dataupload laravel code.txt`
- `tmp_schema.sql`
- `live_vibe_engine_master_policy_feature_template_fields.sql`
- `master_policy_feature_template_fields.csv`
- `priv/repo/migrations/*.exs`
- `priv/repo/seeds/**/*.exs`
- `lib/**/*.ex`
- `test/**/*.exs`

Application stack found:
- Phoenix `~> 1.8.8`, LiveView `~> 1.2.0`, Ecto SQL `~> 3.13`, PostgreSQL via `postgrex`, Swoosh/SMTP, Req, NimbleCSV, Tailwind/esbuild, Heroicons.
- Runtime portals are selected by `PORTAL` env in `CorporatePolicyWeb.Router`.
- Background processing found: `CorporatePolicy.Emails.MailQueue` GenServer for welcome emails.
- PubSub usage: Not found in provided files beyond standard Phoenix endpoint/app setup.

## Architecture Overview

The application is a single Phoenix app with three portal scopes:

| Portal | Scope | Auth | Primary users/roles found |
| --- | --- | --- | --- |
| Admin | `/admin` | email/password via `users` | Admin users. Exact role table/permission model not fully found; admin auth only checks a session user id. |
| Corporate | `/corporate` | email/password via `users` | Corporate contacts where `ref_corporate_id` exists and `department_id` is not in `[1, 3, 9]`. |
| Employee | `/employee` | mobile OTP | Active employee/self records from `trn_mapping_live_employees`. OTP is hardcoded to `123456`. |
| API | `/api` | no auth pipeline found | Visibility role lookup endpoint. |

Phoenix layers:
- Router: `lib/corporate_policy_web/router.ex`
- Portal LiveViews: `lib/corporate_policy_web/admin/live`, `corporate/live`, `employee/live`
- Shared LiveViews/components: claim submission modules at `lib/corporate_policy_web/claim_submission_*`, `components/claim_submission_components.ex`
- Contexts: `Accounts`, `Corporates`, `Policies`, `Claims`, `CdStatements`, `EmployeePortal`, `EscalationMatrices`, `DataUploadService`, `Emails`
- Schemas: under `lib/corporate_policy/**`
- Migrations: `priv/repo/migrations`

## Feature Dependency Map

```text
Router
├─ Admin Portal
│  ├─ SessionController -> Accounts -> User/Password
│  ├─ DashboardLive -> Corporates counts
│  ├─ CorporateLive/New/Edit -> Corporates -> master_corporates, users, contact mappings, logos, locations, email queue
│  ├─ PolicyDetailsLive/AddPolicyLive
│  │  ├─ Step1 -> Policies -> master_add_policies + metadata tables
│  │  ├─ Step2 -> Policies/Corporates -> feature template mappings + visibility roles
│  │  ├─ Step3 -> Policies -> master_sum_insureds
│  │  ├─ Step4 -> DataUploadService -> upload/data dump/live employee tables
│  │  ├─ Step5 -> EscalationMatrices + master_policy_escalation_matrices
│  │  ├─ Step6 -> master_policy_documents
│  │  └─ Step7/CD -> CdStatements -> CD accounts/uploads/rows/errors
│  ├─ EscalationMatrix* -> EscalationMatrices -> master_escalation_matrices
│  ├─ ClaimsSubmission* -> shared Claims LiveViews -> Claims context
│  └─ Export controllers -> CSV from contexts
├─ Corporate Portal
│  ├─ SessionController -> Accounts
│  ├─ Dashboard -> Policies/Corporates
│  ├─ EnrollmentDetails -> Policies -> live employee/inception/endorsement tables
│  ├─ PolicyFeatures -> Policies -> feature mappings + sum insured
│  ├─ Documents -> Policies -> master_policy_documents
│  ├─ EscalationMatrix -> Policies -> master_policy_escalation_matrices + master_escalation_matrices
│  ├─ Claims -> Policies -> master_total_claim_reports
│  └─ ClaimSubmission* -> shared Claims LiveViews -> Claims context
└─ Employee Portal
   ├─ EmployeeSessionController -> EmployeePortal -> trn_mapping_live_employees
   ├─ Dashboard/Members/ContactMatrix -> EmployeePortal
   ├─ Coverages -> EmployeePortal + Policies feature mappings
   └─ ClaimSubmission* -> shared Claims LiveViews scoped to employee policy/code
```

## Database Relationship Map

```text
users
├─ referenced by created_by/updated_by in policy, document, CD, sum insured, metadata tables
├─ corporate contacts mapped by trn_mapping_corporateid_corporatecontactsids
└─ email logs in trn_mapping_corporate_contact_email_logs

master_corporates
├─ has logo via ref_master_corporate_logos_id -> master_logos.logo_id
├─ location ids -> md_pincodes/md_cities/md_states via mapping table lookup
├─ has policies in master_add_policies.ref_corporate_id
└─ has employees in trn_mapping_live_employees.ref_corporate_id

master_add_policies
├─ references corporate, LOB, policy type, insurer, TPA, family definition, claim visibility, FY, sum insured type
├─ has feature mappings in mapping_policy_feature_templates_corporates_policies
├─ has sum insureds in master_sum_insureds
├─ has policy uploads in master_policy_data_uploads
├─ has inception rows in master_inception_data_uploads
├─ has endorsement rows in master_endorsement_data_uploads
├─ has live members in trn_mapping_live_employees
├─ has ecard rows in master_ecards_data_uploads
├─ has total claim reports in master_total_claim_reports
├─ has escalation mappings in master_policy_escalation_matrices
├─ has documents in master_policy_documents
├─ has CD uploads in master_policy_cd_statements and ledger rows in master_cd_statement_data_uploads
└─ has submitted claims in master_claim_submission

master_claim_submission
├─ belongs to master_add_policies via ref_policy_id
├─ has documents in master_claim_submission_documents
└─ has audit logs in trp_claim_submission_logs

master_policy_cd_statements
├─ has ledger rows in master_cd_statement_data_uploads
└─ has import errors in master_cdstatement_upload_errors
```

Not found in provided files:
- A complete Ecto schema for `mapping_policy_completions`; it is accessed by raw table name from CD statements.
- A formal roles/permissions table that gates all admin features.

## End-to-End Workflow Diagram

```text
User opens portal URL
-> Router checks PORTAL environment gate
-> Browser pipeline loads session/flash/CSRF/security headers
-> Portal auth plug checks session
-> Controller login or LiveView mount
-> LiveAuth assigns current user/current employee
-> LiveView loads context data through Ecto queries
-> User submits event/form/upload
-> LiveView handle_event validates params and calls context
-> Context builds changeset or transaction
-> Repo reads/writes PostgreSQL tables
-> Context returns {:ok, data} or {:error, changeset/message}
-> LiveView assigns data/flash or redirects
-> Browser receives patched LiveView DOM or HTTP CSV/JSON response
```

## Request -> Business Logic -> Database -> Response Flow

```text
Admin login POST /admin/login
-> Accounts.authenticate_user(email, password)
-> users lookup by email_address + password verification
-> session current_user_id set
-> redirect /admin/dashboard

Corporate creation LiveView submit
-> CorporateNewLive handle_event("save", action)
-> Corporates.create_corporate + save_contacts
-> master_logos, master_corporates, users, trn_mapping_corporateid_corporatecontactsids
-> MailQueue queues welcome email; logs in trn_mapping_corporate_contact_email_logs
-> flash/redirect

Add policy wizard
-> AddPolicyLive mounts Step components
-> Step1 creates/updates master_add_policies
-> Step2 maps template fields to policy
-> Step3 stores sum insured slabs
-> Step4 parses uploaded CSV/XLS-like CSV data
-> Step5 stores policy escalation mappings
-> Step6 stores policy documents
-> Step7 imports CD ledger rows and marks section completion
-> policy status finalized through Policies.finalize_policy_status

Employee login
-> POST /employee/login action request_otp
-> EmployeePortal.eligible_employee_by_mobile
-> trn_mapping_live_employees active Employee/Self lookup
-> OTP session fields stored
-> POST /employee/login action login
-> OTP and expiry checked
-> current_employee_id session set
-> redirect /employee/dashboard

Claim submission
-> shared ClaimSubmissionFormLive creates/updates draft
-> Claims.create_claim/update_claim
-> master_claim_submission + trp_claim_submission_logs
-> document upload writes master_claim_submission_documents
-> submit requires at least 3 active documents
-> claim_status changes to Submitted, submitted_at/submitted_by set
```

## Feature Analysis

### Authentication and Sessions

Purpose: Allow Admin and Corporate contacts to log in using `users.email_address` and password; allow employees to log in using mobile OTP.

Business objective: restrict portal access and personalize data by session user or employee.

Users/Roles:
- Admin: no explicit role check found in Admin session controller/auth plug.
- Corporate: user must have `ref_corporate_id` and `department_id not in [1, 3, 9]`.
- Employee: active employee/self member with mapped mobile number.

Workflow:
- Admin/Corporate login posts credentials, `Accounts.authenticate_user/2` fetches by email and verifies password.
- Employee login has two actions: `request_otp` and `login`.
- LiveAuth modules load the current session identity before LiveViews render.

Business logic:
- Admin accepts any authenticated `users` row. Additional admin role rule: Not found in provided files.
- Corporate rejects some department IDs.
- Employee OTP expires after 5 minutes and is stored in session.
- Employee OTP value is hardcoded to `123456`.

Validation:
- User email format validates with `~r/^[^\s]+@[^\s]+$/`.
- Employee mobile must normalize to exactly 10 digits.

Potential issues:
- Employee OTP is a fixed default value; this is a security risk.
- Admin auth has no role/department gate in the provided files.
- API scope has no authentication.

### Corporate Master Management

Modules/pages:
- `CorporatePolicyWeb.Admin.CorporateLive`
- `CorporatePolicyWeb.Admin.CorporateNewLive`
- `CorporatePolicyWeb.Admin.CorporateEditLive`
- `CorporatePolicyWeb.Admin.CorporateExportController`
- `CorporatePolicy.Corporates`
- Schemas: `Corporate`, `Logo`, `TrnMappingCorporateContact`, `ContactEmailLog`, location schemas.

Purpose: create, list, edit, export corporate organizations and their portal contacts.

Workflow:
- List page loads paginated corporates, 15 per page, optionally active/inactive.
- New/Edit wizard validates corporate details, resolves pincode into city/state ids, uploads logo if provided, then stores corporate.
- Contacts are saved as `users`, linked through `trn_mapping_corporateid_corporatecontactsids`, and welcome emails are queued.
- Removed contacts are soft-deleted by setting mapping/user `status: 0` and `deleted_at`.

Business rules:
- Corporate group code is generated as a unique 6-character uppercase alphanumeric value.
- Blank contact rows are skipped.
- Single-word contact names get last name `"User"`.
- Missing contact names default internally to `"Contact User"` when partial contact data is present.
- Soft-deleted users with same email may be reactivated.
- Department dropdown lists visibility role rows where `is_visible == 2`.

Validation:
- Corporate required fields: `corporate_name`, `corporate_address`, `pincode`, `city`, `state`, `pan_number`.
- PAN format must match `^[A-Z]{5}[0-9]{4}[A-Z]{1}$`.
- Pincode max length 10, city/state max 25, PAN max 15.
- Contact user requires first name, last name, email, password at user changeset level.

Tables:
- `master_corporates`, `master_logos`, `users`, `trn_mapping_corporateid_corporatecontactsids`, `trn_mapping_corporate_contact_email_logs`, `md_cities`, `md_states`, `md_pincodes`, `trn_mapping_pincode_city_states`, `md_visibility_role_id_feature_tmps`.

Potential issues:
- Some contact insert/update paths use generated plaintext password in email.
- Corporate user permissions are inferred from department id exclusions, not a named role model.
- `list_contacts_for_corporate` uses raw table joins instead of schema associations.

### Policy Master and Add Policy Wizard

Modules/pages:
- `Admin.PolicyDetailsLive`, `Admin.PolicyLive`, `Admin.AddPolicyLive`
- Step components 1 through 7
- `CorporatePolicy.Policies`, `CorporatePolicy.DataUploadService`, `CorporatePolicy.CdStatements`

Purpose: create policy records and progressively attach features, sums insured, employee/member files, escalation contacts, documents, and CD statements.

Workflow:
- `AddPolicyLive.mount/3` determines new/edit mode and current step.
- Step 1 writes policy core fields.
- Step 2 writes feature mapping rows.
- Step 3 writes sum insured values.
- Step 4 imports data upload files.
- Step 5 stores escalation contact mappings.
- Step 6 stores documents.
- Step 7 lists/deletes/imports CD statement rows.
- Child components notify parent with `{:step_completed, step, policy}`.

Policy business rules:
- Financial year is calculated from `policy_start_date` using April-March cycle.
- Initial status from create:
  - no end date -> `2`
  - expired end date -> `3`
  - otherwise -> `2`
- Final status:
  - expired -> `3`
  - required core fields complete -> `1`
  - otherwise -> `0`
- Required completion fields: corporate name, line of business id, policy type id, insurer id, policy number, start date, end date.
- Policy template id maps from policy type:
  - GMC -> 1
  - GPA -> 2
  - Parent Policy -> 3
  - Top up Policy -> 4
  - GTL -> 5
  - Marine -> 6
  - Fire -> 7
  - Office Package -> 8
  - fallback -> 1

Validation:
- Policy required fields include corporate, line of business, policy type, insurer, have policy number, start/end date, status.
- `status` must be one of `[0, 1, 2, 3]`.
- `have_policy_number` must be `[0, 1]`.
- Conditional requirements:
  - If policy type is GMC/Parent Policy/Top up Policy, family definition is required.
  - If sum insured type is used, sum insured type id is required.

Tables:
- `master_add_policies`, `md_line_of_businesses`, `md_policy_types`, `md_insurer_lists`, `md_policy_tpas`, `md_family_definitions`, `md_intimate_claim_visibilities`, `md_financial_years`, `md_sum_insured_types`.
- Wizard tables: `master_policy_feature_templates`, `master_policy_feature_template_fields`, `mapping_policy_feature_templates_corporates_policies`, `master_sum_insureds`, `master_policy_data_uploads`, `master_policy_escalation_matrices`, `master_policy_documents`, `master_policy_cd_statements`.

Potential issues:
- Some wizard step components perform direct `Repo` operations instead of using context functions consistently.
- `mapping_policy_completions` is used by name but no schema was found.
- Policy status codes are not backed by an enum module.

### Data Uploads, Enrollment, Endorsements, Ecards, Claim Dumps

Modules:
- `Admin.Step4DataUploadComponent`
- `CorporatePolicy.DataUploadService`
- Corporate enrollment views and export controllers

Purpose: upload policy-related data files and convert them into normalized member, endorsement, claim report, or ecard rows.

Workflow:
- Step 4 accepts file upload and `data_type`.
- `process_upload/6` inserts `master_policy_data_uploads`.
- File processing branches by data type:
  - `"Inception Data"` -> `master_inception_data_uploads` and live employee upsert.
  - `"Endorsement Data"` -> `master_endorsement_data_uploads` and live employee upsert/deactivation.
  - `"Claim Dumps"` -> `master_total_claim_reports`.
  - `"Ecards"` -> `master_ecards_data_uploads`.

Business rules:
- Supported endorsement types normalize to `employee_addition`, `dependent_addition`, `employee_deletion`, `dependent_deletion`.
- Invalid endorsement type raises and aborts upload transaction.
- Relationship is mandatory; `"self"` and `"employee"` normalize to `"Employee"`.
- Dependent deletion cannot delete a primary employee/self record.
- Deletion deactivates matching inception/live employee rows and logs deletion.
- Live employee upsert conflict target is `[:ref_policy_id, :employee_code, :relationship]`.

Validation:
- CSV rows are padded to expected minimum columns.
- Numeric parsing failures produce nil rather than row-level validation errors for several fields.
- Relationship missing raises an exception.

Tables:
- `master_policy_data_uploads`, `master_inception_data_uploads`, `master_endorsement_data_uploads`, `master_total_claim_reports`, `master_ecards_data_uploads`, `trn_mapping_live_employees`, `trn_endorsement_deletion_logs`.

Potential issues:
- Row validation is uneven; several bad numeric/date values become nil.
- Upload errors for Step 4 are exception-driven rather than collected row-by-row.

### Corporate Portal Dashboard, Enrollment, Policy Features, Documents, Escalation, Claims

Purpose: let corporate contacts view only their corporate policies, employees, dependents, policy features, documents, escalation matrix, and claims report data.

Workflow:
- Corporate LiveViews load `current_user.ref_corporate_id`.
- Policies are fetched with `Policies.list_active_policies_by_corporate/2`.
- Users select FY, policy type, policy number, doc type, list tab, or filters.
- LiveViews re-query context functions and reassign paginated datasets.

Business rules:
- Corporate pages filter policy options by the logged-in user's corporate.
- Enrollment counts split active employees and dependents.
- List view tabs are active, inception, addition, deletion.
- Endorsement addition/deletion views deduplicate records and cancel out matching addition+deletion pairs by employee code and relationship.
- Claims summary buckets statuses by string matching paid/settled, process/pending, and closed/rejected.

Validation:
- Pagination normalizes page to a positive integer.
- Search filters trim and downcase.
- Export endpoints require policy id in params; finer auth checks in controllers are limited in provided files.

Tables:
- Reads `master_add_policies`, live employee/upload tables, `mapping_policy_feature_templates_corporates_policies`, `master_sum_insureds`, `master_policy_documents`, `master_policy_escalation_matrices`, `master_escalation_matrices`, `master_total_claim_reports`.

Potential issues:
- Some exports rely on params and session without strong cross-checks shown in every controller.
- Several Corporate LiveViews duplicate policy selection helper logic.

### Employee Portal

Modules/pages:
- `EmployeeSessionController`
- `EmployeePortal`
- `Employee.DashboardLive`, `MembersLive`, `CoveragesLive`, `ContactMatrixLive`, `ComingSoonLive`
- Employee claim submission wrappers

Purpose: let employees authenticate by mobile OTP and view their own policy coverage, family members, contact matrix, and submit claims.

Workflow:
- Employee requests OTP using mobile number.
- Eligible employee/self member is looked up from active live employees.
- Login checks OTP expiry and loads a `SessionEmployee`.
- Portal pages use `EmployeePortal.list_policies_for_employee/1`, `list_members/1`, `list_policy_feature_cards/1`, and `list_contact_matrix/1`.

Business rules:
- Eligible relationships: `"Employee"` and `"Self"`.
- Active policy list includes policies with status in `[1, 2]`.
- Policy priority sort: GMC, GPA, Parent Policy, Top up Policy, GTL, then others.
- Member listing includes all relations for the employee code under selected policy.

Validation:
- Mobile must be 10 digits.
- OTP must match session value and be unexpired.

Potential issues:
- OTP delivery is logged only; real SMS integration not found.
- Fixed OTP is exposed in flash text.

### Claim Submission

Modules/pages:
- Shared `ClaimSubmissionIndexLive`, `ClaimSubmissionFormLive`, `ClaimSubmissionComponents`
- Portal wrappers in Admin/Corporate/Employee
- Export controllers in all portals
- `CorporatePolicy.Claims`

Purpose: create, edit, document, submit, list, and export claim submissions across portals with portal-specific access scoping.

Workflow:
- Index lists claims for current user/portal with search, status, sort, pagination.
- Form loads accessible corporates/policies/employees/patients.
- Draft claim is created/updated in `master_claim_submission`.
- Document upload creates `master_claim_submission_documents` and logs the action.
- Submit requires minimum documents; then status becomes `"Submitted"` with timestamp.
- Exports generate CSV.

Business rules:
- Portal ids: admin `1`, corporate `2`, employee `3`.
- Claim statuses: Draft, Submitted, Under Review, Approved, Rejected.
- Minimum documents before submit: 3.
- Max upload size: 8 MB.
- Allowed extensions: `.pdf`, `.png`, `.jpg`, `.jpeg`.
- Employee claims must belong to an employee-accessible policy, corporate id, employee code, and covered patient.
- On update, locked fields cannot be changed: `ref_corporate_id`, `ref_policy_id`, `employee_code`, `patient_name`, `estimated_amount`.
- Claims create generated references `CLM-...` and `INT-...`.

Validation:
- Required create fields include policy/corporate, portal, employee code/name, patient, relationship, amount, claim reason/type, hospital, hospitalization date, city/state/pincode.
- Estimated amount must be greater than 0.
- Claim reason max 500; hospital address max 1000.
- Claim number and intimation number unique constraints.
- Document requires claim, document name, original file name, file path, mime type, file size; file size > 0.

Tables:
- `master_claim_submission`, `master_claim_submission_documents`, `trp_claim_submission_logs`, `master_add_policies`, `trn_mapping_live_employees`.

Potential issues:
- Admin listing is scoped to portal id 1 only, so admin-created claims are listed, not all portal claims, based on current `accessible_to/3`.
- File type/size is configured in LiveView upload, but server-side MIME/extension validation in schema is limited.

### Escalation Matrix

Modules/pages:
- Admin master pages: `EscalationMatrixMasterLive`, `EscalationMatrixAddLive`
- Policy step 5: `Step5EscalationComponent`
- Corporate/Employee contact matrix views
- `CorporatePolicy.EscalationMatrices`

Purpose: maintain master escalation contacts and attach them to policies by escalation level.

Workflow:
- Admin creates/edits/deletes master users.
- Delete is soft delete via `deleted_at`.
- Policy step 5 maps master contacts to policy levels.
- Corporate/Employee views read policy-specific contact matrix.

Business rules:
- Master required fields: fullname, mobile number, email id.
- Soft-deleted master records are excluded.
- Policy contact matrix orders by escalation level then id.

Validation:
- fullname max 150.
- phone/mobile max 15.
- email/alt email max 50 and valid email format.
- type max 30.

Tables:
- `master_escalation_matrices`, `master_policy_escalation_matrices`.

Potential issues:
- Delete confirmation exists in LiveView for master list.
- Role/type semantics are not fully defined in provided files.

### CD Accounts and CD Statements

Modules/pages:
- `Admin.CdAccountsLive`
- `Admin.CdStatementUploadLive`
- `Admin.CdStatementExportController`
- `Admin.Step7CDStatementsComponent`
- `CorporatePolicy.CdStatements`

Purpose: manage CD account numbers and import/export policy CD statement ledger rows.

Workflow:
- CD account create requires corporate, policy, and CD number.
- Account is linked to corporate/policy/insurer details from selected policy.
- CD statement upload validates required CSV headers exactly.
- Valid rows go into `master_cd_statement_data_uploads`; invalid rows go into `master_cdstatement_upload_errors`.
- Upload status is `1` when no errors, `2` when errors, initially `0`.
- Step 7 can list, sort, search, paginate, export, and soft-delete rows.

Business rules:
- Required CD CSV headers: particular, transaction_type, employee_count, dependant_count, policy_endorsement_no, endorsement_issued_date, debit_amount, credit_amount, bank_name, cheque_no, policy_number, remark.
- `policy_number` in each row must match current policy.
- CD number must exist for selected corporate.
- Duplicate CD number per corporate and policy is rejected.
- Successful clean upload marks section 7 complete in `mapping_policy_completions`.

Validation:
- Required row fields: particular, transaction_type, policy_number.
- Employee/dependant counts must be integers if provided.
- Debit/credit must be numeric if provided.
- Endorsement issued date must match DD-MM-YYYY or DD/MM/YYYY if provided.
- Policy number format `^[A-Za-z0-9\-\/]+$`.

Tables:
- `master_cd_accounts`, `master_policy_cd_statements`, `master_cd_statement_data_uploads`, `master_cdstatement_upload_errors`, `mapping_policy_completions`.

Potential issues:
- Header matching is strict on order and normalized names.
- `mapping_policy_completions` is raw SQL/table access with no schema found.

### Exports and API

Exports found:
- Admin corporates CSV.
- Admin escalation matrix CSV.
- Admin/Corporate/Employee claim submission CSV.
- Admin total claim reported CSV.
- Corporate enrollment/list view CSV.
- Corporate total claim report CSV.
- Admin CD statement CSV.

API:
- `GET /api/get_visibility_role_id_tempalte`
- Response: `%{role_id: role_data}` where `role_data` is from `Corporates.list_visibility_roles/0`.
- Authentication/authorization: Not found in provided files.
- Typo in route name `tempalte` appears in provided router.

## Database Tables and Migrations

Core tables found through schemas/migrations:

| Table | Main purpose | Key migrations found |
| --- | --- | --- |
| `users` | Portal user accounts/corporate contacts | `20260708104739`, user alteration migrations |
| `master_corporates` | Corporate master | `20260710112530`, status alteration |
| `master_logos` | Logo file records | `20260710112514` |
| `trn_mapping_corporateid_corporatecontactsids` | Corporate-contact mapping | `20260713074704` |
| `trn_mapping_corporate_contact_email_logs` | Welcome email send/failure log | `20260715144521` |
| `md_cities`, `md_states`, `md_pincodes`, `trn_mapping_pincode_city_states` | Location metadata | `20260714182730` |
| `md_visibility_role_id_feature_tmps` | Visibility roles/departments | `20260715070345`, `20260716150000` |
| `master_add_policies` | Policy master | `20260713123831`, `20260714120000` |
| `md_line_of_businesses`, `md_policy_types`, `md_insurer_lists`, `md_policy_tpas`, `md_family_definitions`, `md_intimate_claim_visibilities`, `md_financial_years`, `md_sum_insured_types` | Policy metadata | policy metadata migrations |
| `master_policy_feature_templates`, `master_policy_feature_template_fields` | Dynamic feature field definitions | `20260717170002`, `20260723103803` |
| `mapping_policy_feature_templates_corporates_policies` | Policy-specific feature values | `20260717170004` |
| `master_sum_insureds` | Sum insured rows | `20260715160000` |
| `master_policy_data_uploads` | Uploaded data file metadata | `20260715170000` |
| `master_inception_data_uploads` | Inception member rows | `20260716140000` |
| `master_endorsement_data_uploads` | Endorsement rows | `20260716140100` |
| `trn_mapping_live_employees` | Current active/inactive member state | `20260720185000` |
| `trn_endorsement_deletion_logs` | Endorsement deletion audit | `20260720193000`, `20260721102305` |
| `master_ecards_data_uploads` | Ecard files | `20260716140300` |
| `master_total_claim_reports` | TPA/claim dump reports | `20260716140200` |
| `master_escalation_matrices` | Master escalation contacts | `20260716114328` |
| `master_policy_escalation_matrices` | Policy escalation contacts | `20260715180000` |
| `master_policy_documents` | Policy/service documents | `20260715190000` |
| `master_policy_cd_statements` | CD statement upload metadata | `20260715200000`, `20260721193002` |
| `master_cd_accounts` | CD account master | `20260721193001` |
| `master_cd_statement_data_uploads` | CD ledger rows | `20260721193003` |
| `master_cdstatement_upload_errors` | CD import validation errors | `20260721193004` |
| `master_claim_submission` | Claim submission header | `20260720195000`, claim alteration migrations |
| `master_claim_submission_documents` | Claim documents | `20260720195000` |
| `trp_claim_submission_logs` | Claim audit log | `20260720195000`, `20260721082527`, `20260721085227` |

Indexes explicitly found:
- `trn_mapping_pincode_city_states`: pincode_id, city_id, state_id.
- `trn_mapping_corporate_contact_email_logs`: user_id.
- `trn_endorsement_deletion_logs`: upload_id.
- `master_policy_feature_template_fields`: ref_template_id.
- More constraints/indexes may exist in migration bodies not summarized here; see `priv/repo/migrations`.

## CRUD Matrix

| Feature | Create | Read | Update | Delete |
| --- | --- | --- | --- | --- |
| Users/contacts | `Accounts.create_user`, `Corporates.save_contacts` | `Accounts.get_user`, contact list | `Corporates.update_contacts` | soft delete users/mappings |
| Corporate | `Corporates.create_corporate` | list/get paginated | `update_corporate` | Not found in provided files |
| Policy | `Policies.create_policy/create_or_update_policy` | list/get/preload/stats | `update_policy/update_policy_status` | `delete_policy` exists; UI delete behavior limited |
| Feature mappings | `create_mapped_feature` | list/get mapped details | `update_mapped_feature` | soft delete via `delete_mapped_feature` |
| Sum insured | Step3 direct/context-related operations | list for policy | found in component logic | removal in component |
| Data uploads | `DataUploadService.process_upload` | upload lists | Not found in provided files | Not found in provided files |
| Live employees | upsert from uploads | corporate/employee listing | deactivation from deletion uploads | soft delete/deactivate |
| Escalation master | create | list/get paginated | update | soft delete |
| Policy documents | Step6 upload/store | list documents | Not found in provided files | soft remove in component |
| CD accounts | create | list/paginate | Not found in provided files | Not found in provided files |
| CD statements | upload/import | list/search/sort/export/errors | status updates during import | soft delete row |
| Claims | create draft | list/get/export | update/submit | soft delete document; claim delete not found |

## Dependencies

Internal dependencies:
- `Accounts` depends on `User`, `Password`, `Repo`.
- `Corporates` depends on corporate schemas, `Accounts.User`, `Emails.MailQueue`, location metadata.
- `Policies` depends on policy metadata schemas, upload schemas, feature mappings, escalation, documents, total claim report, CSV.
- `Claims` depends on claims schemas, `Policies`, live employees, `Corporates`, `StringUtils`.
- `EmployeePortal` depends on live employees, policy master, feature mappings, escalation matrices.
- `CdStatements` depends on policy master, CD schemas, CSV parser, raw `mapping_policy_completions`.
- `DataUploadService` depends on upload schemas, live employees, endorsement deletion logs, NimbleCSV.
- `Emails.MailQueue` depends on `Emails`, `Mailer`, `Corporates`.

External dependencies/services:
- PostgreSQL through Ecto/Postgrex.
- Swoosh/SMTP for welcome email delivery.
- NimbleCSV for CSV parsing and generation.
- Phoenix LiveView for UI events/uploads.
- Real SMS provider: Not found in provided files.
- External HTTP API via Req: dependency exists, usage not found in provided files.

## Business Rule Checklist

- [ ] Admin portal is gated by session only; explicit admin role rule not found.
- [ ] Corporate user requires `ref_corporate_id` and department not in `[1, 3, 9]`.
- [ ] Employee login requires active live employee/self member and 10-digit mobile.
- [ ] Employee OTP expires in 5 minutes.
- [ ] Employee OTP is fixed as `123456`.
- [ ] Corporate required fields are name, address, pincode, city, state, PAN.
- [ ] Corporate PAN must match Indian PAN format.
- [ ] Corporate group code must be unique and 6 uppercase alphanumeric chars.
- [ ] Blank corporate contact rows are skipped.
- [ ] Removed corporate contacts are soft-deleted.
- [ ] Soft-deleted users can be reactivated by email.
- [ ] Welcome email is queued for newly created/reactivated contacts.
- [ ] Policy financial year is April 1 to March 31 based on start date.
- [ ] Policy status finalizes to expired, active, or draft/incomplete based on dates and required fields.
- [ ] Policy core completion requires corporate, LOB, policy type, insurer, policy number, start date, end date.
- [ ] Policy type maps to feature template id with fallback template id 1.
- [ ] Feature mappings are policy-specific and soft-deletable.
- [ ] Sum insured must be greater than 0.
- [ ] Inception data creates inception rows and live employee rows.
- [ ] Endorsement data supports only four normalized endorsement types.
- [ ] Missing relationship in upload aborts processing.
- [ ] Dependent deletion cannot delete primary employee/self.
- [ ] Deletion endorsements deactivate existing member rows and create deletion logs.
- [ ] Corporate portal policy lists are filtered by current user's corporate.
- [ ] Corporate enrollment has active, inception, addition, and deletion tabs.
- [ ] Addition/deletion tabs cancel matching addition/deletion pairs by employee code and relationship.
- [ ] Claim submission portal ids are Admin=1, Corporate=2, Employee=3.
- [ ] Claim statuses are Draft, Submitted, Under Review, Approved, Rejected.
- [ ] Claim submit requires at least 3 active documents.
- [ ] Claim uploads allow `.pdf`, `.png`, `.jpg`, `.jpeg` with max size 8 MB at LiveView upload config.
- [ ] Employee claims must match employee policy, corporate, employee code, and covered patient.
- [ ] Claim updates lock corporate, policy, employee code, patient name, and estimated amount.
- [ ] CD account duplicate corporate-policy-CD-number combination is rejected.
- [ ] CD import requires exact header list and matching policy number.
- [ ] CD import valid rows save to ledger table; invalid rows save to error table.
- [ ] CD clean import marks section 7 complete and finalizes policy status.
- [ ] Master escalation matrix records are soft-deleted with `deleted_at`.
- [ ] API visibility role endpoint has no auth found.

## Potential Issues and Refactoring Opportunities

1. Security: employee OTP is hardcoded and disclosed in flash.
2. Security: Admin authentication lacks an explicit admin role/permission gate in provided files.
3. Security: `/api/get_visibility_role_id_tempalte` is unauthenticated.
4. Security: plaintext temporary passwords are emailed to corporate contacts.
5. Authorization: some export controllers should be reviewed for corporate/policy ownership enforcement.
6. Consistency: policy wizard components mix context calls with direct Repo/table operations.
7. Consistency: raw table access is used for contact mappings and policy completions where schemas would clarify contracts.
8. Validation: data upload import validation is uneven; many parse failures become nil.
9. Maintainability: policy selection helper code is duplicated across corporate LiveViews.
10. Maintainability: status codes are scattered as integers/strings; enum modules or typed constants would reduce ambiguity.
11. Naming: route `get_visibility_role_id_tempalte` contains a typo.
12. Observability: no PubSub or job retry/backoff for mail queue found.

## Summary

This project is a multi-portal insurance/corporate policy CRM. Admin users manage corporates, policies, policy features, uploads, escalation contacts, documents, CD statements, and claim submissions. Corporate users view their organization-specific policies, enrollment/member data, policy features, documents, contacts, and claim reports. Employees authenticate by mobile OTP and view their own policies, members, coverages, contacts, and claims.

The central domain is `master_add_policies`; most operational data hangs from it: feature values, sum insured rows, uploaded member/claim data, live employee state, documents, escalation matrix, CD statements, and claim submissions. The application is mostly context-driven, but several LiveComponents still do direct database writes.

Future enhancements suggested by the provided source:
- Replace fixed OTP with real SMS delivery and hashed, expiring OTP records.
- Add explicit role/permission authorization for Admin and API access.
- Consolidate policy selection/filtering into shared helpers.
- Move direct Repo operations from LiveComponents into context functions.
- Add schema/context around `mapping_policy_completions`.
- Add row-level validation/error reporting for all data upload types.
- Strengthen export authorization checks.
