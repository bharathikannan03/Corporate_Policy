defmodule CorporatePolicyWeb.UploadControllerTest do
  use CorporatePolicyWeb.ConnCase, async: false

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Policies.LineOfBusiness
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.Insurer
  alias CorporatePolicy.Policies.FinancialYear
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Policies.TrnMappingLiveEmployee

  setup do
    # Create an admin user for authentication
    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Admin",
        last_name: "User",
        email_address: "admin_test_upload@gmail.com",
        password: "password123",
        status: 1
      })

    # Create corporate and policy dependencies to satisfy foreign keys
    corporate =
      Repo.insert!(%Corporate{
        corporate_name: "Test Corporate",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1
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
        policy_number: "POL-TEST-001",
        corporate_name: corporate.corporate_name,
        ref_corporate_id: corporate.corporate_id,
        ref_md_line_of_businesses_id: lob.id,
        line_of_business: lob.line_of_business_value,
        ref_md_policy_types_id: policy_type.id,
        policy_type: policy_type.policy_type_value,
        ref_select_insurer_id: insurer.id,
        select_insurer: insurer.name,
        ref_fy_year_id: fy.id,
        status: 1,
        created_by: user.id,
        updated_by: user.id
      })

    # Create an active employee for authentication
    employee =
      Repo.insert!(%TrnMappingLiveEmployee{
        ref_policy_id: policy.id,
        ref_corporate_id: corporate.corporate_id,
        employee_code: "EMP888",
        employee_name: "Test Employee",
        relationship: "Employee",
        gender: "Male",
        dob: "1990-01-01",
        status: "active",
        source_type: "Inception"
      })

    # Create dummy files under priv/static/uploads
    uploads_dir = Path.expand("priv/static/uploads")
    samples_dir = Path.join(uploads_dir, "samples")

    File.mkdir_p!(samples_dir)

    test_file_path = Path.join(uploads_dir, "test_file.txt")
    test_sample_path = Path.join(samples_dir, "test_sample.txt")

    File.write!(test_file_path, "secret_content")
    File.write!(test_sample_path, "sample_content")

    on_exit(fn ->
      File.rm(test_file_path)
      File.rm(test_sample_path)
    end)

    {:ok, user: user, employee: employee}
  end

  test "unauthenticated request to standard upload returns 401", %{conn: conn} do
    conn = get(conn, "/uploads/test_file.txt")
    assert response(conn, 401) =~ "Unauthorized"
  end

  test "unauthenticated request to sample upload succeeds (200)", %{conn: conn} do
    conn = get(conn, "/uploads/samples/test_sample.txt")
    assert response(conn, 200) == "sample_content"
  end

  test "authenticated user (Admin) request to standard upload succeeds (200)", %{
    conn: conn,
    user: user
  } do
    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get("/uploads/test_file.txt")

    assert response(conn, 200) == "secret_content"
    assert [content_type] = get_resp_header(conn, "content-type")
    assert content_type =~ "text/plain"
  end

  test "authenticated employee request to standard upload succeeds (200)", %{
    conn: conn,
    employee: employee
  } do
    conn =
      conn
      |> init_test_session(current_employee_id: employee.id)
      |> get("/uploads/test_file.txt")

    assert response(conn, 200) == "secret_content"
  end

  test "authenticated request to non-existent file returns 404", %{conn: conn, user: user} do
    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get("/uploads/does_not_exist.txt")

    assert response(conn, 404) =~ "Not Found"
  end

  test "directory traversal attempts return 403 or 404", %{conn: conn, user: user} do
    conn =
      conn
      |> init_test_session(current_user_id: user.id)
      |> get("/uploads/../forbidden.txt")

    assert conn.status in [403, 404]
  end
end
