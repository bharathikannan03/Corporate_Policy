defmodule CorporatePolicy.Accounts do
  import Ecto.Query, warn: false

  alias CorporatePolicy.Accounts.Password
  alias CorporatePolicy.Accounts.User
  alias CorporatePolicy.Repo

  def list_users do
    Repo.all(User)
  end

  @excluded_department_ids [0, 1, 3, 4, 7, 9]

  @doc """
  Counts users whose department_id is NOT IN the excluded system/internal
  department IDs (0, 1, 3, 4, 7, 9). Used for the Corporate Users stat on
  the admin dashboard.
  """
  def count_corporate_users do
    Repo.aggregate(
      from(u in User,
        where: u.department_id not in ^@excluded_department_ids and is_nil(u.deleted_at)
      ),
      :count,
      :id
    ) || 0
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
