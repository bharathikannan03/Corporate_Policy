defmodule CorporatePolicy.Policies.MasterPolicyDocument do
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(master_policy_document, attrs) do
    master_policy_document
    |> cast(attrs, [
      :document_type_id,
      :document_type,
      :document_name_id,
      :document_name,
      :note,
      :file_path,
      :policy_id,
      :status,
      :original_file_name,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :document_type_id,
      :document_type,
      :document_name_id,
      :document_name,
      :file_path,
      :policy_id,
      :status
    ])
  end
end
