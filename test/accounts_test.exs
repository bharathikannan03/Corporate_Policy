defmodule CorporatePolicy.AccountsTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Accounts.Password

  test "create_user stores a PBKDF2 password" do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "pbkdf2@example.com",
        password: "secret123"
      })

    assert String.starts_with?(user.password, "pbkdf2_sha256$")
    assert Password.valid_password?("secret123", user.password)
  end

  test "authenticate_user supports legacy SHA-256 hashes" do
    legacy_password =
      :crypto.hash(:sha256, "secret123")
      |> Base.encode16(case: :lower)

    {:ok, _user} =
      Accounts.create_user(%{
        first_name: "Legacy",
        last_name: "User",
        email_address: "legacy@example.com",
        password: "temporary123"
      })

    user = Accounts.get_user_by_email("legacy@example.com")

    user
    |> Ecto.Changeset.change(password: legacy_password)
    |> Repo.update!()

    assert {:ok, authenticated_user} =
             Accounts.authenticate_user("legacy@example.com", "secret123")

    assert authenticated_user.email_address == "legacy@example.com"
  end
end
