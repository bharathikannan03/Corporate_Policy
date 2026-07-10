defmodule CorporatePolicyWeb.PageControllerTest do
  use CorporatePolicyWeb.ConnCase

  test "GET / renders login page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Login to your account"
  end
end
