defmodule CorporatePolicy.DataUploadServiceTest do
  use CorporatePolicy.DataCase, async: true

  alias CorporatePolicy.DataUploadService
  alias CorporatePolicy.Repo

  alias CorporatePolicy.Policies.{
    MasterInceptionDataUpload,
    MasterEndorsementDataUpload,
    TrnMappingLiveEmployee,
    TrnEndorsementDeletionLog,
    Policy
  }

  setup do
    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Test",
        last_name: "User",
        email_address: "test_upload_service@example.com",
        password: "password123",
        status: 1
      })

    corporate =
      Repo.insert!(%CorporatePolicy.Corporates.Corporate{
        corporate_name: "Test Corp",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1,
        pincode: "123456",
        city: "Test City",
        state: "Test State"
      })

    lob =
      Repo.insert!(%CorporatePolicy.Policies.LineOfBusiness{
        line_of_business_value: "Health",
        display_id: 1,
        status: 1
      })

    pt =
      Repo.insert!(%CorporatePolicy.Policies.PolicyType{
        policy_type_value: "GMC",
        display_id: 1,
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    insurer =
      Repo.insert!(%CorporatePolicy.Policies.Insurer{
        name: "Test Insurer",
        ref_md_line_of_businesses_id: lob.id,
        status: 1
      })

    fy =
      Repo.insert!(%CorporatePolicy.Policies.FinancialYear{
        year_name: "2026",
        start_date: ~D[2026-04-01],
        end_date: ~D[2027-03-31],
        status: 1
      })

    # Create a test policy
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

    {:ok, policy: policy, user: user}
  end

  test "process_upload for Inception Data saves to inception and trn_mapping_live_employees with normalized Employee relationship",
       %{
         policy: policy
       } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP001,John Doe,Male,Self,1990-01-01,34,9876543210,john@example.com,500000,2020-01-01
    """

    tmp_path = Path.join(System.tmp_dir!(), "inception_test_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    assert {:ok, _upload} =
             DataUploadService.process_upload(
               policy.id,
               "Inception Data",
               "Test Inception",
               tmp_path,
               "inception.csv"
             )

    inception_records = Repo.all(MasterInceptionDataUpload)
    assert length(inception_records) == 1
    assert Enum.at(inception_records, 0).employee_code == "EMP001"
    assert Enum.at(inception_records, 0).relationship == "Employee"

    employee_records = Repo.all(TrnMappingLiveEmployee)
    assert length(employee_records) == 1
    emp = Enum.at(employee_records, 0)
    assert emp.employee_code == "EMP001"
    assert emp.employee_name == "John Doe"
    assert emp.relationship == "Employee"
    assert emp.ref_corporate_id == policy.ref_corporate_id
    assert emp.source_type == "Inception"
  end

  test "process_upload for Endorsement Data updates existing employee record in trn_mapping_live_employees",
       %{policy: policy} do
    inception_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP002,Jane Smith,Female,Employee,1992-05-15,32,9876543211,jane@example.com,300000,2021-03-01
    """

    endorsement_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,EndNo,EndDate,EndType
    EMP002,Jane Smith,Female,Self,1992-05-15,32,9998887770,jane_updated@example.com,500000,2021-03-01,END01,2024-01-01,employee_addition
    """

    inc_path = Path.join(System.tmp_dir!(), "inc_#{policy.id}.csv")
    end_path = Path.join(System.tmp_dir!(), "end_#{policy.id}.csv")
    File.write!(inc_path, inception_csv)
    File.write!(end_path, endorsement_csv)

    DataUploadService.process_upload(
      policy.id,
      "Inception Data",
      "Inception",
      inc_path,
      "inc.csv"
    )

    DataUploadService.process_upload(
      policy.id,
      "Endorsement Data",
      "Endorsement",
      end_path,
      "end.csv"
    )

    assert length(Repo.all(MasterInceptionDataUpload)) == 1
    endorsements = Repo.all(MasterEndorsementDataUpload)
    assert length(endorsements) == 1
    end_rec = Enum.at(endorsements, 0)
    assert end_rec.employee_code == "EMP002"
    assert end_rec.relationship == "Employee"
    assert end_rec.endorsement_number == "END01"
    assert end_rec.endorsement_date == "2024-01-01"
    assert end_rec.endorsement_type == "employee_addition"

    employee_records = Repo.all(TrnMappingLiveEmployee)
    assert length(employee_records) == 1
    emp = Enum.at(employee_records, 0)
    assert emp.employee_code == "EMP002"
    assert emp.relationship == "Employee"
    assert emp.email == "jane_updated@example.com"
    assert emp.mobile_number == "9998887770"
    assert emp.sum_insured == 500_000.0
    assert emp.endorsement_number == "END01"
    assert emp.source_type == "Endorsement"
  end

  test "process_upload handles dependant deletion in Endorsement Data", %{policy: policy} do
    inception_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP004,Alice Green,Female,Self,1985-04-12,39,9876500001,alice@example.com,500000,2018-01-01
    EMP004,Tommy Green,Male,Spouse,1984-06-20,40,9876500002,tommy@example.com,500000,2018-01-01
    """

    endorsement_deletion_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,EndNo,EndDate,EndType
    EMP004,Tommy Green,Male,Spouse,1984-06-20,40,9876500002,tommy@example.com,500000,2018-01-01,END02,2024-02-01,dependent_deletion
    """

    inc_path = Path.join(System.tmp_dir!(), "inc_del_#{policy.id}.csv")
    del_path = Path.join(System.tmp_dir!(), "end_del_#{policy.id}.csv")
    File.write!(inc_path, inception_csv)
    File.write!(del_path, endorsement_deletion_csv)

    DataUploadService.process_upload(
      policy.id,
      "Inception Data",
      "Inception",
      inc_path,
      "inc.csv"
    )

    DataUploadService.process_upload(
      policy.id,
      "Endorsement Data",
      "Deletion",
      del_path,
      "del.csv"
    )

    spouse = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP004", relationship: "Spouse")
    assert spouse.status == "inactive"
    refute is_nil(spouse.deleted_at)

    employee =
      Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP004", relationship: "Employee")

    assert employee.status == "active"
    assert is_nil(employee.deleted_at)

    deletion_logs = Repo.all(TrnEndorsementDeletionLog)
    assert length(deletion_logs) == 1
    log = Enum.at(deletion_logs, 0)
    assert log.employee_code == "EMP004"
    assert log.relationship == "Spouse"
    assert log.deletion_category == "Dependant Deletion"
  end

  test "process_upload handles primary employee deletion in Endorsement Data", %{
    policy: policy
  } do
    inception_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP005,Charlie Brown,Male,Self,1995-09-09,28,9876500003,charlie@example.com,400000,2022-05-01
    """

    employee_deletion_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,EndNo,EndDate,EndType
    EMP005,Charlie Brown,Male,Self,1995-09-09,28,9876500003,charlie@example.com,400000,2022-05-01,END03,2024-03-01,employee_deletion
    """

    inc_path = Path.join(System.tmp_dir!(), "inc_invalid_#{policy.id}.csv")
    invalid_path = Path.join(System.tmp_dir!(), "invalid_del_#{policy.id}.csv")
    File.write!(inc_path, inception_csv)
    File.write!(invalid_path, employee_deletion_csv)

    DataUploadService.process_upload(
      policy.id,
      "Inception Data",
      "Inception",
      inc_path,
      "inc.csv"
    )

    DataUploadService.process_upload(
      policy.id,
      "Endorsement Data",
      "Deletion",
      invalid_path,
      "invalid.csv"
    )

    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP005")
    assert emp.status == "inactive"
    refute is_nil(emp.deleted_at)

    log = Repo.one!(TrnEndorsementDeletionLog)
    assert log.employee_code == "EMP005"
    assert log.relationship == "Employee"
    assert log.endorsement_type == "employee_deletion"
    assert log.deletion_category == "Employee Deletion"
  end

  test "process_upload raises error when relationship is blank or missing", %{
    policy: policy
  } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP003,Bob White,Male,,1988-12-10,35,9123456789,bob@example.com,400000,2019-06-01
    """

    tmp_path = Path.join(System.tmp_dir!(), "missing_rel_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    assert_raise RuntimeError, ~r/Invalid data: Relationship is missing for record/, fn ->
      DataUploadService.process_upload(
        policy.id,
        "Inception Data",
        "Missing Relationship",
        tmp_path,
        "missing_rel.csv"
      )
    end
  end

  test "process_upload raises error when email is blank or missing in Inception Data", %{
    policy: policy
  } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP003,Bob White,Male,Employee,1988-12-10,35,9123456789,,400000,2019-06-01
    """

    tmp_path = Path.join(System.tmp_dir!(), "missing_email_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    assert_raise RuntimeError, ~r/Invalid data: Email Address is missing for record/, fn ->
      DataUploadService.process_upload(
        policy.id,
        "Inception Data",
        "Missing Email",
        tmp_path,
        "missing_email.csv"
      )
    end
  end

  test "process_upload raises error when email is blank or missing in Endorsement Data", %{
    policy: policy
  } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,End endorsement_number,Endorsement Date,Endorsement Type,dol,card_no,designation
    EMP003,Bob White,Male,Employee,1988-12-10,35,9123456789,,400000,2019-06-01,END01,2026-08-19,employee_addition,,,
    """

    tmp_path = Path.join(System.tmp_dir!(), "missing_email_end_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    assert_raise RuntimeError, ~r/Invalid data: Email Address is missing for record/, fn ->
      DataUploadService.process_upload(
        policy.id,
        "Endorsement Data",
        "Missing Email",
        tmp_path,
        "missing_email_end.csv"
      )
    end
  end

  test "is_testuser syncs from MasterInceptionDataUpload to TrnMappingLiveEmployee on upload", %{
    policy: policy
  } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP888,Test Inception,Male,Employee,1990-01-01,34,9876543210,test@example.com,500000,2020-01-01
    """

    tmp_path = Path.join(System.tmp_dir!(), "inception_sync_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    # First upload (creates records with is_testuser = 0)
    {:ok, _} =
      DataUploadService.process_upload(
        policy.id,
        "Inception Data",
        "First",
        tmp_path,
        "inception.csv"
      )

    # Assert initial is_testuser is 0
    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP888")
    assert emp.is_testuser == 0

    # Simulate manual setting of is_testuser in master table
    Repo.update_all(MasterInceptionDataUpload, set: [is_testuser: 1])

    # Re-upload (updates trn_mapping_live_employees and triggers sync)
    {:ok, _} =
      DataUploadService.process_upload(
        policy.id,
        "Inception Data",
        "Second",
        tmp_path,
        "inception.csv"
      )

    # Assert synced is_testuser is now 1
    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP888")
    assert emp.is_testuser == 1
  end

  test "is_testuser syncs from MasterEndorsementDataUpload to TrnMappingLiveEmployee on upload",
       %{policy: policy} do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,Endorsement No,Endorsement Date,Endorsement Type,Date of Leaving,Card No,Designation
    EMP999,Test Endorsement,Male,Employee,1990-01-01,34,9876543210,test@example.com,500000,2020-01-01,END01,2026-08-19,employee_addition,,,
    """

    tmp_path = Path.join(System.tmp_dir!(), "endorsement_sync_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    # First upload (creates records with is_testuser = 0)
    {:ok, _} =
      DataUploadService.process_upload(
        policy.id,
        "Endorsement Data",
        "First",
        tmp_path,
        "endorsement.csv"
      )

    # Assert initial is_testuser is 0
    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP999")
    assert emp.is_testuser == 0

    # Simulate manual setting of is_testuser in master table
    Repo.update_all(MasterEndorsementDataUpload, set: [is_testuser: 1])

    # Re-upload (updates trn_mapping_live_employees and triggers sync)
    {:ok, _} =
      DataUploadService.process_upload(
        policy.id,
        "Endorsement Data",
        "Second",
        tmp_path,
        "endorsement.csv"
      )

    # Assert synced is_testuser is now 1
    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP999")
    assert emp.is_testuser == 1
  end
end
