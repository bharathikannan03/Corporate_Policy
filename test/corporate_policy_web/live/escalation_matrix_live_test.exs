defmodule CorporatePolicyWeb.EscalationMatrixLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.EscalationMatrices

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

    {:ok, user: user}
  end

  test "renders add user page and submits form", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)

    {:ok, view, html} = live(conn, ~p"/admin/escalation-matrix/add-user")

    assert html =~ "Add New User Escalation Matrix"
    assert html =~ "Full Name"
    assert html =~ "Mobile Number"

    # Fill and submit form
    _html =
      view
      |> form("#escalation-matrix-form",
        escalation_matrix: %{
          fullname: "John Doe",
          mobile_number: "9876543210",
          email_id: "john@example.com",
          phone_number: "04412345",
          alt_email_id: "john_alt@example.com",
          send_mail_alt_email: "true",
          company_fulladdress: "123 Main St, Tech City",
          type_id: "1"
        }
      )
      |> render_submit()

    # Redirection on success to user master
    assert_redirected(view, "/admin/escalation-matrix/user-master")

    # Verify database record
    [record] = EscalationMatrices.list_escalation_matrices()
    assert record.fullname == "John Doe"
    assert record.mobile_number == "9876543210"
    assert record.email_id == "john@example.com"
    assert record.phone_number == "04412345"
    assert record.alt_email_id == "john_alt@example.com"
    assert record.send_mail_alt_email == true
    assert record.company_fulladdress == "123 Main St, Tech City"
    assert record.type == "Broker"
    assert record.type_id == 1
  end

  test "lists escalation matrix users, paginates, handles delete modal and exports", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)

    # Insert 12 escalation matrix users
    for i <- 1..12 do
      {:ok, _} =
        EscalationMatrices.create_escalation_matrix(%{
          fullname: "User Name #{i}",
          mobile_number: "987654321#{i}",
          email_id: "user#{i}@example.com",
          type_id: 1,
          type: "Broker"
        })
    end

    # Mount user-master page
    {:ok, view, html} = live(conn, ~p"/admin/escalation-matrix/user-master")

    assert html =~ "Escalation Matrix Users Master"
    # newest first
    assert html =~ "User Name 12"
    assert html =~ "Export"

    # Check S.No sequential numbering starts from 1 on page 1
    # User 12 is index 0 (row_num should be 1), User 11 is index 1 (row_num should be 2), etc.
    assert html =~ "User Name 12"
    assert html =~ "User Name 3"

    # Verify pagination shows page stats and chevron button
    assert html =~ "Showing page <span class=\"font-semibold text-blue-600\">1</span>"
    assert html =~ "of <span class=\"font-semibold text-slate-700\">2</span>"

    # Go to next page
    html = view |> element("#btn-next-desktop") |> render_click()
    assert html =~ "User Name 2"
    assert html =~ "User Name 1"
    assert html =~ "Showing page <span class=\"font-semibold text-blue-600\">2</span>"

    # Go back to page 1
    html = view |> element("#btn-prev-desktop") |> render_click()
    assert html =~ "User Name 12"

    # Get a record to test deletion
    [record | _] = EscalationMatrices.list_escalation_matrices()

    # Click delete button to open custom confirmation modal
    refute has_element?(view, "#delete-confirmation-modal")

    view |> element("#delete-btn-#{record.id}") |> render_click()
    assert has_element?(view, "#delete-confirmation-modal")

    # Cancel deletion
    view |> element("#confirm-modal-cancel-btn") |> render_click()
    refute has_element?(view, "#delete-confirmation-modal")
    # Verify not deleted
    assert EscalationMatrices.get_escalation_matrix!(record.id)

    # Click delete again and confirm
    view |> element("#delete-btn-#{record.id}") |> render_click()
    assert has_element?(view, "#delete-confirmation-modal")

    view |> element("#confirm-modal-delete-btn") |> render_click()
    refute has_element?(view, "#delete-confirmation-modal")

    # Verify soft-deleted in database (deleted_at is set)
    deleted_rec = EscalationMatrices.get_escalation_matrix!(record.id)
    assert deleted_rec.deleted_at
  end
end
