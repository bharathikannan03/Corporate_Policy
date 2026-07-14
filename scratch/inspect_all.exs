# Inspect all corporates and their mappings/users
IO.puts "=== Corporates ==="
corporates = CorporatePolicy.Repo.all(CorporatePolicy.Corporates.Corporate)
IO.inspect(corporates)

IO.puts "\n=== Mappings ==="
mappings = CorporatePolicy.Repo.all(CorporatePolicy.Corporates.TrnMappingCorporateContact)
IO.inspect(mappings)

IO.puts "\n=== Users ==="
users = CorporatePolicy.Repo.all(CorporatePolicy.Accounts.User)
IO.inspect(users)
