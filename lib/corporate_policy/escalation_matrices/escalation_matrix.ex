defmodule CorporatePolicy.EscalationMatrices.EscalationMatrix do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_escalation_matrices" do
    field :fullname, :string
    field :phone_number, :string
    field :mobile_number, :string
    field :email_id, :string
    field :alt_email_id, :string
    field :send_mail_alt_email, :boolean, default: false
    field :company_fulladdress, :string
    field :type, :string
    field :type_id, :integer
    field :status, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
  end

  @required_fields [:fullname, :mobile_number, :email_id]
  @optional_fields [
    :phone_number,
    :alt_email_id,
    :send_mail_alt_email,
    :company_fulladdress,
    :type,
    :type_id,
    :status,
    :deleted_at
  ]

  def changeset(escalation_matrix, attrs) do
    escalation_matrix
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:fullname, max: 150)
    |> validate_length(:phone_number, max: 15)
    |> validate_length(:mobile_number, max: 15)
    |> validate_length(:email_id, max: 50)
    |> validate_length(:alt_email_id, max: 50)
    |> validate_length(:type, max: 30)
    |> validate_format(:email_id, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_format(:alt_email_id, ~r/^[^\s]+@[^\s]+$/,
      message: "must be a valid email address"
    )
  end
end
