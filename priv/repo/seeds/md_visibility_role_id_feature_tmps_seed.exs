# ─── Seeder: md_visibility_role_id_feature_tmps ──────────────────────────────
# Run: mix run priv/repo/seeds/md_visibility_role_id_feature_tmps_seed.exs
# ─────────────────────────────────────────────────────────────────────────────

import Ecto.Query
alias CorporatePolicy.Repo
alias CorporatePolicy.Corporates.MdVisibilityRoleFeature

roles = [
  %{role_id: 1, role: "SuperAdmin", is_visible: 0, status: 0},
  %{role_id: 2, role: "All",        is_visible: 1, status: 0},
  %{role_id: 3, role: "Admin",      is_visible: 3, status: 0},
  %{role_id: 4, role: "HR",         is_visible: 2, status: 0},
  %{role_id: 5, role: "Finance",    is_visible: 2, status: 0},
  %{role_id: 6, role: "Employee",   is_visible: 4, status: 0},
  %{role_id: 7, role: "None",       is_visible: 1, status: 0},
  %{role_id: 9, role: "Broker",     is_visible: 3, status: 0}
]

now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

inserted_count =
  Enum.reduce(roles, 0, fn attrs, acc ->
    existing =
      Repo.one(
        from r in MdVisibilityRoleFeature,
          where: r.role_id == ^attrs.role_id,
          limit: 1
      )

    case existing do
      nil ->
        Ecto.Adapters.SQL.query!(
          Repo,
          """
          INSERT INTO md_visibility_role_id_feature_tmps
            (role_id, role, is_visible, status, inserted_at, updated_at)
          OVERRIDING SYSTEM VALUE
          VALUES ($1, $2, $3, $4, $5, $6)
          """,
          [attrs.role_id, attrs.role, attrs.is_visible, attrs.status, now, now]
        )

        IO.puts("  ✓ Inserted  role_id=#{attrs.role_id}  role=#{attrs.role}  is_visible=#{attrs.is_visible}")
        acc + 1

      _existing ->
        IO.puts("  → Skipped   role_id=#{attrs.role_id}  role=#{attrs.role} (already exists)")
        acc
    end
  end)

# Advance the sequence past the highest role_id to avoid future conflicts
Ecto.Adapters.SQL.query!(
  Repo,
  "SELECT setval(pg_get_serial_sequence('md_visibility_role_id_feature_tmps', 'role_id'), (SELECT MAX(role_id) FROM md_visibility_role_id_feature_tmps))",
  []
)

IO.puts("\n✓ Seeder complete — Inserted: #{inserted_count} / #{length(roles)}")
