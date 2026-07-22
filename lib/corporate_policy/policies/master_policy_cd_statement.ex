defmodule CorporatePolicy.Policies.MasterPolicyCdStatement do
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(master_policy_cd_statement, attrs) do
    master_policy_cd_statement
    |> cast(attrs, [
      :corporate_name,
      :corporate_id,
      :cd_number,
      :cd_account_id,
      :data_upload_file,
      :original_file_name,
      :policy_id,
      :status,
      :is_dataupload,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :corporate_name,
      :corporate_id,
      :cd_number,
      :cd_account_id,
      :data_upload_file,
      :original_file_name
    ])
    |> validate_inclusion(:status, [0, 1, 2])
  end
end
