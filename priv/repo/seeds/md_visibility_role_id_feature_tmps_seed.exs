# ─── Seeder: md_visibility_role_id_feature_tmps ──────────────────────────────
# Run: mix run priv/repo/seeds/md_visibility_role_id_feature_tmps_seed.exs
# ─────────────────────────────────────────────────────────────────────────────

import Ecto.Query
alias CorporatePolicy.Repo
alias CorporatePolicy.Corporates.MdVisibilityRoleFeature

roles = [
  %{role_id: 1, role: "All", is_visible: 1},
  %{role_id: 2, role: "superadmin", is_visible: 1},
  %{role_id: 3, role: "broker", is_visible: 1},
  %{role_id: 4, role: "none", is_visible: 1}
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
            (ref_feature_template_field_id, role_id, role, is_visible, inserted_at, updated_at)
          VALUES (1, $1, $2, $3, $4, $5)
          """,
          [attrs.role_id, attrs.role, attrs.is_visible, now, now]
        )

        IO.puts("  ✓ Inserted  role_id=#{attrs.role_id}  role=#{attrs.role}")
        acc + 1

      _existing ->
        Ecto.Adapters.SQL.query!(
          Repo,
          """
          UPDATE md_visibility_role_id_feature_tmps
          SET role = $1, is_visible = $2, updated_at = $3
          WHERE role_id = $4
          """,
          [attrs.role, attrs.is_visible, now, attrs.role_id]
        )

        IO.puts("  ✓ Updated   role_id=#{attrs.role_id}  role=#{attrs.role}")
        acc + 1
    end
  end)

# Advance the sequence past the highest role_id to avoid future conflicts
Ecto.Adapters.SQL.query!(
  Repo,
  "SELECT setval(pg_get_serial_sequence('md_visibility_role_id_feature_tmps', 'id'), (SELECT MAX(id) FROM md_visibility_role_id_feature_tmps))",
  []
)

IO.puts("\n✓ Seeder complete — Inserted: #{inserted_count} / #{length(roles)}")
