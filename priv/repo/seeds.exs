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

# ─── Location Data ────────────────────────────────────────────────────────────
alias CorporatePolicy.Corporates.LocationImporter

priv_dir = :code.priv_dir(:corporate_policy)

states_csv = Path.join(priv_dir, "static/meta_documents/master_states.csv")
cities_csv = Path.join(priv_dir, "static/meta_documents/master_cities.csv")
pincodes_csv = Path.join(priv_dir, "static/meta_documents/master_pincodes.csv")
mappings_csv = Path.join(priv_dir, "static/meta_documents/mapping_pincode_city_states.csv")

if File.exists?(states_csv) do
  IO.puts("Importing states...")
  {inserted, skipped} = LocationImporter.import_states(states_csv)
  IO.puts("✓ Imported #{inserted} states (#{skipped} skipped/existed).")
else
  IO.puts("⚠ States CSV not found at: #{states_csv}")
end

if File.exists?(cities_csv) do
  IO.puts("Importing cities (this may take a few seconds)...")
  {inserted, skipped} = LocationImporter.import_cities(cities_csv)
  IO.puts("✓ Imported #{inserted} cities (#{skipped} skipped/existed).")
else
  IO.puts("⚠ Cities CSV not found at: #{cities_csv}")
end

if File.exists?(pincodes_csv) do
  IO.puts("Importing pincodes (this may take a few seconds)...")
  {inserted, skipped} = LocationImporter.import_pincodes(pincodes_csv)
  IO.puts("✓ Imported #{inserted} pincodes (#{skipped} skipped/existed).")
else
  IO.puts("⚠ Pincodes CSV not found at: #{pincodes_csv}")
end

if File.exists?(mappings_csv) do
  IO.puts("Importing pincode-city-state mappings (this may take a few seconds)...")
  {inserted, skipped} = LocationImporter.import_mappings(mappings_csv)
  IO.puts("✓ Imported #{inserted} mappings (#{skipped} skipped/existed).")
else
  IO.puts("⚠ Mappings CSV not found at: #{mappings_csv}")
end
