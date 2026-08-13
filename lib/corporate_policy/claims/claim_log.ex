defmodule CorporatePolicy.Claims.ClaimLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias CorporatePolicy.Claims.MasterClaimSubmission

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

    belongs_to :claim, MasterClaimSubmission, foreign_key: :claim_id
    belongs_to :user, CorporatePolicy.Accounts.User, foreign_key: :user_id

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :claim_id,
      :policy_id,
      :portal_id,
      :submitted_by,
      :claim_number,
      :policy_number,
      :corporate_name,
      :policy_type,
      :insurer_name,
      :employee_code,
      :patient_name,
      :relationship,
      :claim_status,
      :estimated_amount,
      :hospital_name,
      :city,
      :state,
      :action,
      :remarks,
      :user_id
    ])
    |> validate_required([:claim_id, :policy_id, :portal_id, :action])
  end
end
