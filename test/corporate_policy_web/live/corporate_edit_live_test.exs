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

    # Seed department options
    dept_it_admin =
      Repo.insert!(%CorporatePolicy.Corporates.MdVisibilityRoleFeature{
        role: "IT Admin",
        is_visible: 2
      })

    dept_hr =
      Repo.insert!(%CorporatePolicy.Corporates.MdVisibilityRoleFeature{
        role: "HR",
        is_visible: 2
      })

    # Add contact users to the corporate
    {:ok, contact_user} =
      Accounts.create_user(%{
        first_name: "John",
        last_name: "Doe",
        email_address: "john@init.com",
        password: "password123",
        status: 1,
        corporate_username: "johndoe",
        department_name: dept_it_admin.role,
        department_id: dept_it_admin.role_id,
        location: "Chennai",
        corporate_id: corporate.corporate_id
      })

    {:ok, contact_user2} =
      Accounts.create_user(%{
        first_name: "Jane",
        last_name: "Doe",
        email_address: "jane@init.com",
        password: "password123",
        status: 1,
        corporate_username: "janedoe",
        department_name: dept_hr.role,
        department_id: dept_hr.role_id,
        location: "Chennai",
        corporate_id: corporate.corporate_id
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
     user: user,
     corporate: corporate,
     contact_user: contact_user,
     contact_user2: contact_user2,
     dept_it_admin: dept_it_admin,
     dept_hr: dept_hr}
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
    contact_user2: contact_user2,
    dept_it_admin: dept_it_admin,
    dept_hr: dept_hr
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
          "department" => to_string(dept_it_admin.role_id),
          "location" => "Madras"
        },
        "1" => %{
          "id" => to_string(contact_user2.id),
          "full_name" => contact_user2.full_name,
          "mobile_number" => contact_user2.mobile_no,
          "email_address" => contact_user2.email_address,
          "corporate_username" => contact_user2.corporate_username,
          "department" => to_string(dept_hr.role_id),
          "location" => contact_user2.location
        },
        "2" => %{
          "full_name" => "New Contact",
          "mobile_number" => "8888888888",
          "email_address" => "new@contact.com",
          "corporate_username" => "newcontact",
          "department" => to_string(dept_hr.role_id),
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
    assert updated_contact.department_id == dept_it_admin.role_id
    assert updated_contact.ref_corporate_id == corporate.corporate_id

    # Verify new contact created in DB
    new_contact = Repo.get_by(Accounts.User, email_address: "new@contact.com")
    assert new_contact != nil
    assert new_contact.full_name == "New Contact"
    assert new_contact.department_name == "HR"
    assert new_contact.department_id == dept_hr.role_id
    assert new_contact.ref_corporate_id == corporate.corporate_id

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

    # Verify mapping status is updated to 0 (soft-deleted) for contact_user2 and deleted_at is set
    mapping =
      Repo.get_by(CorporatePolicy.Corporates.TrnMappingCorporateContact,
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user2.id
      )

    assert mapping != nil
    assert mapping.status == 0
    assert mapping.deleted_at != nil

    # Verify user record status is updated to 0 and deleted_at is set
    user_in_db = Repo.get!(Accounts.User, contact_user2.id)
    assert user_in_db.status == 0
    assert user_in_db.deleted_at != nil
  end

  test "autofetches city and state when pincode changes to a matching 6-digit value", %{
    conn: conn,
    user: user,
    corporate: corporate
  } do
    # Insert location data
    {:ok, state} = Repo.insert(%CorporatePolicy.Corporates.State{state: "Maharashtra", status: 1})
    {:ok, city} = Repo.insert(%CorporatePolicy.Corporates.City{city: "Mumbai", status: 1})
    {:ok, pincode} = Repo.insert(%CorporatePolicy.Corporates.Pincode{pincode: 400_001, status: 1})

    {:ok, _mapping} =
      Repo.insert(%CorporatePolicy.Corporates.TrnMappingPincodeCityState{
        pincode_id: pincode.pincode_id,
        city_id: city.city_id,
        state_id: state.state_id,
        status: 1
      })

    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Change the pincode in the edit form
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{"pincode" => "400001"}
      })
      |> render_change()

    # The city and state inputs should update to Mumbai/Maharashtra
    assert html =~ "value=\"Mumbai\""
    assert html =~ "value=\"Maharashtra\""
  end

  test "reactivates a soft-deleted contact if added back with same email", %{
    conn: conn,
    user: user,
    corporate: corporate,
    contact_user2: contact_user2,
    dept_hr: dept_hr
  } do
    # 1. Soft-delete contact_user2 first
    now = DateTime.utc_now()
    Repo.update!(Accounts.User.changeset(contact_user2, %{status: 0, deleted_at: now}))

    # Verify it is soft-deleted
    assert Repo.get!(Accounts.User, contact_user2.id).status == 0

    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Step 2: Go to contacts tab
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

    # Click Add New User to render inputs for index 1 in the DOM (since index 1 was soft-deleted, only index 0 is loaded)
    view |> element("button", "Add New User") |> render_click()

    # Step 3: Add a new contact using contact_user2's email
    contact_attrs = %{
      "contacts" => %{
        "1" => %{
          "full_name" => "Jane Reactivated",
          "mobile_number" => "8888888888",
          "email_address" => contact_user2.email_address,
          "corporate_username" => "janedoe",
          "department" => to_string(dept_hr.role_id),
          "location" => "Chennai"
        }
      }
    }

    view
    |> form("#corporate-form", %{
      "corporate" => contact_attrs
    })
    |> render_submit(%{"action" => "submit"})

    assert_redirected(view, "/admin/corporate")

    # Verify contact_user2 is reactivated (status 1, deleted_at nil, and updated fields)
    reactivated_user = Repo.get!(Accounts.User, contact_user2.id)
    assert reactivated_user.status == 1
    assert reactivated_user.deleted_at == nil
    assert reactivated_user.full_name == "Jane Reactivated"
    assert reactivated_user.mobile_no == "8888888888"

    # Verify mapping status is updated to 1
    mapping =
      Repo.get_by(CorporatePolicy.Corporates.TrnMappingCorporateContact,
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user2.id
      )

    assert mapping != nil
    assert mapping.status == 1
    assert mapping.deleted_at == nil
  end

  test "deletes and immediately re-adds a contact with the same email in one submission", %{
    conn: conn,
    user: user,
    corporate: corporate,
    contact_user2: contact_user2,
    dept_hr: dept_hr
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/#{corporate.corporate_id}/edit")

    # Step 1: Go to contacts tab
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

    # Step 3: Click Add New User to re-add a contact row
    view |> element("button", "Add New User") |> render_click()

    # Step 4: Submit form re-adding contact_user2 with same email address
    contact_attrs = %{
      "contacts" => %{
        "1" => %{
          "full_name" => "Jane Readded Immediately",
          "mobile_number" => "7777777777",
          "email_address" => contact_user2.email_address,
          "corporate_username" => "janedoe",
          "department" => to_string(dept_hr.role_id),
          "location" => "Chennai"
        }
      }
    }

    view
    |> form("#corporate-form", %{
      "corporate" => contact_attrs
    })
    |> render_submit(%{"action" => "submit"})

    assert_redirected(view, "/admin/corporate")

    # Verify contact_user2 was reactivated and updated in the DB
    updated_user = Repo.get!(Accounts.User, contact_user2.id)
    assert updated_user.status == 1
    assert updated_user.deleted_at == nil
    assert updated_user.full_name == "Jane Readded Immediately"
    assert updated_user.mobile_no == "7777777777"

    # Verify mapping is active
    mapping =
      Repo.get_by(CorporatePolicy.Corporates.TrnMappingCorporateContact,
        corporate_id: corporate.corporate_id,
        corporatecontacts_id: contact_user2.id
      )

    assert mapping != nil
    assert mapping.status == 1
    assert mapping.deleted_at == nil
  end
end
