alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.FamilyDefinition

allowed_names = [
  "Self Only",
  "Self + Spouse + 2 Children",
  "Self + Spouse + 2 Children + 2 Parents or 2 In Laws",
  "Self + Spouse + 2 Children + 2 Parents + 2 Siblings",
  "Self + Spouse + 4 Children",
  "Parents Only"
]

import Ecto.Query

Repo.delete_all(
  from fd in FamilyDefinition,
    where: fd.name not in ^allowed_names
)

IO.puts("Successfully deleted extra Family Definitions from the database.")
