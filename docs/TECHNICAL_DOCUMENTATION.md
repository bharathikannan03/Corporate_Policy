# CorporatePolicy CRM Technical Documentation

Generated from the Phoenix/LiveView implementation, migrations, seed files, and functional/specification documents in this repository.

⚠️ Clarification needed: the functional specification uses a legacy namespace style such as `CRM.Corporates`; this project is implemented as `CorporatePolicy.*` and `CorporatePolicyWeb.*`. All module names below use the actual codebase namespace.

⚠️ Clarification needed: the legacy spec states policy statuses as `1 = Live`, `2 = Draft`, `3 = Expired`, but the implemented `CorporatePolicy.Policies.Policy` uses `0 = Draft`, `1 = Active`, `2 = Inactive`, `3 = Expired`. This document treats the Elixir implementation as authoritative.

## CorporatePolicy.Accounts

### Context & Module Structure

- Context: `CorporatePolicy.Accounts`
- Context file: `lib/corporate_policy/accounts.ex`
- Schemas:
  - `CorporatePolicy.Accounts.User` at `lib/corporate_policy/accounts/user.ex`
  - `CorporatePolicy.Accounts.Password` at `lib/corporate_policy/accounts/password.ex`
- Portal integrations:
  - Admin session controller: `lib/corporate_policy_web/admin/controllers/session_controller.ex`
  - Corporate session controller: `lib/corporate_policy_web/corporate/controllers/corporate_session_controller.ex`
  - Employee OTP auth is separate in `CorporatePolicy.EmployeePortal`.

### Ecto Schema

```elixir
schema "users" do
  field :first_name, :string
  field :last_name, :string
  field :email_address, :string
  field :password, :string
  field :status, :integer, default: 0
  field :remember_token, :string
  field :deleted_at, :utc_datetime_usec
  field :full_name, :string
  field :mobile_no, :string
  field :corporate_username, :string
  field :department_name, :string
  field :location, :string
  field :department_id, :integer
  field :ref_corporate_id, :integer

  timestamps(type: :utc_datetime_usec)
end
```

Associations are currently stored as integer columns in `users`; the schema does not declare `belongs_to` for corporate or department.

### Changesets & Validations

```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [
    :first_name,
    :last_name,
    :full_name,
    :mobile_no,
    :email_address,
    :password,
    :status,
    :corporate_username,
    :department_name,
    :location,
    :department_id,
    :ref_corporate_id
  ])
  |> validate_required([:first_name, :last_name, :email_address, :password])
  |> validate_format(:email_address, ~r/^[^\s]+@[^\s]+$/)
  |> unique_constraint(:email_address)
  |> put_password_hash()
end
```

### Business Logic Functions

- `list_users/0`: returns all `users`.
- `get_user/1`: loads one user by ID.
- `get_user_by_email/1`: normalizes and queries `email_address`.
- `authenticate_user/2`: verifies password through `CorporatePolicy.Accounts.Password.verify_password/2`.
- `create_user/1`: inserts a user with hashed password.
- `change_user/2`: returns a tracking changeset.

### LiveView / Controller Implementation

Admin and Corporate authentication are controller/session based. LiveViews use portal-specific LiveAuth plugs:

- `CorporatePolicyWeb.Admin.LiveAuth`
- `CorporatePolicyWeb.Corporate.LiveAuth`
- `CorporatePolicyWeb.Employee.LiveAuth`

### Authorization & Multi-Tenancy

- Admin auth only requires a valid session user in the current implementation.
- Corporate auth requires `users.ref_corporate_id` and rejects department IDs `[1, 3, 9]`.
- Employee auth is not based on `users`; it uses `trn_mapping_live_employees`.

⚠️ Clarification needed: a formal admin role/permission table is referenced by the broader CRM spec, but a complete role gate for Admin LiveViews is not implemented in the inspected source.

### Database Layer

- Table: `users`
- Key columns: `id`, `email_address`, `password`, `status`, `department_id`, `department_name`, `location`, `ref_corporate_id`, `deleted_at`
- Index/unique expectation: `email_address` is expected to be unique because the changeset uses `unique_constraint(:email_address)`.

## CorporatePolicy.Corporates

### Context & Module Structure

- Context: `CorporatePolicy.Corporates`
- Context file: `lib/corporate_policy/corporates.ex`
- Main schema: `CorporatePolicy.Corporates.Corporate`
- Supporting schemas:
  - `CorporatePolicy.Corporates.Logo`
  - `CorporatePolicy.Corporates.ContactEmailLog`
  - `CorporatePolicy.Corporates.TrnMappingCorporateContact`
  - `CorporatePolicy.Corporates.{Pincode, City, State, TrnMappingPincodeCityState}`
  - `CorporatePolicy.Corporates.MdVisibilityRoleFeature`
- Admin LiveViews:
  - `lib/corporate_policy_web/admin/live/corporate_live.ex`
  - `lib/corporate_policy_web/admin/live/corporate_new_live.ex`
  - `lib/corporate_policy_web/admin/live/corporate_edit_live.ex`
- Export controller: `lib/corporate_policy_web/admin/controllers/corporate_export_controller.ex`

### Ecto Schema

```elixir
@primary_key {:corporate_id, :id, autogenerate: true}
schema "master_corporates" do
  field :corporate_name, :string
  field :coporate_contact_email, :string
  field :corporate_landline, :string
  field :ref_master_pincode_pincode_id, :integer, default: 0
  field :ref_master_city_city_id, :integer, default: 0
  field :ref_master_state_state_id, :integer, default: 0
  field :corporate_address, :string
  field :corporate_group_code, :string
  field :industry_type, :string
  field :corporate_buffer_visibility, :integer, default: 0
  field :corporate_status, :integer, default: 1
  field :pincode, :string
  field :city, :string
  field :state, :string
  field :helpline_no, :string
  field :pan_number, :string
  field :branch_name, :string
  field :deleted_at, :utc_datetime_usec

  belongs_to :logo, CorporatePolicy.Corporates.Logo,
    foreign_key: :ref_master_corporate_logos_id,
    references: :logo_id

  timestamps(type: :utc_datetime_usec)
end
```

Status values:

- `corporate_status = 1`: active
- `corporate_status = 0`: inactive

### Changesets & Validations

```elixir
@required_fields ~w(corporate_name corporate_address pincode city state pan_number)a
@optional_fields ~w(
  coporate_contact_email corporate_landline corporate_group_code
  industry_type corporate_buffer_visibility corporate_status
  helpline_no branch_name
  ref_master_corporate_logos_id
  ref_master_pincode_pincode_id ref_master_city_city_id ref_master_state_state_id
)a

def changeset(corporate, attrs) do
  attrs = normalize_pan(attrs)

  corporate
  |> cast(attrs, @required_fields ++ @optional_fields)
  |> validate_required(@required_fields)
  |> validate_length(:pincode, max: 10)
  |> validate_length(:city, max: 25)
  |> validate_length(:state, max: 25)
  |> validate_length(:pan_number, max: 15)
  |> validate_format(:pan_number, ~r/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/,
    message: "must be in valid PAN format (e.g. ABCDE1234F)"
  )
end
```

