# priv/repo/seeds/md_data_types.exs
alias CorporatePolicy.Repo

now = NaiveDateTime.local_now()

data_types = [
  %{id: 1, name: "Inception Data", status: 1, inserted_at: now, updated_at: now},
  %{id: 2, name: "Endorsement Data", status: 1, inserted_at: now, updated_at: now},
  %{id: 3, name: "Claim Dumps", status: 1, inserted_at: now, updated_at: now},
  %{id: 4, name: "Ecards", status: 1, inserted_at: now, updated_at: now}
]

Repo.insert_all("md_data_types", data_types, on_conflict: :nothing, conflict_target: [:name])
