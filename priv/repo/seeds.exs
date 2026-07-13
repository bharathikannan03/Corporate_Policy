# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CorporatePolicy.Repo.insert!(%CorporatePolicy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CorporatePolicy.Repo
alias CorporatePolicy.Accounts.User

# ─── Admin User ───────────────────────────────────────────────────────────────
admin_attrs = %{
  first_name: "Admin",
  last_name: "User",
  email_address: "admin@gmail.com",
  password: "admin@123",
  status: 1
}

case Repo.get_by(User, email_address: admin_attrs.email_address) do
  nil ->
    %User{}
    |> User.changeset(admin_attrs)
    |> Repo.insert!()

    IO.puts("✓ Admin user created: #{admin_attrs.email_address}")

  _existing ->
    IO.puts("→ Admin user already exists: #{admin_attrs.email_address}")
end
