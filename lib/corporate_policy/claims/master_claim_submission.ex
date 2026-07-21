defmodule CorporatePolicy.Claims.MasterClaimSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  alias CorporatePolicy.Claims.{ClaimLog, ClaimSubmissionDocument}
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.StringUtils

  @claim_statuses ["Draft", "Submitted", "Under Review", "Approved", "Rejected"]

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

    belongs_to :policy, Policy, foreign_key: :ref_policy_id
    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    has_many :documents, ClaimSubmissionDocument, foreign_key: :claim_id
    has_many :logs, ClaimLog, foreign_key: :claim_id

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(
    ref_corporate_id ref_policy_id portal_id claim_number employee_code patient_name estimated_amount
    claim_reason claim_type hospital_name hospital_address hospitalization_date discharge_date
    city state pincode claim_status
  )a

  @optional_fields ~w(
    intimation_number corporate_name policy_number policy_type insurer_name tpa_name employee_name
    relationship treatment_details remarks submitted_at submitted_by created_by updated_by deleted_at
  )a

  @locked_update_fields ~w(ref_corporate_id ref_policy_id employee_code patient_name estimated_amount)a
  @update_required_fields ~w(
    claim_reason claim_type hospital_name hospital_address hospitalization_date discharge_date
    city state pincode claim_status
  )a

  def create_changeset(claim, attrs) do
    claim
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> normalize_string_fields()
    |> normalize_claim_status()
    |> validate_required(@required_fields)
    |> validate_inclusion(:portal_id, [1, 2, 3])
    |> validate_inclusion(:claim_status, @claim_statuses)
    |> validate_number(:estimated_amount, greater_than: 0)
    |> validate_length(:claim_reason, max: 500)
    |> validate_length(:hospital_address, max: 1000)
    |> validate_discharge_date()
    |> unique_constraint(:claim_number)
    |> unique_constraint(:intimation_number)
  end

  def update_changeset(claim, attrs) do
    claim
    |> cast(attrs, (@required_fields ++ @optional_fields) -- @locked_update_fields)
    |> normalize_string_fields()
    |> normalize_claim_status()
    |> validate_required(@update_required_fields)
    |> validate_inclusion(:portal_id, [1, 2, 3])
    |> validate_inclusion(:claim_status, @claim_statuses)
    |> validate_number(:estimated_amount, greater_than: 0)
    |> validate_length(:claim_reason, max: 500)
    |> validate_length(:hospital_address, max: 1000)
    |> validate_discharge_date()
  end

  def status_badge_class(status) do
    case StringUtils.canonicalize(status, @claim_statuses) do
      "Submitted" -> "badge badge-info"
      "Under Review" -> "badge badge-warning"
      "Approved" -> "badge badge-success"
      "Rejected" -> "badge badge-error"
      _ -> "badge badge-ghost"
    end
  end

  defp validate_discharge_date(changeset) do
    start_date = get_field(changeset, :hospitalization_date)
    end_date = get_field(changeset, :discharge_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(end_date, start_date) in [:lt, :eq] ->
        add_error(changeset, :discharge_date, "must be after hospitalization date")

      true ->
        changeset
    end
  end

  defp normalize_string_fields(changeset) do
    Enum.reduce(
      [
        :claim_number,
        :intimation_number,
        :corporate_name,
        :policy_number,
        :policy_type,
        :insurer_name,
        :tpa_name,
        :employee_code,
        :employee_name,
        :patient_name,
        :relationship,
        :claim_reason,
        :claim_type,
        :hospital_name,
        :hospital_address,
        :city,
        :state,
        :pincode,
        :treatment_details,
        :remarks
      ],
      changeset,
      fn field, acc ->
        update_change(acc, field, fn
          value when is_binary(value) -> StringUtils.normalize(value)
          value -> value
        end)
      end
    )
  end

  defp normalize_claim_status(changeset) do
    update_change(changeset, :claim_status, fn status ->
      StringUtils.canonicalize(status, @claim_statuses) || StringUtils.normalize(status)
    end)
  end
end