Embedded contact form:

```elixir
embedded_schema do
  field :id, :string
  field :full_name, :string
  field :mobile_number, :string
  field :email_address, :string
  field :corporate_username, :string
  field :department, :string
  field :location, :string
end
```

Contact fields are all required in the embedded changeset.

### Business Logic Functions

- `create_logo/1`: inserts into `master_logos`.
- `create_email_log/1` and `email_logged?/1`: track welcome-email delivery in `trn_mapping_corporate_contact_email_logs`.
- `list_corporates/0`: all corporates ordered by `corporate_id DESC`.
- `list_corporates_by_status/1`: filters by `corporate_status`.
- `count_active_corporates/0` and `count_inactive_corporates/0`: dashboard counts.
- `list_corporates_paginated/1`: 15-row default pagination with status tab filtering.
- `get_corporate!/1`, `get_corporate_with_logo!/1`, `change_corporate/2`.
- `create_corporate/2`: creates corporate, optional logo, contact users, mapping rows, and email queue entries.
- `update_corporate/3`: updates corporate and optionally creates/relinks logo.
- `update_contacts/2`: transactionally updates users and `trn_mapping_corporateid_corporatecontactsids`; removed contacts are soft-deactivated with `status = 0`, `deleted_at`, and `updated_at`.
- `get_location_by_pincode/1`: resolves pincode/city/state.
- `list_departments_for_dropdown/0`, `get_role_id_by_name/1`, `list_visibility_roles/0`.

### LiveView Implementation

`CorporatePolicyWeb.Admin.CorporateLive`

- `mount/3`: assigns current user, counts, status filter, pagination, and streams `:corporates`.
- Events:
  - `filter_status`: changes active/inactive/all tab.
  - `prev_page`, `next_page`: reload paginated rows.
- Uses LiveView streams with `phx-update="stream"`.

`CorporatePolicyWeb.Admin.CorporateNewLive` and `CorporateEditLive`

- `mount/3`: assigns a two-step wizard, contact rows, departments, pincode state, and logo upload.
- `allow_upload(:logo, accept: ~w(.jpg .jpeg .png), max_entries: 1)`.
- Events:
  - `validate`: validates corporate and contact forms.
  - `add_contact`, `remove_contact`.
  - `prev_tab`.
  - `cancel_upload`.
  - `save` with `action = "next"` validates first step.
  - `save` with `action = "submit"` creates/updates corporate and contacts.

### Authorization & Multi-Tenancy

- Admin can list/create/edit corporates.
- Corporate users are scoped later by `users.ref_corporate_id`.
- Employee portal derives corporate scope from active employee rows.
- `ref_corporate_id` is not cast by the `Corporate` schema because the corporate itself is the tenant root.

### Module Interconnections

- Depends on `Accounts.User` for contact creation.
- Depends on `Emails.MailQueue` for welcome emails.
- Policies, claims, enrollment rows, documents, CD accounts, and dashboards depend on `master_corporates`.

### Database Layer

- Tables:
  - `master_corporates`
  - `master_logos`
  - `users`
  - `trn_mapping_corporateid_corporatecontactsids`
  - `trn_mapping_corporate_contact_email_logs`
  - location tables: `md_pincodes`, `md_cities`, `md_states`, `trn_mapping_pincode_city_states`
- Important indexes:
  - `master_corporates.corporate_id` primary key
  - mapping table should index `corporate_id`, `corporatecontacts_id`, and active `status`.

### Component & UI Notes

- Full LiveViews are used for list/new/edit because creation is a multi-step workflow.
- Logo upload is local static storage in the current implementation, not an S3 client integration.
- Listing tables use pagination and export controller support.

## CorporatePolicy.Policies - Policy Core and 7-Step Wizard

### Context & Module Structure

- Context: `CorporatePolicy.Policies`
- Context file: `lib/corporate_policy/policies.ex`
- Main schema: `CorporatePolicy.Policies.Policy`
- Admin LiveViews:
  - Policy listing: `lib/corporate_policy_web/admin/live/policy_live.ex`
  - Wizard shell: `lib/corporate_policy_web/admin/live/add_policy_live.ex`
  - Step components:
    - `step1_policy_details_component.ex`
    - `step2_policy_features_component.ex`
    - `step3_sum_insured_component.ex`
    - `step4_data_upload_component.ex`
    - `step5_escalation_component.ex`
    - `step6_documents_component.ex`
    - `step7_cd_statements_component.ex`
- Corporate Portal readers:
  - `dashboard_live.ex`
  - `policy_features_live.ex`
  - `documents_live.ex`
  - `enrollment_details_live.ex`
  - `claims_live.ex`
  - `escalation_matrix_live.ex`

### Ecto Schema

```elixir
schema "master_add_policies" do
  field :corporate_name, :string
  field :line_of_business, :string
  field :policy_type, :string
  field :select_insurer, :string
  field :select_tpa, :string
  field :have_policy_number, :integer, default: 0
  field :policy_number, :string
  field :policy_number_identifier, :string
  field :policy_start_date, :date
  field :policy_end_date, :date
  field :family_definition, :string
  field :claim_submission_additional_email, :string
  field :intimate_claim_visibility, :string
  field :sum_insured_type, :string
  field :status, :integer, default: 0

  belongs_to :corporate, CorporatePolicy.Policies.Corporate,
    foreign_key: :ref_corporate_id,
    references: :corporate_id

  belongs_to :line_of_business_ref, CorporatePolicy.Policies.LineOfBusiness,
    foreign_key: :ref_md_line_of_businesses_id

  belongs_to :policy_type_ref, CorporatePolicy.Policies.PolicyType,
    foreign_key: :ref_md_policy_types_id

  belongs_to :insurer_ref, CorporatePolicy.Policies.Insurer, foreign_key: :ref_select_insurer_id
  belongs_to :tpa_ref, CorporatePolicy.Policies.Tpa, foreign_key: :ref_tpa_id

  belongs_to :family_definition_ref, CorporatePolicy.Policies.FamilyDefinition,
    foreign_key: :ref_md_family_definitions_id

  belongs_to :intimate_claim_visibility_ref, CorporatePolicy.Policies.IntimateClaimVisibility,
    foreign_key: :ref_intimate_claim_visibilities_id

  belongs_to :financial_year_ref, CorporatePolicy.Policies.FinancialYear,
    foreign_key: :ref_fy_year_id

  belongs_to :sum_insured_type_ref, CorporatePolicy.Policies.SumInsuredType,
    foreign_key: :ref_md_sum_insured_types_id

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

Implemented policy status values:

- `0`: Draft
- `1`: Active
- `2`: Inactive
- `3`: Expired

### Changesets & Validations

```elixir
def create_changeset(policy, attrs \\ %{}) do
  policy
  |> cast(attrs, [
    :corporate_name,
    :ref_md_line_of_businesses_id,
    :line_of_business,
    :ref_md_policy_types_id,
    :policy_type,
    :ref_select_insurer_id,
    :select_insurer,
    :ref_tpa_id,
    :select_tpa,
    :have_policy_number,
    :policy_number,
    :policy_number_identifier,
    :policy_start_date,
    :policy_end_date,
    :ref_md_family_definitions_id,
    :family_definition,
    :ref_md_sum_insured_types_id,
    :sum_insured_type,
    :ref_intimate_claim_visibilities_id,
    :intimate_claim_visibility,
    :status,
    :ref_corporate_id,
    :ref_fy_year_id,
    :created_by,
    :updated_by
  ])
  |> validate_required([
    :ref_corporate_id,
    :ref_md_line_of_businesses_id,
    :ref_md_policy_types_id,
    :ref_select_insurer_id
  ])
  |> validate_inclusion(:status, [0, 1, 2, 3])
  |> validate_inclusion(:have_policy_number, [0, 1])
  |> validate_conditional_fields()
