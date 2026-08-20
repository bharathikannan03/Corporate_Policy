defmodule CorporatePolicyWeb.Employee.EmployeeSessionControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false
  import Swoosh.TestAssertions

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.TrnMappingLiveEmployee
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Policies.LineOfBusiness
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.Insurer
  alias CorporatePolicy.Policies.FinancialYear

  setup do
    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Test",
        last_name: "User",
        email_address: "test_emp_controller@example.com",
        password: "password123",
        status: 1
      })

    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Test Corp",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1,
        pincode: "123456",
        city: "Test City",
        state: "Test State"
      })

    lob =
      Repo.insert!(%LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    pt =
      Repo.insert!(%PolicyType{
        policy_type_value: "GMC",
        display_id: 1,
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    insurer =
      Repo.insert!(%Insurer{
        name: "Test Insurer",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    fy =
      Repo.insert!(%FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    policy =
      Repo.insert!(%Policy{
        policy_number: "POL-1001",
        corporate_name: corporate.corporate_name,
        ref_corporate_id: corporate.corporate_id,
        ref_md_line_of_businesses_id: lob.id,
        line_of_business: lob.line_of_business_value,
        ref_md_policy_types_id: pt.id,
        policy_type: pt.policy_type_value,
        ref_select_insurer_id: insurer.id,
        select_insurer: insurer.name,
        ref_fy_year_id: fy.id,
        status: 1,
        created_by: user.id,
        updated_by: user.id
      })

    {:ok, policy: policy, corporate: corporate}
  end

  test "renders the employee login page", %{conn: conn} do
    conn = get(conn, ~p"/employee/login")
    assert html_response(conn, 200) =~ "Employee Login"
  end

  test "request OTP for test user uses default OTP and does not send SMS", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP007",
        employee_name: "James Bond",
        gender: "Male",
        relationship: "Employee",
        dob: "1980-11-11",
        mobile_number: "9999988888",
        status: "active",
        is_testuser: 1
      })

    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9999988888"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
             "OTP sent successfully. Use default OTP"

    assert get_session(conn, :employee_login_otp) == "123456"
    assert get_session(conn, :employee_login_employee_id) == employee.id
  end

  test "login as test user works with default OTP", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP007",
        employee_name: "James Bond",
        gender: "Male",
        relationship: "Employee",
        dob: "1980-11-11",
        mobile_number: "9999988888",
        status: "active",
        is_testuser: 1
      })

    expires_at = DateTime.utc_now() |> DateTime.add(300, :second)

    conn =
      conn
      |> init_test_session(
        employee_login_otp: "123456",
        employee_login_mobile: "9999988888",
        employee_login_employee_id: employee.id,
        employee_login_otp_expires_at: DateTime.to_iso8601(expires_at)
      )
      |> post(~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "login",
          "mobile_number" => "9999988888",
          "otp" => "123456"
        }
      })

    assert redirected_to(conn) == "/employee/dashboard"
    assert get_session(conn, :current_employee_id) == employee.id
  end

  test "request OTP for production employee sends email OTP", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    _employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP001",
        employee_name: "John Doe",
        gender: "Male",
        relationship: "Employee",
        dob: "1990-01-01",
        mobile_number: "9876543210",
        email: "john_doe_test@example.com",
        status: "active",
        is_testuser: 0
      })

    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9876543210"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
             "OTP has been sent to your registered email address"

    # Validate that a secure 6-digit OTP is set
    session_otp = get_session(conn, :employee_login_otp)
    assert String.length(session_otp) == 6
    assert session_otp != "123456"

    # Assert email sent to the employee's email address
    assert_email_sent(
      to: {"John Doe", "john_doe_test@example.com"},
      subject: "Your Employee Portal Login OTP"
    )
  end

  test "login with correct secure OTP succeeds and incorrect OTP fails", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP001",
        employee_name: "John Doe",
        gender: "Male",
        relationship: "Employee",
        dob: "1990-01-01",
        mobile_number: "9876543210",
        status: "active",
        is_testuser: 0
      })

    expires_at = DateTime.utc_now() |> DateTime.add(300, :second)

    # Put a specific generated OTP in session
    conn_base =
      conn
      |> init_test_session(
        employee_login_otp: "583921",
        employee_login_mobile: "9876543210",
        employee_login_employee_id: employee.id,
        employee_login_otp_expires_at: DateTime.to_iso8601(expires_at)
      )

    # 1. Try incorrect OTP
    conn_fail =
      post(conn_base, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "login",
          "mobile_number" => "9876543210",
          "otp" => "000000"
        }
      })

    assert Phoenix.Flash.get(conn_fail.assigns.flash, :error) =~ "Invalid or expired OTP"
    assert get_session(conn_fail, :current_employee_id) == nil

    # 2. Try correct OTP
    conn_success =
      post(conn_base, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "login",
          "mobile_number" => "9876543210",
          "otp" => "583921"
        }
      })

    assert redirected_to(conn_success) == "/employee/dashboard"
    assert get_session(conn_success, :current_employee_id) == employee.id
  end

  test "request OTP with invalid mobile number returns error flash", %{conn: conn} do
    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "12345"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Enter a valid 10-digit mobile number"
    assert get_session(conn, :employee_login_otp) == nil
  end

  test "request OTP for unmapped/unauthorized mobile number returns error flash", %{conn: conn} do
    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9111122222"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
             "Mobile number is not mapped to an active employee"

    assert get_session(conn, :employee_login_otp) == nil
  end

  test "request OTP for inactive employee returns error flash", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    _employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP002",
        employee_name: "Inactive User",
        gender: "Female",
        relationship: "Employee",
        dob: "1992-05-15",
        mobile_number: "9876543212",
        status: "inactive",
        is_testuser: 0
      })

    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9876543212"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
             "Mobile number is not mapped to an active employee"

    assert get_session(conn, :employee_login_otp) == nil
  end

  test "request OTP for invalid relationship (e.g. Spouse) returns error flash", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    _employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP003",
        employee_name: "Spouse User",
        gender: "Female",
        relationship: "Spouse",
        dob: "1994-04-04",
        mobile_number: "9876543213",
        status: "active",
        is_testuser: 0
      })

    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9876543213"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
             "Mobile number is not mapped to an active employee"

    assert get_session(conn, :employee_login_otp) == nil
  end

  test "login with expired OTP fails", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP001",
        employee_name: "John Doe",
        gender: "Male",
        relationship: "Employee",
        dob: "1990-01-01",
        mobile_number: "9876543210",
        status: "active",
        is_testuser: 0
      })

    expires_at = DateTime.utc_now() |> DateTime.add(-5, :second)

    conn =
      conn
      |> init_test_session(
        employee_login_otp: "583921",
        employee_login_mobile: "9876543210",
        employee_login_employee_id: employee.id,
        employee_login_otp_expires_at: DateTime.to_iso8601(expires_at)
      )
      |> post(~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "login",
          "mobile_number" => "9876543210",
          "otp" => "583921"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid or expired OTP"
    assert get_session(conn, :current_employee_id) == nil
  end

  defmodule FailingMailerAdapter do
    @behaviour Swoosh.Adapter
    @impl true
    def deliver(_email, _config), do: {:error, :smtp_error}
    @impl true
    def validate_config(_config), do: :ok
  end

  test "request OTP for production employee with failing Mailer sets error flash", %{
    conn: conn,
    policy: policy,
    corporate: corporate
  } do
    _employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP001",
        employee_name: "John Doe",
        gender: "Male",
        relationship: "Employee",
        dob: "1990-01-01",
        mobile_number: "9876543210",
        email: "john_doe_test@example.com",
        status: "active",
        is_testuser: 0
      })

    original_config = Application.get_env(:corporate_policy, CorporatePolicy.Mailer)
    Application.put_env(:corporate_policy, CorporatePolicy.Mailer, adapter: FailingMailerAdapter)

    on_exit(fn ->
      Application.put_env(:corporate_policy, CorporatePolicy.Mailer, original_config)
    end)

    conn =
      post(conn, ~p"/employee/login", %{
        "employee_auth" => %{
          "action" => "request_otp",
          "mobile_number" => "9876543210"
        }
      })

    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Failed to send OTP email"
    assert get_session(conn, :employee_login_otp) == nil
  end
end
