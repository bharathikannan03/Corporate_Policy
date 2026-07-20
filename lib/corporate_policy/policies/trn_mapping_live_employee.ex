defmodule CorporatePolicy.Policies.TrnMappingLiveEmployee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trn_mapping_live_employees" do
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
    field :status, :string, default: "active"
    field :source_type, :string

    field :created_by, :integer
    field :updated_by, :integer
    field :deleted_at, :utc_datetime

    belongs_to :policy, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id

    belongs_to :corporate, CorporatePolicy.Policies.Corporate,
      foreign_key: :ref_corporate_id,
      references: :corporate_id

    timestamps()
  end

  @doc false
  def changeset(trn_mapping_live_employee, attrs) do
    trn_mapping_live_employee
    |> cast(attrs, [
      :employee_code,
      :employee_name,
      :gender,
      :relationship,
      :dob,
      :age,
      :mobile_number,
      :email,
      :sum_insured,
      :doj,
      :endorsement_number,
      :endorsement_date,
      :endorsement_type,
      :dol,
      :member_card_number,
      :designation,
      :status,
      :source_type,
      :created_by,
      :updated_by,
      :deleted_at,
      :ref_policy_id,
      :ref_corporate_id
    ])
    |> validate_required([
      :ref_policy_id,
      :employee_code,
      :employee_name,
      :relationship,
      :gender,
      :dob
    ])
  end
end
