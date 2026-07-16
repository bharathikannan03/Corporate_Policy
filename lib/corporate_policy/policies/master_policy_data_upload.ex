defmodule CorporatePolicy.Policies.MasterPolicyDataUpload do
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(master_policy_data_upload, attrs) do
    master_policy_data_upload
    |> cast(attrs, [
      :data_type,
      :remark,
      :file_path,
      :policy_id,
      :status,
      :is_dataupload,
      :original_file_name,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :data_type,
      :file_path,
      :policy_id,
      :status,
      :is_dataupload
    ])
  end
end
