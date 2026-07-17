defmodule CorporatePolicyWeb.Api.VisibilityRoleController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Corporates

  def index(conn, _params) do
    roles = Corporates.list_visibility_roles()

    # The user specifically requested this JSON format:
    # {
    #   "role_id": [
    #     { "role_id": 2, "role": "All" },
    #     ...
    #   ]
    # }
    role_data =
      Enum.map(roles, fn r ->
        %{role_id: r.role_id, role: r.role}
      end)

    json(conn, %{role_id: role_data})
  end
end
