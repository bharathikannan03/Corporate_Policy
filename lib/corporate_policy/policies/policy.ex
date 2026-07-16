defmodule CorporatePolicy.Policies.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :id

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
    |> put_updated_by(attrs)
    |> validate_conditional_fields()
  end

  def update_changeset(policy, attrs \\ %{}) do
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
    |> put_updated_by(attrs)
    |> validate_conditional_fields()
  end

  defp validate_conditional_fields(changeset) do
    lob = get_field(changeset, :line_of_business)
    pt = get_field(changeset, :policy_type)

    cond do
      lob == "Health" and pt in ["GMC", "Parent Policy", "Top Up Policy"] ->
        validate_required(changeset, [:ref_md_family_definitions_id])

      lob == "Health" and pt == "GPA" ->
        validate_required(changeset, [:ref_md_sum_insured_types_id])

      true ->
        changeset
    end
  end

  def status_changeset(policy, attrs \\ %{}) do
    policy
    |> cast(attrs, [:status, :updated_by])
    |> validate_required([:status])
    |> validate_inclusion(:status, [0, 1, 2, 3])
    |> put_updated_by(attrs)
  end

  defp put_updated_by(changeset, attrs) do
    case get_change(changeset, :updated_by) do
      nil -> put_change(changeset, :updated_by, attrs["updated_by"] || attrs[:updated_by])
      _ -> changeset
    end
  end

  @status_draft 0
  @status_active 1
  @status_inactive 2
  @status_expired 3

  def status_label(status) do
    case status do
      @status_draft -> "Draft"
      @status_active -> "Active"
      @status_inactive -> "Inactive"
      @status_expired -> "Expired"
      _ -> "Unknown"
    end
  end

  def status_class(status) do
    case status do
      @status_draft -> "badge badge-ghost"
      @status_active -> "badge badge-success"
      @status_inactive -> "badge badge-warning"
      @status_expired -> "badge badge-error"
      _ -> "badge badge-ghost"
    end
  end
end
