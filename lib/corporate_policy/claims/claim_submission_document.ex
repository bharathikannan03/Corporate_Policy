defmodule CorporatePolicy.Claims.ClaimSubmissionDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias CorporatePolicy.Claims.MasterClaimSubmission

  schema "master_claim_submission_documents" do
    field :policy_id, :integer
    field :document_name, :string
    field :original_file_name, :string
    field :file_path, :string
    field :mime_type, :string
    field :file_size, :integer
    field :status, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    belongs_to :claim, MasterClaimSubmission, foreign_key: :claim_id
    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :claim_id,
      :policy_id,
      :document_name,
      :original_file_name,
      :file_path,
      :mime_type,
      :file_size,
      :status,
      :created_by,
      :updated_by,
      :deleted_at
    ])
    |> validate_required([
      :claim_id,
      :policy_id,
      :document_name,
      :original_file_name,
      :file_path
    ])
    |> validate_number(:file_size, greater_than: 0)
  end
end
