# priv/repo/seeds/md_document_types.exs

alias CorporatePolicy.Repo

# This schema will be created shortly or we can use raw inserts.
# Let's use raw inserts so we don't strictly depend on schemas in seed files.
now = NaiveDateTime.local_now()

document_types = [
  %{id: 1, document_type: "Policy Document", status: 1, inserted_at: now, updated_at: now},
  %{id: 2, document_type: "Service Document", status: 1, inserted_at: now, updated_at: now}
]

Repo.insert_all("md_document_types", document_types, on_conflict: :nothing, conflict_target: [:id])
