defmodule CorporatePolicyWeb.SessionControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false

  alias CorporatePolicy.Accounts

  test "renders the login page", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert redirected_to(conn) == "/admin/login"
  end

  test "logs in with valid credentials", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane@example.com",
        password: "secret123"
      })

    conn =
      post(conn, ~p"/admin/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert redirected_to(conn) == "/admin/dashboard"
    assert get_session(conn, :current_user_id) == user.id
  end

  test "denies login if user is corporate user", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Corporate",
        last_name: "User",
        email_address: "corporate.user@example.com",
        password: "secret123",
        ref_corporate_id: 123,
        department_id: 4
      })

    conn =
      post(conn, ~p"/admin/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "Credentials are invalid for admin"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears corporate session and redirects to admin login if accessing admin dashboard", %{
    conn: conn
  } do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Corporate",
        last_name: "User",
        email_address: "corporate.user@example.com",
        password: "secret123",
        ref_corporate_id: 123,
        department_id: 4
      })

    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get(~p"/admin/dashboard")

    assert redirected_to(conn) == "/admin/login"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears employee session and redirects to admin login if accessing admin dashboard", %{
    conn: conn
  } do
    conn =
      conn
      |> init_test_session(current_employee_id: "EMP123")
      |> get(~p"/admin/dashboard")

    assert redirected_to(conn) == "/admin/login"
    assert get_session(conn, :current_employee_id) == nil
  end
end
