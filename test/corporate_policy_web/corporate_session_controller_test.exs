defmodule CorporatePolicyWeb.CorporateSessionControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false

  alias CorporatePolicy.Accounts

  test "renders the corporate login page", %{conn: conn} do
    conn = get(conn, ~p"/corporate/login")

    assert html_response(conn, 200) =~ "Corporate Login"
  end

  test "logs in corporate user with valid credentials", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane.corp@example.com",
        password: "secret123",
        ref_corporate_id: 42,
        # HR (non-restricted)
        department_id: 4
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert redirected_to(conn) == "/admin/dashboard"
    assert get_session(conn, :current_user_id) == user.id
  end

  test "denies login if user is SuperAdmin", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Super",
        last_name: "Admin",
        email_address: "superadmin@example.com",
        password: "secret123",
        ref_corporate_id: 42,
        # SuperAdmin (restricted)
        department_id: 1
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login if user is Admin", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin.user@example.com",
        password: "secret123",
        ref_corporate_id: 42,
        # Admin (restricted)
        department_id: 3
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login if user is Broker", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Broker",
        last_name: "User",
        email_address: "broker@example.com",
        password: "secret123",
        ref_corporate_id: 42,
        # Broker (restricted)
        department_id: 9
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login if user lacks ref_corporate_id", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Regular",
        last_name: "User",
        email_address: "regular@example.com",
        password: "secret123",
        ref_corporate_id: nil,
        department_id: 4
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login with invalid credentials", %{conn: conn} do
    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => "unknown@example.com", "password" => "wrong"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "logs out", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane.corp@example.com",
        password: "secret123",
        ref_corporate_id: 42,
        department_id: 4
      })

    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> delete(~p"/corporate/logout")

    assert redirected_to(conn) == "/corporate/login"
    assert get_session(conn, :current_user_id) == nil
  end
end
