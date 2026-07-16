defmodule CorporatePolicy.Corporates.ContactEmailLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "trn_mapping_corporate_contact_email_logs" do
    field :user_id, :integer
    field :sent_status, :string
    field :error_message, :string

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:user_id, :sent_status]
  @optional_fields [:error_message]

  def changeset(log \\ %__MODULE__{}, attrs) do
    log
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:sent_status, ["sent", "failed"])
  end
end
