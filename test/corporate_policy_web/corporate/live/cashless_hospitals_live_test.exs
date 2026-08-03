defmodule CorporatePolicyWeb.Corporate.CashlessHospitalsLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.PolicyType

  setup do
    today = Date.utc_today()
    start_date = Date.add(today, -5) |> Date.to_string()
    end_date = Date.add(today, 360) |> Date.to_string()

    # Create Corporate
    {:ok, corporate} =
      Corporates.create_corporate(%{
        "corporate_name" => "PURPLE TALK INDIA PRIVATE LIMITED",
        "corporate_address" => "123 Tech Park",
        "pincode" => "500081",
        "city" => "Hyderabad",
        "state" => "Telangana",
        "pan_number" => "ABCDE1234F",
        "corporate_status" => 1
      })

    # Create User
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Richie",
        last_name: "Joseph",
        email_address: "richie.joseph@purpletalk.com",
        password: "password123",
        ref_corporate_id: corporate.corporate_id,
        department_id: 4
      })

    # Insert dependencies
    lob =
      Repo.insert!(%CorporatePolicy.Policies.LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    insurer =
      Repo.insert!(%CorporatePolicy.Policies.Insurer{
        name: "Aditya Birla Health Insurance Co. Limited",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    tpa =
      Repo.insert!(%CorporatePolicy.Policies.Tpa{
        name: "Internal TPA",
        status: 1
      })

    family_def =
      Repo.insert!(%CorporatePolicy.Policies.FamilyDefinition{
        name: "1+3",
        display_id: 1,
        status: 1
      })

    fy =
      Repo.insert!(%CorporatePolicy.Policies.FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    # Ensure GMC policy type
    {:ok, gmc_pt} =
      case Repo.get_by(PolicyType, policy_type_value: "GMC") do
        nil ->
          %PolicyType{}
          |> PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: lob.id
          })
          |> Repo.insert()

        existing ->
          {:ok, existing}
      end

    # Create active policy
    {:ok, active_policy} =
      Policies.create_policy(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => lob.id,
        "line_of_business" => lob.line_of_business_value,
        "ref_md_policy_types_id" => gmc_pt.id,
        "policy_type" => "GMC",
        "ref_select_insurer_id" => insurer.id,
        "select_insurer" => insurer.name,
        "ref_tpa_id" => tpa.id,
        "select_tpa" => tpa.name,
        "ref_md_family_definitions_id" => family_def.id,
        "policy_number" => "2-81-25-00003017-000",
        "policy_start_date" => start_date,
        "policy_end_date" => end_date,
        "ref_fy_year_id" => fy.id,
        "status" => 1,
        "have_policy_number" => 1
      })

    # Insert a cashless hospital record for this TPA
    Repo.insert!(%Policies.CashlessHospitalUpload{
      hospital_name: "Appolo Corporate Hospital",
      hospital_address: "123 Corporate Ave",
      city: "Hyderabad",
      state: "Telangana",
      pincode: 500_081,
      ref_insurer_id: insurer.id,
      insurer_name: insurer.name,
      ref_tpa_id: to_string(tpa.id)
    })

    {:ok, user: user, corporate: corporate, active_policy: active_policy, tpa: tpa}
  end

  test "mounts corporate cashless hospitals view and lists records", %{
    conn: conn,
    user: user,
    corporate: corporate
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, _view, html} = live(conn, ~p"/corporate/cashless-hospitals")

    assert html =~ corporate.corporate_name
    assert html =~ "Cashless Hospitals"
    assert html =~ "Appolo Corporate Hospital"
    assert html =~ "Hyderabad"
  end

  test "filters cashless hospitals list by search query", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, _html} = live(conn, ~p"/corporate/cashless-hospitals")

    html =
      view
      |> form("#search-form", %{search: "Appolo"})
      |> render_change()

    assert html =~ "Appolo Corporate Hospital"

    html_no_match =
      view
      |> form("#search-form", %{search: "NonExistent"})
      |> render_change()

    refute html_no_match =~ "Appolo Corporate Hospital"
    assert html_no_match =~ "No cashless hospital records found"
  end

  test "exports cashless hospitals list as CSV", %{
    conn: conn,
    user: user,
    tpa: tpa
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    # Directly request the export action
    conn =
      get(conn, ~p"/corporate/cashless-hospitals/export", %{
        "tpa_id" => to_string(tpa.id),
        "search" => ""
      })

    assert response_content_type(conn, :csv) =~ "text/csv"
    assert get_resp_header(conn, "content-disposition") != []
    assert conn.resp_body =~ "HOSPITAL NAME"
    assert conn.resp_body =~ "Appolo Corporate Hospital"
  end
end
