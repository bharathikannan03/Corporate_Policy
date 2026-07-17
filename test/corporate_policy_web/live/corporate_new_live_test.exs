defmodule CorporatePolicyWeb.CorporateNewLiveTest do
  use CorporatePolicyWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Ecto.Query, only: [from: 2]
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
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

    # Seed departments
    dept_hr =
      Repo.insert!(%CorporatePolicy.Corporates.MdVisibilityRoleFeature{
        role: "HR",
        is_visible: 2
      })

    dept_finance =
      Repo.insert!(%CorporatePolicy.Corporates.MdVisibilityRoleFeature{
        role: "Finance",
        is_visible: 2
      })

    {:ok, user: user, dept_hr: dept_hr, dept_finance: dept_finance}
  end

  test "complete corporate creation flow step-by-step", %{
    conn: conn,
    user: user,
    dept_hr: dept_hr
  } do
    # Authenticate by adding user to session
    conn = conn |> init_test_session(current_user_id: user.id)

    # Mount the page
    {:ok, view, html} = live(conn, ~p"/admin/corporate/new")

    assert html =~ "Corporate Details"
    assert html =~ "Group Code"

    # 1. Try to click Next with invalid data (e.g. empty fields)
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{
          "corporate_name" => "",
          "pincode" => "",
          "city" => "",
          "state" => "",
          "corporate_address" => ""
        }
      })
      |> render_submit(%{"action" => "next"})

    assert html =~ "can&#39;t be blank"

    # Verify no corporate is created in DB yet
    assert Repo.aggregate(Corporate, :count, :corporate_id) == 0

    # 2. Submit valid corporate details to transition to contacts step
    valid_attrs = %{
      "corporate_name" => "Acme Corp",
      "pincode" => "560001",
      "city" => "Bengaluru",
      "state" => "Karnataka",
      "corporate_address" => "123 Main Street",
      "pan_number" => "ABCDE1234F",
      "corporate_landline" => "080-12345678",
      "coporate_contact_email" => "contact@acme.com",
      "industry_type" => "Technology",
      "branch_name" => "HQ Branch",
      "helpline_no" => "1800123456"
    }

    # Submit the form with next action
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => valid_attrs
      })
      |> render_submit(%{"action" => "next"})

    # The corporate data should be stored in the database now!
    assert Repo.aggregate(Corporate, :count, :corporate_id) == 1
    corporate = Repo.one(Corporate)
    assert corporate.corporate_name == "Acme Corp"
    assert corporate.pincode == "560001"
    assert corporate.city == "Bengaluru"
    assert corporate.state == "Karnataka"

    # Tab should now switch to Corporate Contacts
    assert html =~ "Corporate Contacts"
    assert html =~ "Full Name"
    assert html =~ "Mobile Number"

    # 3. Fill in the contacts details and submit to complete the flow
    contact_attrs = %{
      "contacts" => %{
        "0" => %{
          "full_name" => "John Doe",
          "mobile_number" => "9876543210",
          "email_address" => "john@acme.com",
          "corporate_username" => "johndoe",
          "department" => to_string(dept_hr.role_id),
          "location" => "Bengaluru"
        }
      }
    }

    # Submit the contacts form
    view
    |> form("#corporate-form", %{
      "corporate" => contact_attrs
    })
    |> render_submit(%{"action" => "submit"})

    # Check redirection/navigation
    assert_redirected(view, "/admin/corporate")

    # Verify that contact user and mapping are saved
    user_in_db = Repo.get_by(Accounts.User, email_address: "john@acme.com")
    assert user_in_db != nil
    assert user_in_db.full_name == "John Doe"
    assert user_in_db.mobile_no == "9876543210"
    assert user_in_db.corporate_username == "johndoe"
    assert user_in_db.department_name == "HR"
    assert user_in_db.department_id == dept_hr.role_id
    assert user_in_db.ref_corporate_id == corporate.corporate_id
    assert user_in_db.location == "Bengaluru"

    # Verify trn_mapping_corporateid_corporatecontactsids table entry
    mapping =
      Repo.one(
        from m in "trn_mapping_corporateid_corporatecontactsids",
          select: %{
            corporate_id: m.corporate_id,
            corporatecontacts_id: m.corporatecontacts_id,
            status: m.status
          }
      )

    assert mapping.corporate_id == corporate.corporate_id
    assert mapping.corporatecontacts_id == user_in_db.id
    assert mapping.status == 1
  end

  test "saves corporate with uploaded logo", %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/new")

    # Select and upload the file
    logo_input =
      file_input(view, "#corporate-form", :logo, [
        %{
          name: "logo.png",
          content: "fake png image content",
          type: "image/png"
        }
      ])

    render_upload(logo_input, "logo.png")

    valid_attrs = %{
      "corporate_name" => "Logo Corp",
      "pincode" => "560001",
      "city" => "Bengaluru",
      "state" => "Karnataka",
      "corporate_address" => "123 Main Street",
      "pan_number" => "ABCDE1234F",
      "corporate_landline" => "080-12345678",
      "coporate_contact_email" => "contact@logo.com",
      "industry_type" => "Technology",
      "branch_name" => "HQ Branch",
      "helpline_no" => "1800123456"
    }

    # Submit the form with next action
    view
    |> form("#corporate-form", %{
      "corporate" => valid_attrs
    })
    |> render_submit(%{"action" => "next"})

    # The corporate data should be stored in the database now!
    assert Repo.aggregate(Corporate, :count, :corporate_id) == 1
    corporate = Repo.one(Corporate) |> Repo.preload(:logo)
    assert corporate.corporate_name == "Logo Corp"
    assert corporate.logo != nil
    assert corporate.logo.logo =~ "/uploads/logos/"
    assert corporate.logo.logo =~ ".png"

    # Verify that file was saved to disk
    file_path = Path.join(["priv", "static" | String.split(corporate.logo.logo, "/")])
    assert File.exists?(file_path)

    # Clean up the file
    File.rm!(file_path)
  end

  test "displays validation error for invalid PAN card format and normalizes lowercase to uppercase",
       %{conn: conn, user: user} do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/new")

    # 1. Validate with invalid PAN format
    invalid_attrs = %{
      "corporate_name" => "Acme Corp",
      "pincode" => "560001",
      "city" => "Bengaluru",
      "state" => "Karnataka",
      "corporate_address" => "123 Main Street",
      "pan_number" => "invalidpan1"
    }

    html =
      view
      |> form("#corporate-form", %{
        "corporate" => invalid_attrs
      })
      |> render_submit(%{"action" => "next"})

    assert html =~ "must be in valid PAN format"

    # 2. Check that a valid lowercase PAN is normalized and successfully saved
    valid_lowercase_attrs = %{
      "corporate_name" => "Acme Corp",
      "pincode" => "560001",
      "city" => "Bengaluru",
      "state" => "Karnataka",
      "corporate_address" => "123 Main Street",
      "pan_number" => "abcde1234f"
    }

    view
    |> form("#corporate-form", %{
      "corporate" => valid_lowercase_attrs
    })
    |> render_submit(%{"action" => "next"})

    # The corporate data should be stored in the database with normalized uppercase PAN
    corporate = Repo.one(Corporate)
    assert corporate != nil
    assert corporate.pan_number == "ABCDE1234F"
  end

  test "fails corporate creation and shows error when logo upload has errors", %{
    conn: conn,
    user: user
  } do
    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/new")

    # Select an invalid file type (e.g. .txt)
    logo_input =
      file_input(view, "#corporate-form", :logo, [
        %{
          name: "logo.txt",
          content: "text content",
          type: "text/plain"
        }
      ])

    # This will trigger client/server validation errors
    render_upload(logo_input, "logo.txt")

    valid_attrs = %{
      "corporate_name" => "Fail Corp",
      "pincode" => "560001",
      "city" => "Bengaluru",
      "state" => "Karnataka",
      "corporate_address" => "123 Main Street",
      "pan_number" => "ABCDE1234F"
    }

    # Submit the form with next action
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => valid_attrs
      })
      |> render_submit(%{"action" => "next"})

    # It should display Logo upload failed and stop creation
    assert html =~ "Logo upload failed"
    assert Repo.aggregate(Corporate, :count, :corporate_id) == 0
  end

  test "autofetches city and state when a valid 6-digit pincode is entered", %{
    conn: conn,
    user: user
  } do
    # Insert test data for state, city, pincode, and mapping
    {:ok, state} = Repo.insert(%CorporatePolicy.Corporates.State{state: "Karnataka", status: 1})
    {:ok, city} = Repo.insert(%CorporatePolicy.Corporates.City{city: "Bengaluru", status: 1})
    {:ok, pincode} = Repo.insert(%CorporatePolicy.Corporates.Pincode{pincode: 560_001, status: 1})

    {:ok, _mapping} =
      Repo.insert(%CorporatePolicy.Corporates.TrnMappingPincodeCityState{
        pincode_id: pincode.pincode_id,
        city_id: city.city_id,
        state_id: state.state_id,
        status: 1
      })

    conn = conn |> init_test_session(current_user_id: user.id)
    {:ok, view, _html} = live(conn, ~p"/admin/corporate/new")

    # Trigger form change with a matching pincode
    html =
      view
      |> form("#corporate-form", %{
        "corporate" => %{"pincode" => "560001"}
      })
      |> render_change()

    # The HTML should now be reactively updated with the fetched city and state
    assert html =~ "value=\"Bengaluru\""
    assert html =~ "value=\"Karnataka\""
  end
end
