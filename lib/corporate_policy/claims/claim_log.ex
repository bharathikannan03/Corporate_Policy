defmodule CorporatePolicy.Claims.ClaimLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias CorporatePolicy.Claims.MasterClaimSubmission

  schema "trp_claim_submission_logs" do
    field :policy_id, :integer
    field :portal_id, :integer
    field :submitted_by, :integer
    field :action, :string
    field :remarks, :string

    belongs_to :claim, MasterClaimSubmission, foreign_key: :claim_id
    belongs_to :user, CorporatePolicy.Accounts.User, foreign_key: :user_id

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:claim_id, :policy_id, :portal_id, :submitted_by, :action, :remarks, :user_id])
    |> validate_required([:claim_id, :policy_id, :portal_id, :action])
  end
end
