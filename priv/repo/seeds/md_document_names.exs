# priv/repo/seeds/md_document_names.exs

alias CorporatePolicy.Repo

now = NaiveDateTime.local_now()

document_names = [
  %{id: 1, document_type_id: 1, document_name: "Policy copy", status: 1, inserted_at: now, updated_at: now},
  %{id: 2, document_type_id: 2, document_name: "Claim form", status: 1, inserted_at: now, updated_at: now},
  %{id: 3, document_type_id: 2, document_name: "Non Payable list", status: 1, inserted_at: now, updated_at: now},
  %{id: 4, document_type_id: 2, document_name: "Day care list", status: 1, inserted_at: now, updated_at: now},
  %{id: 5, document_type_id: 2, document_name: "Check list", status: 1, inserted_at: now, updated_at: now}
]

Repo.insert_all("md_document_names", document_names, on_conflict: :nothing, conflict_target: [:id])
