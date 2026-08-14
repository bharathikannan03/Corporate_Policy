defmodule CorporatePolicyWeb.Admin.ClaimSubmissionLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate

  alias CorporatePolicy.Policies.{
    Policy,
    FinancialYear,
    LineOfBusiness,
    PolicyType,
    Insurer,
    TrnMappingLiveEmployee
  }

  setup do
    user =
      Repo.insert!(%Accounts.User{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin@gmail.com",
        password: "admin@123",
        status: 1
      })

    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Corporate Claims Live",
        corporate_address: "Address 1",
        pincode: "400001",
        city: "Mumbai",
        state: "Maharashtra",
        pan_number: "ABCDE1234F",
        corporate_status: 1,
        status: 1
      })

    fy =
      Repo.insert!(%FinancialYear{
        year_name: "2026-2027",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    lob =
      Repo.insert!(%LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    policy_type =
      Repo.insert!(%PolicyType{
        policy_type_value: "GMC",
        ref_md_line_of_businesses_id: lob.id,
        display_id: 1,
        status: 1
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Insurer Claims Live",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    policy =
      Repo.insert!(%Policy{
        corporate_name: corporate.corporate_name,
        ref_corporate_id: corporate.corporate_id,
        ref_fy_year_id: fy.id,
        ref_md_line_of_businesses_id: lob.id,
        line_of_business: "Health",
        ref_md_policy_types_id: policy_type.id,
        policy_type: "GMC",
        ref_select_insurer_id: insurer.id,
        select_insurer: insurer.name,
        policy_number: "POL-CLAIMS-LIVE-01",
        status: 1
      })

    _employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP-CL-LIVE",
        employee_name: "Bob Claims Live",
        relationship: "Employee",
        status: "active",
        source_type: "Inception",
        created_by: user.id,
        updated_by: user.id
      })

    {:ok, user: user, corporate: corporate, policy: policy}
  end

  test "claim submission index mounts and displays title", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, _view, html} = live(conn, ~p"/admin/claims-submission")
    assert html =~ "Claims Submission"
  end

  test "add claim submission form mounts successfully and filters patients", %{
    conn: conn,
    user: user,
    corporate: corporate,
    policy: policy
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, html} = live(conn, ~p"/admin/claims-submission/add")
    assert html =~ "Add Claim"

    # 1. Trigger corporate selection first
    view
    |> form("#admin-claim-form", %{
      "claim" => %{
        "ref_corporate_id" => to_string(corporate.corporate_id)
      }
    })
    |> render_change()

    # 2. Trigger policy selection
    view
    |> form("#admin-claim-form", %{
      "claim" => %{
        "ref_corporate_id" => to_string(corporate.corporate_id),
        "ref_policy_id" => to_string(policy.id)
      }
    })
    |> render_change()

    # 3. Trigger employee code input to fetch Bob Claims Live
    html =
      view
      |> form("#admin-claim-form", %{
        "claim" => %{
          "ref_corporate_id" => to_string(corporate.corporate_id),
          "ref_policy_id" => to_string(policy.id),
          "employee_code" => "EMP-CL-LIVE"
        }
      })
      |> render_change()

    assert html =~ "Bob Claims Live"
  end
end
