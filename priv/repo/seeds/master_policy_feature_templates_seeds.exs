alias CorporatePolicy.Repo
import Ecto.Query

# Templates matching the master_policy_feature_template_fields CSV
# Uses raw insert to avoid schema column mismatch issues
templates = [
  %{template_id: 1, policy_identifier: "GMC",                  set_default: 2, status: 1},
  %{template_id: 2, policy_identifier: "GPA",                  set_default: 2, status: 1},
  %{template_id: 3, policy_identifier: "GTL",                  set_default: 2, status: 1},
  %{template_id: 4, policy_identifier: "Marine",               set_default: 2, status: 1},
  %{template_id: 5, policy_identifier: "Fire",                 set_default: 2, status: 1},
  %{template_id: 6, policy_identifier: "Workmen Compensation", set_default: 2, status: 1},
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
    IO.puts("- Skipped (exists): #{t.policy_identifier}")
  end
end

IO.puts("\nDone!")
