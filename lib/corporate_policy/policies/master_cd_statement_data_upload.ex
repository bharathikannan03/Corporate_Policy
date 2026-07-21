defmodule CorporatePolicy.Policies.MasterCdStatementDataUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_cd_statement_data_uploads" do
    field :particular, :string
    field :transaction_type, :string
    field :employee_count, :integer
    field :dependant_count, :integer
    field :policy_endorsement_no, :string
    field :endorsement_issued_date, :string
    field :debit_amount, :decimal
    field :credit_amount, :decimal
    field :bank_name, :string
    field :cheque_no, :string
    field :policy_number, :string
    field :remark, :string
    field :corporate_name, :string
    field :corporate_id, :integer
    field :policy_id, :integer
    field :cd_number, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec
    field :ref_policy_cd_statement_id, :integer

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(data_upload, attrs) do
    data_upload
    |> cast(attrs, [
      :ref_policy_cd_statement_id,
      :particular,
      :transaction_type,
      :employee_count,
      :dependant_count,
      :policy_endorsement_no,
      :endorsement_issued_date,
      :debit_amount,
      :credit_amount,
      :bank_name,
      :cheque_no,
      :policy_number,
      :remark,
      :corporate_name,
      :corporate_id,
      :policy_id,
      :cd_number,
      :status,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :ref_policy_cd_statement_id,
      :particular,
      :transaction_type,
      :policy_number,
      :cd_number
    ])
  end
end
