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

  @doc """
  Counts all users with status = 1 (active) who have not been soft-deleted.
  Used for the Users card on the admin dashboard.
  """
  def count_active_users do
    Repo.aggregate(
      from(u in User, where: u.status == 1 and is_nil(u.deleted_at)),
      :count,
      :id
    ) || 0
  end

  def get_user(id) do
    Repo.one(from u in User, where: u.id == ^id and is_nil(u.deleted_at))
  end

  def get_user_by_email(email) do
    Repo.one(from u in User, where: u.email_address == ^email and is_nil(u.deleted_at))
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      is_nil(user) -> {:error, :invalid_credentials}
      user.status != 1 -> {:error, :inactive_user}
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

  def corporate_user?(%User{} = user) do
    not is_nil(user.ref_corporate_id) and user.department_id not in [1, 3, 9]
  end

  def corporate_user?(_), do: false

  def admin_user?(%User{} = user) do
    is_nil(user.ref_corporate_id) or user.department_id in [1, 3, 9]
  end

  def admin_user?(_), do: false
end