end
```

Conditional validations:

```elixir
defp validate_conditional_fields(changeset) do
  lob = get_field(changeset, :line_of_business)
  pt = get_field(changeset, :policy_type)

  cond do
    StringUtils.equal?(lob, "Health") and
        StringUtils.in?(pt, ["GMC", "Parent Policy", "Top Up Policy"]) ->
      validate_required(changeset, [:ref_md_family_definitions_id])

    StringUtils.equal?(lob, "Health") and StringUtils.equal?(pt, "GPA") ->
      validate_required(changeset, [:ref_md_sum_insured_types_id])

    true ->
      changeset
  end
end
```

### Business Logic Functions

Policy CRUD and status:

- `list_policies/0`: loads all policies and preloads corporate, FY, LOB, type, insurer, TPA, family definition, and claim visibility references.
- `list_policies_paginated/1`: 15 per page.
- `list_policies_by_fy/1`: `0` or `nil` means all years; otherwise filters `ref_fy_year_id`.
- `list_active_policies/0`: `status == 1`, non-empty `policy_number`.
- `list_active_policies_by_corporate/2`: tenant scoped by `ref_corporate_id` or normalized `corporate_name`, optional FY.
- `list_inactive_policies/0`: `status == 2` or missing policy number.
- `list_expired_policies/0`: `status == 3`.
- `get_policy/1`, `get_policy!/1`, `get_policy_with_preloads/1`.
- `create_policy/2`: populates denormalized names, calculates FY from `policy_start_date`, determines initial status, stores `created_by` and `updated_by`, inserts, then finalizes status.
- `create_or_update_policy/2`: uses `policy_id` or `id` when present.
- `update_policy/2`, `update_policy_status/3`, `delete_policy/1`.

Financial year:

- Uses April-March cycle.
- Start date month `>= 4` maps to that calendar year; otherwise previous year.
- Stored in `master_add_policies.ref_fy_year_id`.
- `md_financial_years.year_name` stores the FY start year.

Metadata:

- `list_line_of_businesses/0`
- `list_policy_types/0`
- `list_insurers/0`
- `list_tpas/0`
- `list_corporates/0`
- `list_family_definitions/0`
- `list_policy_types_by_lob/1`
- `list_claim_visibilities/0`
- `list_financial_years/0`
- `list_sum_insured_types/0`
- `get_policy_info_meta_data/0`

Corporate Portal readers:

- `get_policy_member_count/2`
- `list_policy_employees_paginated/3`
- `list_employee_dependents_paginated/4`
- `get_policy_list_counts/2`
- `list_policy_list_view_paginated/4`
- `list_total_claim_reports_paginated/3`
- `get_total_claim_summary/2`
- `list_escalation_matrices_for_policy/1`
- `list_documents_for_policy/2`

### LiveView Implementation

`CorporatePolicyWeb.Admin.PolicyLive`

- `mount/3`: loads current user, metadata, financial years, policy stats, and policy page.
- `handle_params/3`: handles URL state for filters and pagination.
- Events:
  - `new-policy`: opens policy form/wizard.
  - `edit-policy`: loads policy for editing.
  - `save-policy`: create/update Step 1-level data.
  - `update-status`: updates status.
  - `delete-policy`: currently disabled/placeholder.
  - `filter-change`: active/draft/expired/all list filter.
  - `fy-change`: changes financial year filter.

`CorporatePolicyWeb.Admin.AddPolicyLive`

- `mount/3`: accepts params, loads policy when editing, sets current step, metadata, policy reference, and step state.
- `handle_event("goto-step", ...)`: moves within seven-step wizard.
- `handle_info({:step_completed, :step1, policy}, ...)`: stores newly created policy and enables later steps.
- `handle_info({:step_completed, step, policy}, ...)`: advances wizard.
- `handle_info({:put_flash, kind, msg}, ...)`: child components send flash messages to the shell.

Wizard pattern:

- Shell LiveView owns current step.
- Each step is a stateful component.
- Child components send `{:step_completed, step, policy}` to parent.
- Step completion is partially tracked in DB for CD statements via raw `mapping_policy_completions`; full Ecto schema was not found.

### Authorization & Multi-Tenancy

- Admin: can list/create/edit policies.
- Corporate Portal: policy data is filtered by `current_user.ref_corporate_id`.
- Employee Portal: policy data is filtered by authenticated employee’s `ref_policy_id`, `ref_corporate_id`, and `employee_code`.
- Financial year scoping is consistently represented by `ref_fy_year_id`.

### Module Interconnections

- Corporate policy references `master_corporates`.
- Feature mappings, sum insureds, upload logs, uploaded employee rows, claim reports, escalation rows, documents, CD statements, claims, and employee portal pages depend on `master_add_policies`.
- Claim submission reads policy metadata to denormalize corporate/policy/insurer/TPA names onto claim rows.

### Database Layer

- Core table: `master_add_policies`
- Master/metadata tables:
  - `md_line_of_businesses`
  - `md_policy_types`
  - `md_insurer_lists`
  - `md_policy_tpas`
  - `md_family_definitions`
  - `md_intimate_claim_visibilities`
  - `md_sum_insured_types`
  - `md_financial_years`
- Important indexes should cover `ref_corporate_id`, `ref_fy_year_id`, `status`, `policy_number`.

## CorporatePolicy.Policies - Policy Features

### Context & Module Structure

- Context: `CorporatePolicy.Policies`
- Schemas:
  - `CorporatePolicy.Policies.MasterPolicyFeatureTemplate`
  - `CorporatePolicy.Policies.MasterPolicyFeatureTemplateField`
  - `CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy`
- Admin component: `lib/corporate_policy_web/admin/live/add_policy_components/step2_policy_features_component.ex`
- Corporate reader: `lib/corporate_policy_web/corporate/live/policy_features_live.ex`
- Seed data:
  - `master_policy_feature_template_fields.csv`
  - `priv/repo/seeds/master_policy_feature_template_fields_seeds.exs`
  - `live_vibe_engine_master_policy_feature_template_fields.sql`

### Ecto Schemas

```elixir
@primary_key {:template_id, :id, autogenerate: true}
schema "master_policy_feature_templates" do
  field :policy_identifier, :string
  field :set_default, :integer, default: 2
  field :status, :integer, default: 1

  belongs_to :policy_ref, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

