defmodule CorporatePolicy.Corporates.Corporate do
  use Ecto.Schema
  import Ecto.Changeset

  alias CorporatePolicy.Corporates.Logo

  @primary_key {:corporate_id, :id, autogenerate: true}
  schema "master_corporates" do
    field :corporate_name, :string
    field :coporate_contact_email, :string
    field :corporate_landline, :string
    field :ref_master_pincode_pincode_id, :integer, default: 0
    field :ref_master_city_city_id, :integer, default: 0
    field :ref_master_state_state_id, :integer, default: 0
    field :corporate_address, :string
    field :corporate_group_code, :string
    field :industry_type, :string
    field :corporate_buffer_visibility, :integer, default: 0
    field :corporate_status, :integer, default: 0
    field :pincode, :string
    field :city, :string
    field :state, :string
    field :helpline_no, :string
    field :pan_number, :string
    field :branch_name, :string
    field :deleted_at, :utc_datetime_usec

    belongs_to :logo, Logo,
      foreign_key: :ref_master_corporate_logos_id,
      references: :logo_id

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(corporate_name corporate_address pincode city state)a
  @optional_fields ~w(
    coporate_contact_email corporate_landline corporate_group_code
    industry_type corporate_buffer_visibility corporate_status
    helpline_no pan_number branch_name
    ref_master_corporate_logos_id
    ref_master_pincode_pincode_id ref_master_city_city_id ref_master_state_state_id
  )a

  def changeset(corporate, attrs) do
    corporate
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:pincode, max: 10)
    |> validate_length(:city, max: 25)
    |> validate_length(:state, max: 25)
    |> validate_length(:pan_number, max: 15)
  end

  defmodule ContactForm do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :string
      field :full_name, :string
      field :mobile_number, :string
      field :email_address, :string
      field :corporate_username, :string
      field :department, :string
      field :location, :string
    end

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [
        :full_name,
        :mobile_number,
        :email_address,
        :corporate_username,
        :department,
        :location
      ])
      |> validate_required([
        :full_name,
        :mobile_number,
        :email_address,
        :corporate_username,
        :department,
        :location
      ])
    end
  end
end
