defmodule CorporatePolicy.Policies.MasterCdStatementUploadError do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_cdstatement_upload_errors" do
    field :ref_doc_id, :integer
    field :row, :integer
    field :column_name, :string
    field :errors, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(upload_error, attrs) do
    upload_error
    |> cast(attrs, [:ref_doc_id, :row, :column_name, :errors])
    |> validate_required([:ref_doc_id, :row, :column_name, :errors])
  end
end