```elixir
@primary_key {:template_field_id, :id, autogenerate: true}
schema "master_policy_feature_template_fields" do
  field :policy_feature_template_field_name, :string
  field :policy_feature_template_field_placeholder, :string
  field :ref_master_temp_field_Type, :integer
  field :ref_template_id, :integer
  field :status, :integer, default: 0
  field :is_mandatory, :integer, default: 0
  field :ref_policyidentifier_id, :integer
  field :field_description, :string
  field :ref_fieldgrouping_id, :string
  field :deleted_at, :naive_datetime

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps(inserted_at: :created_at, updated_at: :updated_at)
end
```

```elixir
@primary_key {:policy_feature_template_field_value_id, :id, autogenerate: true}
schema "mapping_policy_feature_templates_corporates_policies" do
  field :ref_policy_feature_template_field_name, :string
  field :policy_feature_template_field_value, :string
  field :ref_template_id, :integer
  field :ref_coporate_id, :integer
  field :ref_policy_feature_template_field_id, :integer
  field :ref_policy_feature_template_field_type_id, :integer
  field :policy_feature_template_field_visibility_role_ids, :string
  field :status, :integer, default: 0
  field :deleted_at, :naive_datetime
  field :ref_policyidentifier_id, :integer

  belongs_to :policy_ref, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

### Changesets & Validations

- Template requires `policy_identifier`, `set_default`, `status`.
- Template field requires `policy_feature_template_field_name`, `ref_master_temp_field_Type`, `ref_template_id`.
- Mapping requires field name, field value, template, corporate, policy, field id, and field type id.

### Business Logic Functions

- `list_policy_feature_templates/0`: returns active/default feature templates.
- `list_policy_identifiers/1`: returns identifiers for a policy.
- `get_template_id_for_policy/1`: resolves template ID by policy type/policy.
- `list_mapped_features_by_policy/1`: returns feature mapping rows grouped by identifier.
- `get_mapped_feature_details/1`: loads mapped feature details for editing.
- `create_mapped_feature/1`, `update_mapped_feature/2`, `delete_mapped_feature/1`.
- Corporate portal filters policy features by policy type, policy number, FY, selected plan, and visibility roles.

### LiveView Implementation

Step 2 component events:

- `show_form`, `hide_form`.
- `edit_feature`: loads existing field values.
- `save-features`: writes template/field mapping rows.
- `confirm_delete`, `cancel_delete`, `delete_feature`.
- `paginate_table`.
- `next_step`.

Corporate Portal `PolicyFeaturesLive`:

- `mount/3`: loads current corporate user, FY options, policy types, policy numbers, feature cards and sum insureds.
- Events:
  - `select_policy_type`
  - `change_fy`
  - `paginate_table`
  - row/detail modal events
  - `close_modal`

### Authorization & Multi-Tenancy

- Policy feature values are scoped by `ref_coporate_id` and `ref_policy_id`.
- Visibility by role is stored as `policy_feature_template_field_visibility_role_ids`.
- Corporate Portal uses `current_user.ref_corporate_id`.
- Employee Portal only shows employee-accessible feature cards through `EmployeePortal.list_policy_feature_cards/1`.

### Database Layer

- Tables:
  - `master_policy_feature_templates`
  - `master_policy_feature_template_fields`
  - `mapping_policy_feature_templates_corporates_policies`
  - `md_visibility_role_id_feature_tmps`
- Field type values are numeric through `ref_master_temp_field_Type` / `ref_policy_feature_template_field_type_id`.

⚠️ Clarification needed: the spec references `master_policyfeature_identifiers`; the implemented system uses `master_policy_feature_templates.policy_identifier` and `ref_policyidentifier_id` fields. No Ecto schema named `PolicyFeatureIdentifier` was found.

## CorporatePolicy.Policies - Sum Insured

### Context & Module Structure

- Context: `CorporatePolicy.Policies`
- Schema: `CorporatePolicy.Policies.MasterSumInsured`
- Component: `lib/corporate_policy_web/admin/live/add_policy_components/step3_sum_insured_component.ex`

### Ecto Schema

```elixir
schema "master_sum_insureds" do
  field :sum_insured, :integer
  field :policy_feature_identifier, :string
  field :template_id, :integer
  field :policy_id, :integer
  field :feature_identifier_id, :integer
  field :status, :integer, default: 0
  field :deleted_at, :naive_datetime

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

### Changesets & Validations

```elixir
def changeset(master_sum_insured, attrs) do
  master_sum_insured
  |> cast(attrs, [
    :sum_insured,
    :policy_feature_identifier,
    :template_id,
    :policy_id,
    :feature_identifier_id,
    :status,
    :deleted_at,
    :created_by,
    :updated_by
  ])
  |> validate_required([
    :sum_insured,
    :policy_feature_identifier,
    :template_id,
    :policy_id,
    :feature_identifier_id,
    :status
  ])
  |> validate_number(:sum_insured, greater_than: 0)
end
```

### Business Logic Functions

- `list_sum_insureds_for_policy/1`: lists active rows for a policy.
- `list_features_by_identifier/1`: resolves feature identifier dropdown data.
- Step 3 writes one or more sum insured rows tied to policy and feature identifier.

### LiveView Implementation

Step 3 component events:

- Saves `sum_insured`, `policy_feature_identifier`, `template_id`, `policy_id`, and `feature_identifier_id`.
- `remove_sum_insured`: removes row by ID.
- `paginate_table`: paginates existing rows.
- `save_step3`: marks step complete and advances.

### Authorization & Multi-Tenancy

- Admin writes rows through the wizard.
- Corporate/Employee reads are indirectly scoped by accessible policy IDs and corporate ID.

### Database Layer

- Table: `master_sum_insureds`
- Important columns: `policy_id`, `template_id`, `feature_identifier_id`, `sum_insured`, `status`, `deleted_at`.

## CorporatePolicy.DataUploadService and Enrollment Data

### Context & Module Structure

