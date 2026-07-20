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
      Repo.insert!(%CorporatePolicy.Policies.Corporate{
        corporate_name: "Test Corp",
        corporate_address: "123 Test Street",
        status: 1,
        corporate_status: 1
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

  test "process_upload for Inception Data saves to inception and trn_mapping_live_employees", %{
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

    employee_records = Repo.all(TrnMappingLiveEmployee)
    assert length(employee_records) == 1
    emp = Enum.at(employee_records, 0)
    assert emp.employee_code == "EMP001"
    assert emp.employee_name == "John Doe"
    assert emp.ref_corporate_id == policy.ref_corporate_id
    assert emp.source_type == "Inception"
  end

  test "process_upload for Endorsement Data updates existing employee record in trn_mapping_live_employees",
       %{policy: policy} do
    inception_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP002,Jane Smith,Female,Self,1992-05-15,32,9876543211,jane@example.com,300000,2021-03-01
    """

    endorsement_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,EndNo,EndDate,EndType
    EMP002,Jane Smith,Female,Self,1992-05-15,32,9998887770,jane_updated@example.com,500000,2021-03-01,END01,2024-01-01,Addition
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
    assert length(Repo.all(MasterEndorsementDataUpload)) == 1

    employee_records = Repo.all(TrnMappingLiveEmployee)
    assert length(employee_records) == 1
    emp = Enum.at(employee_records, 0)
    assert emp.employee_code == "EMP002"
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
    EMP004,Tommy Green,Male,Spouse,1984-06-20,40,9876500002,tommy@example.com,500000,2018-01-01,END02,2024-02-01,Dependant Deletion
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

    employee = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP004", relationship: "Self")
    assert employee.status == "active"
    assert is_nil(employee.deleted_at)

    deletion_logs = Repo.all(TrnEndorsementDeletionLog)
    assert length(deletion_logs) == 1
    log = Enum.at(deletion_logs, 0)
    assert log.employee_code == "EMP004"
    assert log.relationship == "Spouse"
    assert log.deletion_category == "Dependant Deletion"
  end

  test "process_upload throws error on deletion record with relationship = Self", %{
    policy: policy
  } do
    inception_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
    EMP005,Charlie Brown,Male,Self,1995-09-09,28,9876500003,charlie@example.com,400000,2022-05-01
    """

    invalid_deletion_csv = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ,EndNo,EndDate,EndType
    EMP005,Charlie Brown,Male,Self,1995-09-09,28,9876500003,charlie@example.com,400000,2022-05-01,END03,2024-03-01,Employee Deletion
    """

    inc_path = Path.join(System.tmp_dir!(), "inc_invalid_#{policy.id}.csv")
    invalid_path = Path.join(System.tmp_dir!(), "invalid_del_#{policy.id}.csv")
    File.write!(inc_path, inception_csv)
    File.write!(invalid_path, invalid_deletion_csv)

    DataUploadService.process_upload(
      policy.id,
      "Inception Data",
      "Inception",
      inc_path,
      "inc.csv"
    )

    assert_raise RuntimeError,
                 ~r/Invalid data: Deletion requested for employee relationship 'Self'/,
                 fn ->
                   DataUploadService.process_upload(
                     policy.id,
                     "Endorsement Data",
                     "Invalid Deletion",
                     invalid_path,
                     "invalid.csv"
                   )
                 end

    # Confirm employee is still active and no deletion log was recorded
    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP005")
    assert emp.status == "active"
    assert is_nil(emp.deleted_at)
    assert length(Repo.all(TrnEndorsementDeletionLog)) == 0
  end

  test "process_upload handles whitespaces and defaults blank relationship to Self", %{
    policy: policy
  } do
    csv_content = """
    Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile,Email,Sum Insured,DOJ
      EMP003  ,  Bob White  ,Male,,1988-12-10,35,9123456789,bob@example.com,400000,2019-06-01
    """

    tmp_path = Path.join(System.tmp_dir!(), "trim_test_#{policy.id}.csv")
    File.write!(tmp_path, csv_content)

    assert {:ok, _upload} =
             DataUploadService.process_upload(
               policy.id,
               "Inception Data",
               "Trim Inception",
               tmp_path,
               "trim.csv"
             )

    emp = Repo.get_by!(TrnMappingLiveEmployee, employee_code: "EMP003")
    assert emp.employee_name == "Bob White"
    assert emp.relationship == "Self"
  end
end
