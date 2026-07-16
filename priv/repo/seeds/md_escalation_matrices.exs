# priv/repo/seeds/md_escalation_matrices.exs

alias CorporatePolicy.Repo

now = NaiveDateTime.local_now()

escalation_matrices = [
  %{id: 1, level: "Level 1", status: 1, inserted_at: now, updated_at: now},
  %{id: 2, level: "Level 2", status: 1, inserted_at: now, updated_at: now},
  %{id: 3, level: "Level 3", status: 1, inserted_at: now, updated_at: now}
]

Repo.insert_all("md_escalation_matrices", escalation_matrices, on_conflict: :nothing, conflict_target: [:id])