- Service: `CorporatePolicy.DataUploadService` at `lib/corporate_policy/data_upload_service.ex`
- Context: `CorporatePolicy.Policies`
- Schemas:
  - `MasterPolicyDataUpload`
  - `MasterInceptionDataUpload`
  - `MasterEndorsementDataUpload`
  - `TrnMappingLiveEmployee`
  - `MasterTotalClaimReport`
  - `MasterEcardsDataUpload`
  - `TrnEndorsementDeletionLog`
- Admin wizard component: `step4_data_upload_component.ex`
- Corporate Portal enrollment page: `lib/corporate_policy_web/corporate/live/enrollment_details_live.ex`
- Employee Portal member/coverage pages: `lib/corporate_policy_web/employee/live/*.ex`

### Ecto Schemas

```elixir
schema "master_policy_data_uploads" do
  field :data_type, :string
  field :remark, :string
  field :file_path, :string
  field :policy_id, :integer
  field :status, :integer, default: 0
  field :is_dataupload, :boolean, default: false
  field :original_file_name, :string
  field :deleted_at, :naive_datetime

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

```elixir
schema "trn_mapping_live_employees" do
  field :employee_code, :string
  field :employee_name, :string
  field :gender, :string
  field :relationship, :string
  field :dob, :string
  field :age, :integer
  field :mobile_number, :string
  field :email, :string
  field :sum_insured, :float
  field :doj, :string
  field :endorsement_number, :string
  field :endorsement_date, :string
  field :endorsement_type, :string
  field :dol, :string
  field :member_card_number, :string
  field :designation, :string
  field :status, :string, default: "active"
  field :source_type, :string
  field :created_by, :integer
  field :updated_by, :integer
  field :deleted_at, :utc_datetime

  belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
  belongs_to :corporate, CorporatePolicy.Policies.Corporate,
    foreign_key: :ref_corporate_id,
    references: :corporate_id

  timestamps()
end
```

`master_inception_data_uploads` and `master_endorsement_data_uploads` share the same employee/member shape, with endorsement rows storing `age` and `sum_insured` as strings in the implemented schema.

### Changesets & Validations

- Upload log requires `data_type`, `file_path`, `policy_id`, `status`, and `is_dataupload`.
- Inception, endorsement, and live employee rows require `ref_policy_id`, `employee_code`, `employee_name`, `relationship`, `gender`, and `dob`.
- E-card rows require `ref_policy_id` and `ecards_data_url`.
- Total claim report rows require `ref_policy_id` and `employee_code`.

### Business Logic Functions

- Step 4 writes `master_policy_data_uploads` and delegates parsing to `DataUploadService`.
- Inception data creates source rows and live employee rows.
- Endorsement data creates endorsement rows and updates live employees for addition/deletion/correction style actions.
- Deletions are logged in `trn_endorsement_deletion_logs`.
- Claims dump imports into `master_total_claim_reports`.
- E-cards are stored in `master_ecards_data_uploads`.

Calculated fields:

- Active lives count is derived from `trn_mapping_live_employees` scoped by policy/corporate and active status.
- Corporate enrollment list views aggregate employees and dependents by `employee_code`.

### LiveView Implementation

Step 4 component:

- `allow_upload(:data_file, accept: ~w(.csv .pdf .zip), max_entries: 1)`.
- Events:
  - `validate_upload`
  - `save_upload`
  - `remove_upload_entry`
  - `save_step4`
  - `paginate_table`

Corporate Enrollment LiveView:

- `mount/3`: loads FY, policy type/number filters, active employee data, and counts.
- Events:
  - `select_policy_type`
  - `select_policy_number`
  - `change_fy`
  - `toggle_policy_details`
  - `select_nav_tab`
  - `select_list_type`
  - `filter_list_view`
  - `goto_list_view_page`
  - `filter_employees`
  - `goto_employee_page`
  - `view_dependents`
  - `search_dependents`
  - `goto_dependent_page`
  - `view_card`

### Authorization & Multi-Tenancy

- Admin can upload against any policy.
- Corporate HR is scoped by `users.ref_corporate_id`.
- Employee is scoped by `trn_mapping_live_employees.id`, `employee_code`, `ref_policy_id`, and `ref_corporate_id`.
- FY filter applies through the selected policy’s `ref_fy_year_id`.

### Database Layer

- Tables:
  - `master_policy_data_uploads`
  - `master_inception_data_uploads`
  - `master_endorsement_data_uploads`
  - `trn_mapping_live_employees`
  - `trn_endorsement_deletion_logs`
  - `master_total_claim_reports`
  - `master_ecards_data_uploads`
- Important filters: `ref_policy_id`, `ref_corporate_id`, `employee_code`, `relationship`, `status`, `deleted_at`.

⚠️ Clarification needed: the spec references S3 paths. The current implementation stores uploaded files under app/static paths; no S3 client integration was found.

## CorporatePolicy.EscalationMatrices and Policy Escalations

### Context & Module Structure

- Global context: `CorporatePolicy.EscalationMatrices`
- Global schema: `CorporatePolicy.EscalationMatrices.EscalationMatrix`
- Policy-specific schema: `CorporatePolicy.Policies.MasterPolicyEscalationMatrix`
- Admin LiveViews:
  - `escalation_matrix_master_live.ex`
  - `escalation_matrix_add_live.ex`
  - wizard Step 5 component
- Corporate reader: `lib/corporate_policy_web/corporate/live/escalation_matrix_live.ex`

### Ecto Schemas

```elixir
schema "master_escalation_matrices" do
  field :fullname, :string
  field :phone_number, :string
  field :mobile_number, :string
  field :email_id, :string
  field :alt_email_id, :string
  field :send_mail_alt_email, :boolean, default: false
  field :company_fulladdress, :string
  field :type, :string
  field :type_id, :integer
  field :status, :integer, default: 1
  field :deleted_at, :utc_datetime_usec

  timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
end
```

```elixir
schema "master_policy_escalation_matrices" do
  field :escalation_level_id, :integer
  field :level, :string
  field :user_id, :integer
  field :user_fullname, :string
  field :policy_id, :integer
  field :status, :integer, default: 0
  field :deleted_at, :naive_datetime

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

### Changesets & Validations

Global escalation:

- Requires `fullname`, `mobile_number`, `email_id`.
- Max lengths: fullname 150, phone/mobile 15, email/alternate email 50, type 30.
- Validates email formats for both email fields.

Policy escalation:

- Requires `escalation_level_id`, `level`, `user_id`, `user_fullname`, `policy_id`, and `status`.

### Business Logic Functions

- `list_escalation_matrices/0`
- `list_escalation_matrices_paginated/1`: 15-row pagination with streams in LiveView.
- `get_escalation_matrix!/1`
- `create_escalation_matrix/1`
- `update_escalation_matrix/2`
- `delete_escalation_matrix/1`: implemented as delete/soft-delete behavior in context/LiveView path.
- Policy context lists policy-specific escalation contacts and joins global matrix data for display.

### LiveView Implementation

