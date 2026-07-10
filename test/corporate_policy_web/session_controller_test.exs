defmodule CorporatePolicyWeb.SessionControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false

  alias CorporatePolicy.Accounts

  test "renders the login page", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "Login to your account"
  end

  test "logs in with valid credentials", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane@example.com",
        password: "secret123"
      })

    conn = post(conn, ~p"/login", %{"user" => %{"email_address" => user.email_address, "password" => "secret123"}})

    assert redirected_to(conn) == "/admin/dashboard"
    assert get_session(conn, :current_user_id) == user.id
  end
end
