defmodule CorporatePolicyWeb.PageControllerTest do
  use CorporatePolicyWeb.ConnCase

  test "GET / renders login page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == "/admin/login"
  end
end
