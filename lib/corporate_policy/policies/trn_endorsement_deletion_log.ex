defmodule CorporatePolicy.Policies.TrnEndorsementDeletionLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trn_endorsement_deletion_logs" do
    field :employee_code, :string
    field :employee_name, :string
    field :relationship, :string
    field :endorsement_number, :string
    field :endorsement_date, :string
    field :endorsement_type, :string
    field :deletion_category, :string, default: "Dependant Deletion"
    field :action, :string
    field :deleted_at, :utc_datetime

    field :created_by, :integer
    field :updated_by, :integer

    belongs_to :upload, CorporatePolicy.Policies.MasterPolicyDataUpload, foreign_key: :upload_id
    belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id

    belongs_to :corporate, CorporatePolicy.Policies.Corporate,
      foreign_key: :ref_corporate_id,
      references: :corporate_id

    timestamps()
  end

  @doc false
  def changeset(trn_endorsement_deletion_log, attrs) do
    trn_endorsement_deletion_log
    |> cast(attrs, [
      :employee_code,
      :employee_name,
      :relationship,
      :endorsement_number,
      :endorsement_date,
      :endorsement_type,
      :deletion_category,
      :action,
      :deleted_at,
      :created_by,
      :updated_by,
      :upload_id,
      :ref_policy_id,
      :ref_corporate_id
    ])
    |> validate_required([
      :ref_policy_id,
      :employee_code,
      :relationship,
      :deletion_category
    ])
  end
end
