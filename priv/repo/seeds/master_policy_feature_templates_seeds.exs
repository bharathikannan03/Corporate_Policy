alias CorporatePolicy.Repo
import Ecto.Query

templates = [
  %{template_id: 1, policy_identifier: "GMC",                  set_default: 2, status: 1},
  %{template_id: 2, policy_identifier: "GPA",                  set_default: 2, status: 1},
  %{template_id: 3, policy_identifier: "Parent Policy",         set_default: 2, status: 1},
  %{template_id: 4, policy_identifier: "Top up Policy",         set_default: 2, status: 1},
  %{template_id: 5, policy_identifier: "GTL",                  set_default: 2, status: 1},
  %{template_id: 6, policy_identifier: "Marine",               set_default: 2, status: 1},
  %{template_id: 7, policy_identifier: "Fire",                 set_default: 2, status: 1},
  %{template_id: 8, policy_identifier: "Office Package",         set_default: 2, status: 1},
  %{template_id: 9, policy_identifier: "Motor Insurance",        set_default: 2, status: 1},
  %{template_id: 10, policy_identifier: "Travel Insurance",      set_default: 2, status: 1},
  %{template_id: 11, policy_identifier: "Property Insurance",    set_default: 2, status: 1},
  %{template_id: 12, policy_identifier: "Commercial Insurance",  set_default: 2, status: 1},
  %{template_id: 13, policy_identifier: "Asset Insurance",       set_default: 2, status: 1},
  %{template_id: 14, policy_identifier: "Pet Insurance",         set_default: 2, status: 1},
  %{template_id: 15, policy_identifier: "Bite-Sized Insurance",  set_default: 2, status: 1},
  %{template_id: 16, policy_identifier: "Workmen Compensation", set_default: 2, status: 1}
]

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

for t <- templates do
  count =
    Repo.one(
      from row in "master_policy_feature_templates",
        where: row.template_id == ^t.template_id,
        select: count(row.template_id)
    )

  if count == 0 do
    Repo.insert_all(
      "master_policy_feature_templates",
      [%{
        template_id:      t.template_id,
        policy_identifier: t.policy_identifier,
        set_default:      t.set_default,
        status:           t.status,
        inserted_at:      now,
        updated_at:       now
      }],
      on_conflict: :nothing,
      conflict_target: :template_id
    )
    IO.puts("✓ Inserted template: #{t.policy_identifier} (id=#{t.template_id})")
  else
    Repo.update_all(
      from(row in "master_policy_feature_templates", where: row.template_id == ^t.template_id),
      set: [policy_identifier: t.policy_identifier, updated_at: now]
    )
    IO.puts("✓ Updated template: #{t.policy_identifier} (id=#{t.template_id})")
  end
end

IO.puts("\nDone!")
