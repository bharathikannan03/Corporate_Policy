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

  test "rate limits login attempts after 5 requests from same IP", %{conn: conn} do
    conn = %{conn | remote_ip: {192, 168, 1, 100}}

    # Perform 5 login attempts
    conns =
      Enum.map(1..5, fn _ ->
        post(conn, ~p"/admin/login", %{
          "user" => %{"email_address" => "invalid@example.com", "password" => "wrong"}
        })
      end)

    for c <- conns do
      assert html_response(c, 200) =~ "Invalid email or password"
    end

    # The 6th attempt should be blocked and redirected
    blocked_conn =
      post(conn, ~p"/admin/login", %{
        "user" => %{"email_address" => "invalid@example.com", "password" => "wrong"}
      })

    assert redirected_to(blocked_conn) == "/admin/login"
    assert Phoenix.Flash.get(blocked_conn.assigns.flash, :error) =~ "Too many login attempts"
  end

  test "denies login if admin user is inactive", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Inactive",
        last_name: "Admin",
        email_address: "inactive@example.com",
        password: "secret123",
        status: 0
      })

    conn =
      post(conn, ~p"/admin/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "Your account is inactive or disabled."
    assert get_session(conn, :current_user_id) == nil
  end

  test "denies login if admin user is soft-deleted", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Deleted",
        last_name: "Admin",
        email_address: "deleted@example.com",
        password: "secret123",
        status: 1
      })

    {:ok, _} =
      Ecto.Changeset.change(user, %{deleted_at: DateTime.utc_now()})
      |> CorporatePolicy.Repo.update()

    conn =
      post(conn, ~p"/admin/login", %{
        "user" => %{"email_address" => user.email_address, "password" => "secret123"}
      })

    assert html_response(conn, 200) =~ "Invalid email or password"
    assert get_session(conn, :current_user_id) == nil
  end

  test "clears session and redirects to admin login if active user becomes inactive on accessing admin dashboard",
       %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Deactivating",
        last_name: "Admin",
        email_address: "deactivating@example.com",
        password: "secret123",
        status: 1
      })

    {:ok, _} = Accounts.change_user(user, %{status: 0}) |> CorporatePolicy.Repo.update()

    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get(~p"/admin/dashboard")

    assert redirected_to(conn) == "/admin/login"
    assert get_session(conn, :current_user_id) == nil

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
             "Your account is inactive or disabled."
  end
end
