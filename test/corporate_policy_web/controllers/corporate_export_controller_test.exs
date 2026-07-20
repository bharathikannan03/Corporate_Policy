defmodule CorporatePolicyWeb.CorporateExportControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates

  setup do
    # Create an admin user for authentication
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin_test@gmail.com",
        password: "password123",
        status: 1
      })

    # Create a couple of corporates with different statuses
    {:ok, corp_active} =
      Corporates.create_corporate(%{
        "corporate_name" => "Active Corp",
        "corporate_address" => "123 Street",
        "pincode" => "123456",
        "city" => "CityA",
        "state" => "StateA",
        "pan_number" => "ABCDE1234A",
        "corporate_group_code" => "GC123A",
        "corporate_status" => 1
      })

    {:ok, corp_inactive} =
      Corporates.create_corporate(%{
        "corporate_name" => "Inactive Corp",
        "corporate_address" => "456 Avenue",
        "pincode" => "654321",
        "city" => "CityB",
        "state" => "StateB",
        "pan_number" => "FGHIJ5678B",
        "corporate_group_code" => "GC456B",
        "corporate_status" => 0
      })

    {:ok, user: user, corp_active: corp_active, corp_inactive: corp_inactive}
  end

  test "export requires authentication", %{conn: conn} do
    conn = get(conn, ~p"/admin/corporate/export")
    assert redirected_to(conn) == "/admin/login"
  end

  test "exports all corporates when status is all or unspecified", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    conn = get(conn, ~p"/admin/corporate/export", status: "all")
    assert response_content_type(conn, :csv)
    body = response(conn, 200)
    assert body =~ "Active Corp"
    assert body =~ "Inactive Corp"
  end

  test "exports active corporates only", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    conn = get(conn, ~p"/admin/corporate/export", status: "active")
    assert response_content_type(conn, :csv)
    body = response(conn, 200)
    assert body =~ "Active Corp"
    refute body =~ "Inactive Corp"
  end

  test "exports inactive corporates only", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    conn = get(conn, ~p"/admin/corporate/export", status: "inactive")
    assert response_content_type(conn, :csv)
    body = response(conn, 200)
    refute body =~ "Active Corp"
    assert body =~ "Inactive Corp"
  end
end
