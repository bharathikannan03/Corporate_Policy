defmodule CorporatePolicyWeb.Corporate.DashboardLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies

  setup do
    today = Date.utc_today()
    start_date = Date.add(today, -5) |> Date.to_string()
    end_date = Date.add(today, 360) |> Date.to_string()

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

    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Richie",
        last_name: "Joseph",
        email_address: "richie.joseph@purpletalk.com",
        password: "password123",
        ref_corporate_id: corporate.corporate_id,
        department_id: 4
      })

    {:ok, gmc_pt} =
      case Repo.get_by(Policies.PolicyType, policy_type_value: "GMC") do
        nil ->
          %Policies.PolicyType{}
          |> Policies.PolicyType.changeset(%{
            policy_type_value: "GMC",
            display_id: 1,
            status: 1,
            ref_md_line_of_businesses_id: 1
          })
          |> Repo.insert()

        existing ->
          {:ok, existing}
      end

    {:ok, parent_pt} =
      case Repo.get_by(Policies.PolicyType, policy_type_value: "Parent Policy") do
        nil ->
          %Policies.PolicyType{}
          |> Policies.PolicyType.changeset(%{
            policy_type_value: "Parent Policy",
            display_id: 2,
            status: 1,
            ref_md_line_of_businesses_id: 1
          })
          |> Repo.insert()

        existing ->
          {:ok, existing}
      end

    lob = List.first(Policies.list_line_of_businesses())
    insurer = List.first(Policies.list_insurers())
    tpa = List.first(Policies.list_tpas())
    family_def = List.first(Policies.list_family_definitions())

    {:ok, active_policy} =
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
        "policy_number" => "2-81-25-00003017-000",
        "policy_start_date" => start_date,
        "policy_end_date" => end_date,
        "status" => 1,
        "have_policy_number" => 1
      })

    {:ok, draft_policy} =
      Policies.create_policy(%{
        "ref_corporate_id" => corporate.corporate_id,
        "corporate_name" => corporate.corporate_name,
        "ref_md_line_of_businesses_id" => (lob && lob.id) || 1,
        "line_of_business" => "Health",
        "ref_md_policy_types_id" => parent_pt.id,
        "policy_type" => "Parent Policy",
        "ref_select_insurer_id" => (insurer && insurer.id) || 1,
        "select_insurer" => "Draft Insurer Ltd",
        "ref_md_family_definitions_id" => (family_def && family_def.id) || 1,
        "policy_start_date" => start_date,
        "policy_end_date" => end_date,
        "status" => 0,
        "have_policy_number" => 0
      })

    %{
      user: user,
      corporate: corporate,
      active_policy: active_policy,
      draft_policy: draft_policy
    }
  end

  test "mounts corporate dashboard and renders mapped corporate and active policies", %{
    conn: conn,
    user: user,
    corporate: corporate,
    active_policy: active_policy
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, _html} = live(conn, ~p"/corporate/dashboard")
    html = render(view)

    assert html =~ corporate.corporate_name
    assert html =~ "Hi, Welcome back!"
    assert html =~ "Corporate"
    assert html =~ active_policy.policy_number
    assert html =~ "Aditya Birla Health Insurance Co. Limited"
    assert html =~ "PREMIUM ANALYSIS"
    assert html =~ "CLAIM RATIO ANALYSIS"
    assert html =~ "ACTIVE EMPLOYEES"
    assert html =~ "0"

    # Draft policy should NOT be shown because only active policies (status == 1) are loaded
    refute html =~ "DRAFT-POLICY-001"
  end

  test "switches policy type and policy number tabs", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, _html} = live(conn, ~p"/corporate/dashboard")

    html = render_click(view, :select_policy_type, %{"type" => "GMC"})
    assert html =~ "2-81-25-00003017-000"

    html = render_click(view, :select_policy_number, %{"number" => "2-81-25-00003017-000"})
    assert html =~ "2-81-25-00003017-000"
  end
end
