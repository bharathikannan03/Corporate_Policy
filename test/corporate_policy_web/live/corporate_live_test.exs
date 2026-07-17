defmodule CorporatePolicyWeb.CorporateLiveTest do
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

  test "lists corporates and filters by status using tabs", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    # 1. Mount the page and assert initially shows ALL corporates
    {:ok, view, html} = live(conn, ~p"/admin/corporate")

    assert html =~ "All Corporates"
    assert html =~ "Active Corporate Co"
    assert html =~ "Inactive Corporate Co"
    assert html =~ "Export"

    # 2. Click ACTIVE tab and assert only Active Corporate Co is displayed
    html = view |> element("#tab-active") |> render_click()
    assert html =~ "Active Corporate Co"
    refute html =~ "Inactive Corporate Co"

    # 3. Click IN-ACTIVE tab and assert only Inactive Corporate Co is displayed
    html = view |> element("#tab-inactive") |> render_click()
    refute html =~ "Active Corporate Co"
    assert html =~ "Inactive Corporate Co"

    # 4. Click ALL tab and assert both are displayed again
    html = view |> element("#tab-all") |> render_click()
    assert html =~ "Active Corporate Co"
    assert html =~ "Inactive Corporate Co"
  end

  test "paginates corporate records showing 15 per page", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    # Insert 16 additional corporates so total is 18 (2 from setup + 16 new)
    for i <- 1..16 do
      {:ok, _} =
        Corporates.create_corporate(%{
          "corporate_name" => "Corp Pagination #{i}",
          "corporate_address" => "Address",
          "pincode" => "560001",
          "city" => "Bengaluru",
          "state" => "Karnataka",
          "pan_number" => "ABCDE1234A",
          "corporate_status" => 1
        })
    end

    {:ok, view, html} = live(conn, ~p"/admin/corporate")

    assert html =~ "Corp Pagination 16"
    assert html =~ "Showing page"
    assert html =~ "1"
    assert html =~ "2"
    assert html =~ "18"

    # Click next page
    html = view |> element("#btn-next-desktop") |> render_click()
    assert html =~ "Showing page"
    assert html =~ "2"
    assert html =~ "2"
  end
end