Global master:

- `mount/3`: loads stream and pagination.
- Events: `prev_page`, `next_page`, `delete_click`, `cancel_delete`, `confirm_delete`.

Policy Step 5:

- Adds a global escalation user to a policy at a selected level.
- Events: add/save matrix, `remove_matrix`, `paginate_table`, `save_step5`.

Corporate Portal:

- Filters by FY, policy type, and policy number before showing policy-specific escalation matrix.

### Authorization & Multi-Tenancy

- Admin manages global and policy-specific contacts.
- Corporate HR reads only contacts for policies accessible to its `ref_corporate_id`.
- Employee portal reads employee-scoped contact matrix through `EmployeePortal.list_contact_matrix/1`.

### Database Layer

- Tables:
  - `master_escalation_matrices`
  - `md_escalation_matrices`
  - `master_policy_escalation_matrices`
- Level values come from `md_escalation_matrices`; display values include Level 1/2/3 in the spec.

## CorporatePolicy.Policies - Policy Documents

### Context & Module Structure

- Context: `CorporatePolicy.Policies`
- Schema: `CorporatePolicy.Policies.MasterPolicyDocument`
- Admin component: `step6_documents_component.ex`
- Corporate reader: `lib/corporate_policy_web/corporate/live/documents_live.ex`

### Ecto Schema

```elixir
schema "master_policy_documents" do
  field :document_type_id, :integer
  field :document_type, :string
  field :document_name_id, :integer
  field :document_name, :string
  field :note, :string
  field :file_path, :string
  field :policy_id, :integer
  field :status, :integer, default: 0
  field :original_file_name, :string
  field :deleted_at, :naive_datetime

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps()
end
```

### Changesets & Validations

Requires `document_type_id`, `document_type`, `document_name_id`, `document_name`, `file_path`, `policy_id`, and `status`.

### Business Logic Functions

- `list_documents_for_policy/2`: reads documents scoped to policy and document type.
- `get_master_policy_document/1`: loads a document by ID.
- Step 6 creates and removes policy documents.

Document type values:

- `1`: Service Document, visible to HR and Employee in the spec.
- `2`: Policy Document, HR-only in the spec.

⚠️ Clarification needed: the implemented schema stores `document_type_id` and `document_name_id`; the legacy spec names these as `ref_document_type_id` and `ref_document_name_id`.

### LiveView Implementation

Step 6 component:

- `allow_upload(:policy_doc, accept: ~w(.pdf), max_entries: 1)`.
- Events:
  - `validate_doc`
  - document upload save
  - `remove_doc_entry`
  - `remove_document`
  - `paginate_table`
  - `save_step6`

Corporate Documents LiveView:

- `mount/3`: loads corporate-scoped policies and documents.
- Events: `select_doc_type`, `select_policy_type`, `select_policy_number`, `change_fy`.

### Authorization & Multi-Tenancy

- Admin manages documents for any policy.
- Corporate HR sees documents for its corporate policies.
- Employee visibility depends on document type and employee policy scope.

### Database Layer

- Tables:
  - `master_policy_documents`
  - `md_document_types`
  - `md_document_names`

## CorporatePolicy.CdStatements

### Context & Module Structure

- Context: `CorporatePolicy.CdStatements`
- Context file: `lib/corporate_policy/cd_statements.ex`
- Schemas:
  - `CorporatePolicy.Policies.MasterCdAccount`
  - `CorporatePolicy.Policies.MasterPolicyCdStatement`
  - `CorporatePolicy.Policies.MasterCdStatementDataUpload`
  - `CorporatePolicy.Policies.MasterCdStatementUploadError`
- Admin LiveViews:
  - `cd_accounts_live.ex`
  - `cd_statement_upload_live.ex`
  - `cd_statements_live.ex`
  - wizard Step 7 component

### Ecto Schemas

```elixir
schema "master_cd_accounts" do
  field :cd_name, :string
  field :cd_number, :string
  field :corporate_id, :integer, source: :ref_corporate_id
  field :corporate_name, :string
  field :policy_id, :integer, source: :ref_policy_id
  field :policy_number, :string
  field :insurer_id, :integer, source: :ref_insurer_id
  field :insurer_name, :string
  field :status, :integer, default: 1
  field :deleted_at, :utc_datetime_usec

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps(type: :utc_datetime_usec)
end
```

```elixir
schema "master_policy_cd_statements" do
  field :corporate_name, :string
  field :corporate_id, :integer
  field :cd_number, :string
  field :cd_account_id, :integer
  field :data_upload_file, :string
  field :original_file_name, :string
  field :policy_id, :integer
  field :status, :integer, default: 0
  field :is_dataupload, :boolean, default: true
  field :deleted_at, :utc_datetime_usec

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps(type: :utc_datetime_usec)
end
```

```elixir
schema "master_cd_statement_data_uploads" do
  field :particular, :string
  field :transaction_type, :string
  field :employee_count, :integer
  field :dependant_count, :integer
  field :policy_endorsement_no, :string
  field :endorsement_issued_date, :string
  field :debit_amount, :decimal
  field :credit_amount, :decimal
  field :bank_name, :string
  field :cheque_no, :string
  field :policy_number, :string
  field :remark, :string
  field :corporate_name, :string
  field :corporate_id, :integer
  field :policy_id, :integer
  field :cd_number, :string
  field :status, :integer, default: 0
  field :deleted_at, :utc_datetime_usec
  field :ref_policy_cd_statement_id, :integer

  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps(type: :utc_datetime_usec)
end
```

### Changesets & Validations

- CD account requires `cd_number`, `corporate_id`, `corporate_name`, `insurer_id`, `insurer_name`; `status` must be `0` or `1`.
- CD upload header requires `corporate_name`, `corporate_id`, `cd_number`, `cd_account_id`, `data_upload_file`, `original_file_name`; `status` must be `0`, `1`, or `2`.
- CD ledger row requires `ref_policy_cd_statement_id`, `particular`, `transaction_type`, `policy_number`, and `cd_number`.

### Business Logic Functions

- `list_active_corporates/0`
- `list_policy_options_for_corporate/1`
- `list_cd_numbers_for_corporate/1`
- `get_cd_account_by_corporate_and_policy/2`
- `list_cd_accounts_paginated/1`
- `create_cd_account/1`
- `list_policy_cd_statements_paginated/1`
- `list_cd_statement_uploads_paginated/1`
- `delete_policy_cd_statement_row/1`
- `get_upload_errors/1`
- `create_policy_cd_statement_upload/2`

Calculated values:

- CD ledger queries aggregate debit and credit amounts to derive balances.
- Step 7 is read-only from the policy wizard except deletion of rows exposed by the component.

### LiveView Implementation

CD Accounts LiveView:

- `mount/3`: loads corporates, policy options, account table, form defaults.
- Events: `validate_form`, `save_account`, `search_accounts`, `sort_accounts`, `paginate_table`.

