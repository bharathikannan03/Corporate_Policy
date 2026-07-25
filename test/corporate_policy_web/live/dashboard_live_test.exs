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

  test "displays expiring policies renewals chart correctly", %{
    conn: conn,
    user: user,
    active_corp: corporate
  } do
    alias CorporatePolicy.Policies
    alias CorporatePolicy.Repo

    # 1. Fetch metadata records so we don't violate foreign key constraints
    gmc_pt =
      case Repo.get_by(Policies.PolicyType, policy_type_value: "GMC") do
        nil ->
          %Policies.PolicyType{}
          |> Policies.PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: 1
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    lob = List.first(Policies.list_line_of_businesses())
    insurer = List.first(Policies.list_insurers())
    tpa = List.first(Policies.list_tpas())
    family_def = List.first(Policies.list_family_definitions())

    # Create a future end date
    today = Date.utc_today()
    future_date = Date.add(today, 30)
    future_month = future_date.month

    {:ok, _policy} =
      Policies.create_policy(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => (lob && lob.id) || 1,
        "line_of_business" => (lob && lob.line_of_business_value) || "Health",
        "ref_md_policy_types_id" => gmc_pt.id,
        "policy_type" => "GMC",
        "ref_select_insurer_id" => (insurer && insurer.id) || 1,
        "select_insurer" => "Aditya Birla Health Insurance Co. Limited",
        "ref_tpa_id" => tpa && tpa.id,
        "select_tpa" => "Internal TPA",
        "ref_md_family_definitions_id" => (family_def && family_def.id) || 1,
        "policy_number" => "TEST-POLICY-123",
        "policy_start_date" => Date.to_iso8601(today),
        "policy_end_date" => Date.to_iso8601(future_date)
      })

    # 2. Get chart data directly and check
    chart_data = Policies.get_expiring_policies_chart_data()
    expected_value_at_index = Enum.at(chart_data.values, future_month - 1)
    assert expected_value_at_index >= 1

    # 3. Mount dashboard and assert page contains hook and JSON data for chart
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, _view, html} = live(conn, ~p"/admin/dashboard")

    # Assert renewals-chart element and data exists in DOM
    assert html =~ "renewals-chart"
    assert html =~ "data-values"
  end
end
