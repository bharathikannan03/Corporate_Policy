defmodule CorporatePolicy.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :password, :string
    field :status, :integer, default: 0
    field :remember_token, :string
    field :deleted_at, :utc_datetime_usec
    field :full_name, :string
    field :mobile_no, :string
    field :corporate_username, :string
    field :department_name, :string
    field :location, :string
    field :department_id, :integer
    field :ref_corporate_id, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :full_name,
      :mobile_no,
      :email_address,
      :password,
      :status,
      :corporate_username,
      :department_name,
      :location,
      :department_id,
      :ref_corporate_id
    ])
    |> validate_required([:first_name, :last_name, :email_address, :password])
    |> validate_format(:email_address, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email_address)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password, hash_password(password))
    end
  end

  defp hash_password(password) do
    :crypto.hash(:sha256, password) |> Base.encode16(case: :lower)
  end
end