CD Upload LiveView:

- `allow_upload(:cd_csv, accept: ~w(.csv), max_entries: 1, max_file_size: @max_csv_size)`.
- Events:
  - `validate_form`
  - `remove_cd_entry`
  - upload save
  - `search_uploads`
  - `sort_uploads`
  - `paginate_table`
  - `show_errors`
  - `close_errors`

Step 7 component:

- Events: `search_rows`, `sort_rows`, `paginate_table`, `confirm_delete`, `cancel_delete`, `delete_row`, `save_step7`.

### Authorization & Multi-Tenancy

- Admin manages CD accounts and uploads.
- Corporate Portal does not write CD rows in the current implementation.
- Policy wizard Step 7 scopes by `policy_id`; CD accounts also store `corporate_id`.

### Database Layer

- Tables:
  - `master_cd_accounts`
  - `master_policy_cd_statements`
  - `master_cd_statement_data_uploads`
  - `master_cdstatement_upload_errors`
  - raw `mapping_policy_completions` access for step completion.

## CorporatePolicy.Claims

### Context & Module Structure

- Context: `CorporatePolicy.Claims`
- Context file: `lib/corporate_policy/claims.ex`
- Schemas:
  - `CorporatePolicy.Claims.MasterClaimSubmission`
  - `CorporatePolicy.Claims.ClaimSubmissionDocument`
  - `CorporatePolicy.Claims.ClaimLog`
- Shared LiveViews:
  - `lib/corporate_policy_web/claim_submission_index_live.ex`
  - `lib/corporate_policy_web/claim_submission_form_live.ex`
- Portal wrappers:
  - `CorporatePolicyWeb.Admin.ClaimsSubmissionIndexLive`
  - `CorporatePolicyWeb.Corporate.ClaimsSubmissionIndexLive`
  - `CorporatePolicyWeb.Employee.ClaimsSubmissionIndexLive`

### Ecto Schemas

```elixir
schema "master_claim_submission" do
  field :ref_corporate_id, :integer
  field :portal_id, :integer
  field :claim_number, :string
  field :intimation_number, :string
  field :corporate_name, :string
  field :policy_number, :string
  field :policy_type, :string
  field :insurer_name, :string
  field :tpa_name, :string
  field :employee_code, :string
  field :employee_name, :string
  field :patient_name, :string
  field :relationship, :string
  field :estimated_amount, :decimal
  field :claim_reason, :string
  field :claim_type, :string
  field :hospital_name, :string
  field :hospital_address, :string
  field :hospitalization_date, :date
  field :discharge_date, :date
  field :city, :string
  field :state, :string
  field :pincode, :string
  field :treatment_details, :string
  field :remarks, :string
  field :claim_status, :string, default: "Draft"
  field :submitted_at, :utc_datetime_usec
  field :submitted_by, :integer
  field :deleted_at, :utc_datetime_usec

  belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  has_many :documents, CorporatePolicy.Claims.ClaimSubmissionDocument, foreign_key: :claim_id
  has_many :logs, CorporatePolicy.Claims.ClaimLog, foreign_key: :claim_id

  timestamps(type: :utc_datetime_usec)
end
```

```elixir
schema "master_claim_submission_documents" do
  field :policy_id, :integer
  field :document_name, :string
  field :original_file_name, :string
  field :file_path, :string
  field :mime_type, :string
  field :file_size, :integer
  field :status, :integer, default: 1
  field :deleted_at, :utc_datetime_usec

  belongs_to :claim, CorporatePolicy.Claims.MasterClaimSubmission, foreign_key: :claim_id
  belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
  belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

  timestamps(type: :utc_datetime_usec)
end
```

```elixir
schema "trp_claim_submission_logs" do
  field :policy_id, :integer
  field :portal_id, :integer
  field :submitted_by, :integer
  field :claim_number, :string
  field :policy_number, :string
  field :corporate_name, :string
  field :policy_type, :string
  field :insurer_name, :string
  field :employee_code, :string
  field :patient_name, :string
  field :relationship, :string
  field :claim_status, :string
  field :estimated_amount, :decimal
  field :hospital_name, :string
  field :city, :string
  field :state, :string
  field :action, :string
  field :remarks, :string

  belongs_to :claim, CorporatePolicy.Claims.MasterClaimSubmission, foreign_key: :claim_id
  belongs_to :user, CorporatePolicy.Accounts.User, foreign_key: :user_id

  timestamps(type: :utc_datetime_usec, updated_at: false)
end
```

Claim status values:

- `Draft`
- `Submitted`
- `Under Review`
- `Approved`
- `Rejected`

Portal IDs:

- `1`: Admin
- `2`: Corporate
- `3`: Employee

### Changesets & Validations

Create requires:

```elixir
@required_fields ~w(
  ref_corporate_id ref_policy_id portal_id claim_number employee_code patient_name estimated_amount
  claim_reason claim_type hospital_name hospital_address hospitalization_date discharge_date
  city state pincode claim_status
)a
```

Validation rules:

- `portal_id` in `[1, 2, 3]`
- `claim_status` in the five allowed strings
- `estimated_amount > 0`
- `claim_reason` max 500
- `hospital_address` max 1000
- `discharge_date` must be after `hospitalization_date`
- unique constraints on `claim_number` and `intimation_number`

Documents require `claim_id`, `policy_id`, `document_name`, `original_file_name`, `file_path`, and `file_size > 0`.

Logs require `claim_id`, `policy_id`, `portal_id`, and `action`.

### Business Logic Functions

- `list_claims/3`: paginated, searchable, sortable claim list with portal-specific access.
- `list_claims_for_export/2`: export data.
- `get_accessible_claim!/3`: enforces portal scope and preloads policy, documents, logs.
- `create_claim/3`: enriches policy/corporate metadata, generates `CLM` and `INT` references, inserts claim and log in a transaction.
- `update_claim/4`: checks access, updates mutable fields, and logs action.
- `submit_claim/3`: requires at least 3 active documents, updates status and submitted fields, and writes log.
- `list_claim_documents/2`, `count_claim_documents/1`, `create_claim_document/3`, `delete_claim_document/4`.
- `list_accessible_corporates/2`, `list_accessible_policies/3`, `list_accessible_employees/3`, `list_patient_options/2`.
- `get_location_by_pincode/1`: helper for city/state auto-fill.

Upload constants:

- Minimum documents: `3`
- Max document size: `8_000_000`
- Extensions: `.pdf`, `.png`, `.jpg`, `.jpeg`

### LiveView Implementation

Index LiveView:

- `mount/3`: sets portal, current actor, pagination, filters, and rows.
- Events:
  - `filter`
  - `paginate`
  - `sort`

Form LiveView:

