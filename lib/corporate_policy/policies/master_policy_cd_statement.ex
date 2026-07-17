defmodule CorporatePolicy.Policies.MasterPolicyCdStatement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_policy_cd_statements" do
    field :corporate_name, :string
    field :corporate_id, :integer
    field :cd_number, :string
    field :cd_account_id, :integer
    field :data_upload_file, :string
    field :policy_id, :integer
    field :is_dataupload, :boolean, default: true
    field :deleted_at, :naive_datetime

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
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
      :policy_id,
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
      :data_upload_file
    ])
  end
end
