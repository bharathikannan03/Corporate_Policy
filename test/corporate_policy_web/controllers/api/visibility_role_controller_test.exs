defmodule CorporatePolicyWeb.Api.VisibilityRoleControllerTest do
  use CorporatePolicyWeb.ConnCase

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.MdVisibilityRoleFeature

  setup do
    # Insert test visibility roles
    role1 = Repo.insert!(%MdVisibilityRoleFeature{role_id: 101, role: "Marketing", status: 1})
    role2 = Repo.insert!(%MdVisibilityRoleFeature{role_id: 102, role: "Sales", status: 1})

    # This role has deleted_at set and should be excluded by context filtering
    role3 =
      Repo.insert!(%MdVisibilityRoleFeature{
        role_id: 103,
        role: "Support",
        status: 1,
        deleted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      })

    %{roles: [role1, role2, role3]}
  end

  test "GET /api/get_visibility_role_id_template returns active, non-deleted roles in correct format",
       %{conn: conn} do
    conn = get(conn, ~p"/api/get_visibility_role_id_template")
    res = json_response(conn, 200)

    assert Map.has_key?(res, "role_id")
    role_list = res["role_id"]
    assert is_list(role_list)

    # Must contain active, non-deleted roles
    assert Enum.any?(role_list, fn r -> r["role_id"] == 101 and r["role"] == "Marketing" end)
    assert Enum.any?(role_list, fn r -> r["role_id"] == 102 and r["role"] == "Sales" end)

    # Must exclude deleted role
    refute Enum.any?(role_list, fn r -> r["role_id"] == 103 or r["role"] == "Support" end)
  end
end
