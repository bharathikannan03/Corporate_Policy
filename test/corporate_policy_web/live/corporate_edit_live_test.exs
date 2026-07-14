defmodule CorporatePolicyWeb.CorporateEditLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Corporates.Corporate

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin@gmail.com",
        password: "admin@123",
        status: 1
      })

    # Create an initial corporate
    {:ok, corporate} =
      Corporates.create_corporate(
        %{
          "corporate_name" => "Initial Corp",
          "pincode" => "123456",
          "city" => "Chennai",
          "state" => "Tamil Nadu",
          "corporate_address" => "123 Old Road",
          "pan_number" => "ABCDE1234F",
          "corporate_group_code" => "INIT12"
        },
        nil
      )

    # Add contact users to the corporate
    {:ok, contact_user} =
      Accounts.create_user(%{
        first_name: "John",
        last_name: "Doe",
        email_address: "john@init.com",
        password: "password123",
        status: 1,
        corporate_username: "johndoe",
        department_name: "IT",
        location: "Chennai"
      })

    {:ok, contact_user2} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane@init.com",
        password: "password123",
        status: 1,
        corporate_username: "janedoe",
        department_name: "HR",
        location: "Chennai"
      })

    now = DateTime.utc_now()

    Repo.insert_all("trn_mapping_corporateid_corporatecontactsids", [
      %{
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user.id,
        status: 1,
        inserted_at: now,
        updated_at: now
      },
      %{
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user2.id,
        status: 1,
        inserted_at: now,
        updated_at: now
      }
    ])

    {:ok,
     user: user, corporate: corporate, contact_user: contact_user, contact_user2: contact_user2}
  end

  test "loads edit page with pre-populated data", %{conn: conn, user: user, corporate: corporate} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, _view, html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    assert html =~ "Edit Corporate"
    assert html =~ "Initial Corp"
    assert html =~ "123456"
    assert html =~ "Chennai"
    assert html =~ "ABCDE1234F"
  end

  test "validates required fields and PAN card format", %{
    conn: conn,
    user: user,
    corporate: corporate
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Submit empty fields
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{
          "corporate_name" => "",
          "pincode" => "",
          "city" => "",
          "state" => "",
          "corporate_address" => "",
          "pan_number" => ""
        }
      })
      |> render_submit(%{"action" => "next"})

    assert html =~ "can&#39;t be blank"

    # Submit invalid PAN card format
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{
          "corporate_name" => "Acme",
          "pincode" => "560001",
          "city" => "Bengaluru",
          "state" => "Karnataka",
          "corporate_address" => "456 Lane",
          "pan_number" => "invalidpan"
        }
      })
      |> render_submit(%{"action" => "next"})

    assert html =~ "must be in valid PAN format"
  end

  test "updates corporate details and contact list successfully", %{
    conn: conn,
    user: user,
    corporate: corporate,
    contact_user: contact_user,
    contact_user2: contact_user2
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # 1. Update Details step (also validates lowercase PAN normalization)
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{
          "corporate_name" => "Updated Corp Name",
          "pincode" => "600001",
          "city" => "Madras",
          "state" => "Tamil Nadu",
          "corporate_address" => "789 New Road",
          # Lowercase, should be normalized
          "pan_number" => "fihpb4074d"
        }
      })
      |> render_submit(%{"action" => "next"})

    # Tab should now switch to Corporate Contacts
    assert html =~ "Corporate Contacts"

    # Click Add New User to render inputs for index 2 in the DOM
    view |> element("button", "Add New User") |> render_click()

    # 2. Update Contacts: Edit the first contact, keep the second, and add a third
    contact_attrs = %{
      "contacts" => %{
        "0" => %{
          "id" => to_string(contact_user.id),
          "full_name" => "John Edited",
          "mobile_number" => "9999999999",
          "email_address" => "john@edited.com",
          "corporate_username" => "john_edited",
          "department" => "IT Admin",
          "location" => "Madras"
        },
        "1" => %{
          "id" => to_string(contact_user2.id),
          "full_name" => contact_user2.full_name,
          "mobile_number" => contact_user2.mobile_no,
          "email_address" => contact_user2.email_address,
          "corporate_username" => contact_user2.corporate_username,
          "department" => contact_user2.department_name,
          "location" => contact_user2.location
        },
        "2" => %{
          "full_name" => "New Contact",
          "mobile_number" => "8888888888",
          "email_address" => "new@contact.com",
          "corporate_username" => "newcontact",
          "department" => "HR",
          "location" => "Madras"
        }
      }
    }

    view
    |> form("#corporate-form", %{
      "corporate" => contact_attrs
    })
    |> render_submit(%{"action" => "submit"})

    assert_redirected(view, "/admin/corporate")

    # Verify corporate details updated in DB
    updated_corporate = Repo.get!(Corporate, corporate.corporate_id)
    assert updated_corporate.corporate_name == "Updated Corp Name"
    assert updated_corporate.pincode == "600001"
    assert updated_corporate.pan_number == "FIHPB4074D"

    # Verify existing contact updated in DB
    updated_contact = Repo.get!(Accounts.User, contact_user.id)
    assert updated_contact.full_name == "John Edited"
    assert updated_contact.mobile_no == "9999999999"
    assert updated_contact.email_address == "john@edited.com"
    assert updated_contact.department_name == "IT Admin"

    # Verify new contact created in DB
    new_contact = Repo.get_by(Accounts.User, email_address: "new@contact.com")
    assert new_contact != nil
    assert new_contact.full_name == "New Contact"
    assert new_contact.department_name == "HR"

    # Verify mapping exists for new contact
    new_mapping =
      Repo.get_by(CorporatePolicy.Corporates.TrnMappingCorporateContact,
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: new_contact.id
      )

    assert new_mapping != nil
    assert new_mapping.status == 1
  end

  test "soft-deletes removed contacts upon submission", %{
    conn: conn,
    user: user,
    corporate: corporate,
    contact_user2: contact_user2
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Step 1: Click next to get to contacts tab
    view
    |> form("#corporate-form", %{
      "corporate" => %{
        "corporate_name" => "Corp Name",
        "pincode" => "600001",
        "city" => "Madras",
        "state" => "Tamil Nadu",
        "corporate_address" => "789 New Road",
        "pan_number" => "FIHPB4074D"
      }
    })
    |> render_submit(%{"action" => "next"})

    # Step 2: Delete index 1 contact using UI click
    view
    |> element("button[phx-click='remove_contact'][phx-value-index='1']", "Delete")
    |> render_click()

    # Step 3: Submit the form to commit the deletion
    view
    |> form("#corporate-form", %{})
    |> render_submit(%{"action" => "submit"})

    assert_redirected(view, "/admin/corporate")

    # Verify mapping status is updated to 0 (soft-deleted) for contact_user2
    mapping =
      Repo.get_by(CorporatePolicy.Corporates.TrnMappingCorporateContact,
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user2.id
      )

    assert mapping != nil
    assert mapping.status == 0
  end

  test "updates corporate status successfully", %{conn: conn, user: user, corporate: corporate} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Initial corporate_status in DB is 0
    assert corporate.corporate_status == 0

    view
    |> form("#corporate-form", %{
      "corporate" => %{
        "corporate_name" => "Updated Status Corp",
        "pincode" => "600001",
        "city" => "Madras",
        "state" => "Tamil Nadu",
        "corporate_address" => "789 New Road",
        "pan_number" => "FIHPB4074D",
        "corporate_status" => "1"
      }
    })
    |> render_submit(%{"action" => "next"})

    # Complete step 2 to save
    view
    |> form("#corporate-form", %{})
    |> render_submit(%{"action" => "submit"})

    assert_redirected(view, "/admin/corporate")

    updated = Repo.get!(Corporate, corporate.corporate_id)
    assert updated.corporate_status == 1
  end
end
