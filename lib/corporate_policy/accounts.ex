defmodule CorporatePolicy.Accounts do
  import Ecto.Query, warn: false

  alias CorporatePolicy.Accounts.Password
  alias CorporatePolicy.Accounts.User
  alias CorporatePolicy.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email_address: email)
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      is_nil(user) -> {:error, :invalid_credentials}
      Password.valid_password?(password, user.password) -> {:ok, user}
      true -> {:error, :invalid_credentials}
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
