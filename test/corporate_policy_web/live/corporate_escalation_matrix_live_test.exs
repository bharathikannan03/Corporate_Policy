defmodule CorporatePolicyWeb.Corporate.EscalationMatrixLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.MasterPolicyEscalationMatrix
  alias CorporatePolicy.EscalationMatrices.EscalationMatrix

  setup do
    {:ok, corporate} =
      Corporates.create_corporate(%{
        "corporate_name" => "Vibe Test Corporate Pvt Ltd",
        "corporate_address" => "Test Street, Chennai",
        "pincode" => "600001",
        "city" => "Chennai",
        "state" => "Tamil Nadu",
        "pan_number" => "ABCDE1234F",
        "corporate_status" => 1
      })

    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Corporate",
        last_name: "User",
        email_address: "corp_user_#{System.unique_integer([:positive])}@vibe.com",
        password: "password123",
        status: 1,
        ref_corporate_id: corporate.corporate_id
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

    lob = List.first(Policies.list_line_of_businesses())
    insurer = List.first(Policies.list_insurers())
    tpa = List.first(Policies.list_tpas())
    family_def = List.first(Policies.list_family_definitions())

    {:ok, empty_policy} =
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
        "policy_number" => "PG11260000000099",
        "policy_start_date" => "2025-07-25",
        "policy_end_date" => "2026-07-24",
        "status" => 1,
        "have_policy_number" => 1
      })

    {:ok, policy} =
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
        "policy_number" => "PG11260000000094",
        "policy_start_date" => "2025-07-25",
        "policy_end_date" => "2026-07-24",
        "status" => 1,
        "have_policy_number" => 1
      })

    master_esc =
      case Repo.get(EscalationMatrix, 1) do
        nil ->
          {:ok, esc} =
            CorporatePolicy.EscalationMatrices.create_escalation_matrix(%{
              "fullname" => "Ramesh",
              "mobile_number" => "9600516455",
              "email_id" => "ramesh@vibeins.com",
              "company_fulladdress" => "NO.33/54, Mount Poonamallee Road",
              "status" => 1
            })

          esc

        existing ->
          existing
      end

    Repo.insert!(%MasterPolicyEscalationMatrix{
      policy_id: policy.id,
      escalation_level_id: 1,
      level: "Level 1",
      user_id: master_esc.id,
      user_fullname: master_esc.fullname,
      status: 1
    })

    {:ok, user: user, corporate: corporate, policy: policy, empty_policy: empty_policy}
  end

  test "renders escalation matrix page with policy details and levels", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, _view, html} = live(conn, ~p"/corporate/escalation-matrix")

    assert html =~ "Escalation Matrix"
    assert html =~ "GMC"
    assert html =~ "PG11260000000094"

    assert html =~ "Level 1"
    assert html =~ "Ramesh"
  end

  test "renders 'No user found for this policy.' when switching to policy with no escalation contacts",
       %{
         conn: conn,
         user: user
       } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, _html} = live(conn, ~p"/corporate/escalation-matrix")

    html = render_click(view, :select_policy_number, %{"number" => "PG11260000000099"})

    assert html =~ "No user found for this policy."
  end
end
