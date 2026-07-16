defmodule CorporatePolicy.Policies.MasterInceptionDataUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_inception_data_uploads" do
    field :employee_code, :string
    field :employee_name, :string
    field :gender, :string
    field :relationship, :string
    field :dob, :string
    field :age, :integer
    field :mobile_number, :string
    field :email, :string
    field :sum_insured, :float
    field :doj, :string
    field :endorsement_number, :string
    field :endorsement_date, :string
    field :endorsement_type, :string
    field :dol, :string
    field :member_card_number, :string
    field :designation, :string
    field :status, :string, default: "0"
    
    field :otp, :integer
    field :otp_expires_at, :utc_datetime
    field :is_register, :integer, default: 0
    field :is_mail_send, :integer, default: 0
    field :is_testuser, :integer, default: 0
    field :created_by, :integer
    field :updated_by, :integer
    field :deleted_at, :utc_datetime

    belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id

    timestamps()
  end

  @doc false
  def changeset(master_inception_data_upload, attrs) do
    master_inception_data_upload
    |> cast(attrs, [
      :employee_code, :employee_name, :gender, :relationship, :dob, :age,
      :mobile_number, :email, :sum_insured, :doj, :endorsement_number,
      :endorsement_date, :endorsement_type, :dol, :member_card_number,
      :designation, :status, :otp, :otp_expires_at, :is_register, :is_mail_send,
      :is_testuser, :created_by, :updated_by, :deleted_at, :ref_policy_id
    ])
    |> validate_required([:ref_policy_id, :employee_code, :employee_name, :relationship, :gender, :dob])
  end
end
