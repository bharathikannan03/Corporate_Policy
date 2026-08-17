defmodule CorporatePolicyWeb.Admin.CdStatementUploadLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Policies.{Policy, FinancialYear, LineOfBusiness, PolicyType, Insurer}

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
        corporate_name: "Corporate CD Statement Live",
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
        name: "Insurer CD Statement Live",
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
        policy_number: "POL-CD-LIVE-02",
        status: 1
      })

    {:ok, user: user, corporate: corporate, policy: policy}
  end

  test "standalone CD Statement mounts and displays page title", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, _view, html} = live(conn, ~p"/admin/cd-statements/cd-statement")
    assert html =~ "CD Statement"
  end

  test "policy-specific CD Statement upload mounts properly", %{
    conn: conn,
    user: user,
    policy: policy
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, _view, html} = live(conn, ~p"/admin/policy-details/#{policy.id}/cd-statements/new")
    assert html =~ "Back To CD Statement"
  end
end
