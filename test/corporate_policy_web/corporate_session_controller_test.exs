defmodule CorporatePolicyWeb.Corporate.CorporateSessionControllerTest do
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

    assert redirected_to(conn) == "/corporate/dashboard"
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

  test "denies login if user is admin user", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin@example.com",
        password: "secret123",
        ref_corporate_id: nil,
        department_id: 3
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears admin session and redirects to corporate login if accessing corporate dashboard",
       %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin@example.com",
        password: "secret123",
        ref_corporate_id: nil,
        department_id: 3
      })

    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get(~p"/corporate/dashboard")

    assert redirected_to(conn) == "/corporate/login"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears employee session and redirects to corporate login if accessing corporate dashboard",
       %{conn: conn} do
    conn =
      conn
      |> init_test_session(current_employee_id: "EMP123")
      |> get(~p"/corporate/dashboard")

    assert redirected_to(conn) == "/corporate/login"
    assert get_session(conn, :current_employee_id) == nil
  end

  test "denies login if corporate user is inactive", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Inactive",
        last_name: "Corporate",
        email_address: "inactive.corp@example.com",
        password: "secret123",
        status: 0,
        ref_corporate_id: 123,
        department_id: 4
      })

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "Your account is inactive or disabled."
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login if corporate user is soft-deleted", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Deleted",
        last_name: "Corporate",
        email_address: "deleted.corp@example.com",
        password: "secret123",
        status: 1,
        ref_corporate_id: 123,
        department_id: 4
      })

    {:ok, _} =
      Ecto.Changeset.change(user, %{deleted_at: DateTime.utc_now()})
      |> CorporatePolicy.Repo.update()

    conn =
      post(conn, ~p"/corporate/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "credentials are invalid for corporate"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears session and redirects to corporate login if active user becomes inactive on accessing corporate dashboard",
       %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Deactivating",
        last_name: "Corporate",
        email_address: "deactivating.corp@example.com",
        password: "secret123",
        status: 1,
        ref_corporate_id: 123,
        department_id: 4
      })

    {:ok, _} = Accounts.change_user(user, %{status: 0}) |> CorporatePolicy.Repo.update()

    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get(~p"/corporate/dashboard")

    assert redirected_to(conn) == "/corporate/login"
    assert get_session(conn, :current_user_id) == nil

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
             "Your account is inactive or disabled."
  end
end
