defmodule CorporatePolicy.Policies.MasterEcardsDataUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_ecards_data_uploads" do
    field :ref_doc_id, :integer
    field :employee_code, :string
    field :ecard_data_originalname, :string
    field :ecards_data_url, :string
    field :data_upload, :integer, default: 0
    field :status, :integer, default: 0
    
    field :created_by, :integer
    field :updated_by, :integer
    field :deleted_at, :utc_datetime

    belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id

    timestamps()
  end

  @doc false
  def changeset(master_ecards_data_upload, attrs) do
    master_ecards_data_upload
    |> cast(attrs, [
      :ref_doc_id, :employee_code, :ecard_data_originalname, :ecards_data_url,
      :data_upload, :status, :created_by, :updated_by, :deleted_at, :ref_policy_id
    ])
    |> validate_required([:ref_policy_id, :ecards_data_url])
  end
end
