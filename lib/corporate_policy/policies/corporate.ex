defmodule CorporatePolicy.Policies.Corporate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:corporate_id, :id, autogenerate: true}

  schema "master_corporates" do
    field :corporate_name, :string
    field :corporate_address, :string
    field :corporate_landline, :string
    field :coporate_contact_email, :string
    field :corporate_group_code, :string
    field :industry_type, :string
    field :pan_number, :string
    field :helpline_no, :string
    field :branch_name, :string
    field :pincode, :string
    field :city, :string
    field :state, :string
    field :ref_master_corporate_logos_id, :id
    field :ref_master_pincode_pincode_id, :id
    field :ref_master_city_city_id, :id
    field :ref_master_state_state_id, :id
    field :corporate_buffer_visibility, :integer, default: 0
    field :corporate_status, :integer, default: 0
    field :status, :integer, default: 0

    has_many :policies, CorporatePolicy.Policies.Policy, foreign_key: :ref_corporate_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(corporate, attrs) do
    corporate
    |> cast(attrs, [
      :corporate_name,
      :corporate_address,
      :corporate_landline,
      :coporate_contact_email,
      :corporate_group_code,
      :industry_type,
      :pan_number,
      :helpline_no,
      :branch_name,
      :pincode,
      :city,
      :state,
      :ref_master_corporate_logos_id,
      :ref_master_pincode_pincode_id,
      :ref_master_city_city_id,
      :ref_master_state_state_id,
      :corporate_buffer_visibility,
      :corporate_status,
      :status
    ])
    |> validate_required([:corporate_name])
    |> validate_inclusion(:status, [0, 1])
    |> validate_inclusion(:corporate_status, [0, 1])
  end
end
