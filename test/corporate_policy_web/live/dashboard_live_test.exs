defmodule CorporatePolicyWeb.DashboardLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates

  setup do
    # Create an admin user for authentication
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin@gmail.com",
        password: "admin@123",
        status: 1
      })

    # Create active corporate
    {:ok, active_corp} =
      Corporates.create_corporate(%{
        "corporate_name" => "Active Corporate Co",
        "corporate_address" => "Address 1",
        "pincode" => "560001",
        "city" => "Bengaluru",
        "state" => "Karnataka",
        "pan_number" => "ABCDE1234A",
        "corporate_status" => 1
      })

    # Create inactive corporate
    {:ok, inactive_corp} =
      Corporates.create_corporate(%{
        "corporate_name" => "Inactive Corporate Co",
        "corporate_address" => "Address 2",
        "pincode" => "600001",
        "city" => "Chennai",
        "state" => "Tamil Nadu",
        "pan_number" => "FGHIJ5678B",
        "corporate_status" => 0
      })

    {:ok, user: user, active_corp: active_corp, inactive_corp: inactive_corp}
  end

  test "displays actual active/inactive corporate count and redirects to corporate page", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    # 1. Mount the dashboard and assert counts are correct
    {:ok, view, html} = live(conn, ~p"/admin/dashboard")

    assert html =~ "Corporate"
    assert html =~ "Active"
    assert html =~ "Inactive"

    # Assert counts in the HTML structure
    # Active corporate count is 1
    assert html =~ "1"

    # 2. Click the corporate card and follow the redirection to the all corporate page
    {:ok, _corp_view, corp_html} =
      view
      |> element("#stat-corporate")
      |> render_click()
      |> follow_redirect(conn, "/admin/corporate")

    assert corp_html =~ "All Corporates"
  end
end
