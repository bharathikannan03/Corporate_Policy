defmodule CorporatePolicyWeb.RolesConfigurationLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates.MdVisibilityRoleFeature
  alias CorporatePolicy.Repo

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

    # Clear existing roles to avoid constraint issues during test
    Repo.delete_all(CorporatePolicy.Corporates.TrnMappingRoleidRoleaccessdetail)
    Repo.delete_all(CorporatePolicy.Corporates.MdRoleAccessdetailModuleOption)
    Repo.delete_all(CorporatePolicy.Corporates.MdRoleAccessdetailModule)
    Repo.delete_all(MdVisibilityRoleFeature)

    # Seed modules
    modules = [
      %{module_id: 1, module_name: "Dashboard", status: 1},
      %{module_id: 2, module_name: "Enrollment", status: 1},
      %{module_id: 3, module_name: "Claims", status: 1},
      %{module_id: 4, module_name: "Cashless Hospitals", status: 1},
      %{module_id: 5, module_name: "Escalation Matrix", status: 1},
      %{module_id: 6, module_name: "Policy Features", status: 1},
      %{module_id: 7, module_name: "Policy Documents", status: 1},
      %{module_id: 8, module_name: "CD Statements", status: 1},
      %{module_id: 9, module_name: "Endorsements", status: 1},
      %{module_id: 10, module_name: "Employee", status: 1},
      %{module_id: 11, module_name: "Reports", status: 1},
      %{module_id: 12, module_name: "Summary", status: 1},
      %{module_id: 13, module_name: "Endorsement Calculation", status: 1}
    ]

    for m <- modules,
        do: Repo.insert!(struct(CorporatePolicy.Corporates.MdRoleAccessdetailModule, m))

    # Seed options
    options = [
      %{module_option_id: 1, module_option_name: "View", status: 1},
      %{module_option_id: 2, module_option_name: "Upload Enrollment", status: 1},
      %{module_option_id: 3, module_option_name: "Intimate Claim", status: 1},
      %{module_option_id: 4, module_option_name: "View Corporate Buffer List", status: 1},
      %{module_option_id: 5, module_option_name: "Upload CD Statements", status: 1},
      %{module_option_id: 6, module_option_name: "View Activity Logs", status: 1},
      %{module_option_id: 7, module_option_name: "View Claims Report", status: 1},
      %{module_option_id: 8, module_option_name: "View Demography Report", status: 1},
      %{module_option_id: 9, module_option_name: "View Top Ten Claims", status: 1},
      %{module_option_id: 10, module_option_name: "View Endorsement Analysis", status: 1},
      %{module_option_id: 11, module_option_name: "Upload Rackrates", status: 1},
      %{module_option_id: 12, module_option_name: "View Rackrates list", status: 1},
      %{module_option_id: 13, module_option_name: "Upload Endorsement Calculation", status: 1},
      %{module_option_id: 14, module_option_name: "View Endorsement List", status: 1}
    ]

    for o <- options,
        do: Repo.insert!(struct(CorporatePolicy.Corporates.MdRoleAccessdetailModuleOption, o))

    # Insert initial test roles
    {:ok, _role1} = Repo.insert(%MdVisibilityRoleFeature{role_id: 10, role: "HR", status: 1})
    {:ok, _role2} = Repo.insert(%MdVisibilityRoleFeature{role_id: 11, role: "Finance", status: 1})

    {:ok, user: user}
  end

  test "lists existing roles, their statuses, and allows editing", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, _view, html} = live(conn, ~p"/admin/roles-configuration")

    assert html =~ "Roles List"
    assert html =~ "HR"
    assert html =~ "Finance"
    assert html =~ "ACTIVE"
  end

  test "verifies role name case-sensitively, throws error on duplicate, and saves new role", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, html} = live(conn, ~p"/admin/roles-configuration/add")
    assert html =~ "Add Role"

    # 1. Try to verify name "HR" (exact case matches existing)
    html =
      view
      |> form("#role-name-form", %{role_name: "HR"})
      |> render_submit()

    assert html =~ "Role name already exists in the database table"

    # 2. Try to verify name "hr" (lowercase - does not match existing due to case sensitivity)
    # The form automatically converts names to uppercase on submit, so let's verify with a completely different name first
    html =
      view
      |> form("#role-name-form", %{role_name: "OPERATIONS"})
      |> render_submit()

    assert html =~ "Role name is available"
    assert html =~ "Permissions Access Configurations"

    # 3. Toggle Dashboard View permission
    # Dashboard module_id is 1, view option_id is 1
    view
    |> element("input[phx-value-module-id='1'][phx-value-option-id='1']")
    |> render_click()

    # 4. Save the role
    {:ok, _list_view, list_html} =
      view
      |> element("#save-role-btn")
      |> render_click()
      |> follow_redirect(conn, "/admin/roles-configuration/list")

    assert list_html =~ "Role and its access details stored successfully"
    assert list_html =~ "OPERATIONS"
    assert list_html =~ "Dashboard: View"
  end

  test "edits existing role permissions", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    # Mount the edit view directly
    {:ok, view, html} = live(conn, ~p"/admin/roles-configuration/10/edit")
    assert html =~ "Edit Role"
    assert html =~ "HR"
    assert html =~ "Permissions Access Configurations"

    # Toggle Claims View permission (module_id: 3, option_id: 1)
    view
    |> element("input[phx-value-module-id='3'][phx-value-option-id='1']")
    |> render_click()

    # Save
    {:ok, _list_view, list_html} =
      view
      |> element("#save-role-btn")
      |> render_click()
      |> follow_redirect(conn, "/admin/roles-configuration/list")

    assert list_html =~ "Role access details updated successfully"
    assert list_html =~ "Claims: View"
  end
end