- `mount/3`: loads claim for edit or initializes new claim form; configures upload.
- `allow_upload(:claim_document, accept: ~w(.pdf .png .jpg .jpeg), max_entries: 1, max_file_size: 8_000_000)`.
- Events:
  - `validate`
  - `save`
  - `open_upload_modal`, `close_upload_modal`
  - `paginate_documents`
  - `remove_upload_entry`
  - `save_document`
  - `confirm_delete_document`
  - `submit_claim`
  - `back_to_details`

### Authorization & Multi-Tenancy

- Admin: can access all claims.
- Corporate HR: scoped to `ref_corporate_id` from the session user.
- Employee: scoped to authenticated employee `employee_code`, `ref_policy_id`, and `ref_corporate_id`.
- Access is enforced in context queries through `accessible_to/3` and explicit claim access helpers.

### Database Layer

- Tables:
  - `master_claim_submission`
  - `master_claim_submission_documents`
  - `trp_claim_submission_logs`
- Important indexes should cover `ref_corporate_id`, `ref_policy_id`, `employee_code`, `claim_status`, and `deleted_at`.

## CorporatePolicy.EmployeePortal

### Context & Module Structure

- Context: `CorporatePolicy.EmployeePortal`
- Context file: `lib/corporate_policy/employee_portal.ex`
- Data source schema: `CorporatePolicy.Policies.TrnMappingLiveEmployee`
- Employee LiveViews:
  - `dashboard_live.ex`
  - `members_live.ex`
  - `coverages_live.ex`
  - `contact_matrix_live.ex`
  - claim submission wrappers
- Controller:
  - `lib/corporate_policy_web/employee/controllers/employee_session_controller.ex`

### Ecto Schema

Employee Portal primarily reads `trn_mapping_live_employees`; see the enrollment section for the full schema.

### Changesets & Validations

The Employee Portal does not create a separate employee auth schema. Login eligibility is query-based:

- mobile number normalized to 10 digits
- relationship must represent employee/self
- employee row must be active

⚠️ Clarification needed: OTP is currently hardcoded to `123456` in the implementation. Production behavior should use generated OTP plus SMS/email dispatch.

### Business Logic Functions

- `eligible_employee_by_mobile/1`: finds an active employee/self row for OTP login.
- `get_authenticated_employee/1`: loads session employee by ID.
- `build_session_employee/1`: creates a compact session struct.
- `get_policy_details/1`: policy metadata for employee dashboard.
- `list_members/1`: employee and dependent list by policy/employee code.
- `list_policy_feature_cards/1`: coverage/benefit data for employee.
- `list_contact_matrix/1`: policy/global contact matrix for employee.
- `list_policy_types_for_employee/1`
- `list_policies_for_employee/1`

### LiveView Implementation

Dashboard/Members/ContactMatrix:

- `mount/3`: receives current employee from LiveAuth, loads scoped policy/member/contact data, assigns current page metadata.

Coverages:

- `mount/3`: loads policy feature cards and plan selection.
- `handle_event("select_plan", ...)`: switches visible plan/feature identifier.

Claim submission:

- Uses the shared claims LiveViews with portal `:employee`.

### Authorization & Multi-Tenancy

- Employee access is always derived from `trn_mapping_live_employees.id` stored in session.
- Reads are scoped by `employee_code`, `ref_policy_id`, `ref_corporate_id`, and active member status.

### Database Layer

- Tables read:
  - `trn_mapping_live_employees`
  - `master_add_policies`
  - `mapping_policy_feature_templates_corporates_policies`
  - `master_sum_insureds`
  - `master_policy_escalation_matrices`
  - `master_policy_documents`
  - claims tables for submissions

## Shared UI, Pagination, Exports, and Background Work

### Pagination

- `CorporatePolicy.Policies.page_size/0`: 15
- `CorporatePolicy.Claims.page_size/0`: 15
- `CorporatePolicyWeb.Pagination` provides presentation helpers.
- Corporate list and escalation matrix master use LiveView streams for collection rendering.

### Export Patterns

Export controllers produce CSV-style responses from context query functions:

- Admin corporate export: `admin/controllers/corporate_export_controller.ex`
- Admin escalation export: `admin/controllers/escalation_matrix_export_controller.ex`
- Claims export: admin/corporate/employee export controllers
- CD statement export: `admin/controllers/cd_statement_export_controller.ex`
- Total claim report exports for admin/corporate.

### File Uploads

Current upload handling uses LiveView `allow_upload` and stores paths in DB:

- Corporate logo: `.jpg`, `.jpeg`, `.png`
- Policy data upload: `.csv`, `.pdf`, `.zip`
- Policy document: `.pdf`
- CD statement: `.csv`
- Claim document: `.pdf`, `.png`, `.jpg`, `.jpeg`

⚠️ Clarification needed: S3 is described in the functional spec, but no concrete S3 storage adapter or `Req` upload integration was found.

### Background Jobs / Async Operations

- `CorporatePolicy.Emails.MailQueue` is a GenServer queue for welcome-email dispatch.
- Contact creation queues welcome emails and logs delivery in `trn_mapping_corporate_contact_email_logs`.
- No Oban/Broadway/background job framework was found.
- No PubSub-driven UI updates were found beyond standard Phoenix infrastructure.

## Cross-Module Data Flow

1. Admin creates a corporate in `master_corporates`.
2. Corporate contacts are created in `users` and mapped through `trn_mapping_corporateid_corporatecontactsids`.
3. Admin creates a policy in `master_add_policies`; reference names are denormalized from metadata tables.
4. Step 2 stores benefit fields in `mapping_policy_feature_templates_corporates_policies`.
5. Step 3 stores sum insured rows in `master_sum_insureds`.
6. Step 4 stores upload logs and imported employee/claim/e-card rows.
7. Inception/endorsement data feeds `trn_mapping_live_employees`.
8. Corporate and Employee portals read active policies, employees, features, documents, claims, and escalation contacts through tenant-scoped queries.
9. Claim submission writes `master_claim_submission`, documents, and audit logs.
10. CD accounts/uploads write CD header and ledger tables and are surfaced in the policy wizard.

## Open Specification Gaps

⚠️ Clarification needed: `mapping_policy_completions` is referenced by behavior/spec and raw queries, but no dedicated Ecto schema was found.

⚠️ Clarification needed: exact role permission CRUD rules for Admin/Broker Agent/Corporate HR/Employee are not fully encoded in the inspected source. Current enforcement is mostly portal/session and tenant-scope based.

⚠️ Clarification needed: several legacy table names in `DATABASE_SCHEMA_REPORT.md` are Laravel-era and are not implemented as Ecto schemas in this Phoenix app. This document focuses on implemented Phoenix modules plus referenced legacy tables where they affect behavior.

⚠️ Clarification needed: cashless hospitals, claims intimation, roles configuration, and some dashboard views have placeholder/simple LiveViews in the current code. Full schemas/business rules were not found for all of those screens.
