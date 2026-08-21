defmodule CorporatePolicy.Workers.CdStatementImportWorkerTest do
  use CorporatePolicy.DataCase, async: false
  use Oban.Testing, repo: CorporatePolicy.Repo

  alias CorporatePolicy.Repo
  alias CorporatePolicy.CdStatements

  alias CorporatePolicy.Policies.{
    Policy,
    LineOfBusiness,
    PolicyType,
    Insurer,
    MasterCdAccount,
    MasterCdStatementDataUpload
  }

  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Workers.CdStatementImportWorker

  setup do
    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Test",
        last_name: "User",
        email_address: "cd_worker_test@example.com",
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
        status: 1,
        ref_md_line_of_businesses_id: lob.id
      })

    insurer =
      Repo.insert!(%Insurer{
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

    policy =
      Repo.insert!(%Policy{
        ref_corporate_id: corporate.corporate_id,
        ref_md_line_of_businesses_id: lob.id,
        ref_md_policy_types_id: pt.id,
        ref_select_insurer_id: insurer.id,
        ref_fy_year_id: fy.id,
        corporate_name: "Test Corp",
        line_of_business: "Health",
        policy_type: "GMC",
        select_insurer: "Test Insurer",
        policy_number: "332204/48/2023/1119",
        status: 1
      })

    cd_account =
      Repo.insert!(%MasterCdAccount{
        cd_name: "CD Account 1",
        cd_number: "CD12345",
        corporate_id: corporate.corporate_id,
        corporate_name: corporate.corporate_name,
        policy_id: policy.id,
        policy_number: policy.policy_number,
        insurer_id: policy.ref_select_insurer_id,
        insurer_name: policy.select_insurer,
        status: 1
      })

    csv_dir = Path.expand("tmp/tests_cd")
    File.mkdir_p!(csv_dir)

    # Generate relative/absolute path mock info
    filename = "valid_cd.csv"
    dest_path = Path.join(csv_dir, filename)

    File.write!(
      dest_path,
      """
      particular,transaction_type,employee_count,dependant_count,policy_endorsement_no,endorsement_issued_date,debit_amount,credit_amount,bank_name,cheque_no,policy_number,remark
      Opening Balance,Payment Received,10,20,112233,19-08-2026,,500000,ICICI Bank,123456,332204/48/2023/1119,None
      """
    )

    invalid_dest_path = Path.join(csv_dir, "invalid_cd.csv")

    File.write!(
      invalid_dest_path,
      """
      particular,transaction_type,employee_count,dependant_count,policy_endorsement_no,endorsement_issued_date,debit_amount,credit_amount,bank_name,cheque_no,policy_number,remark
      Opening Balance,Payment Received,10,20,112233,19-08-2026,,500000,ICICI Bank,123456,WRONG-POLICY,None
      """
    )

    # Move files to static uploads so that worker path-mapping works
    static_dest = "priv/static/uploads/cd_statements/valid_cd.csv"
    File.mkdir_p!(Path.dirname(static_dest))
    File.cp!(dest_path, static_dest)

    static_invalid_dest = "priv/static/uploads/cd_statements/invalid_cd.csv"
    File.cp!(invalid_dest_path, static_invalid_dest)

    on_exit(fn ->
      File.rm_rf!(csv_dir)
      File.rm(static_dest)
      File.rm(static_invalid_dest)
    end)

    {:ok,
     user: user,
     policy: policy,
     corporate: corporate,
     cd_account: cd_account,
     valid_path: "/uploads/cd_statements/valid_cd.csv",
     invalid_path: "/uploads/cd_statements/invalid_cd.csv"}
  end

  test "CD statement upload background enqueues job and CdStatementImportWorker processes it", %{
    user: user,
    policy: policy,
    corporate: corporate,
    valid_path: path
  } do
    # Subscribe to progress channel
    Phoenix.PubSub.subscribe(CorporatePolicy.PubSub, "cd_uploads:#{policy.id}")

    attrs = %{
      "corporate_id" => to_string(corporate.corporate_id),
      "cd_number" => "CD12345"
    }

    file_info = %{
      public_path: path,
      original_file_name: "valid_cd.csv",
      absolute_path: Path.expand("priv/static" <> path)
    }

    # Queue background processing
    assert {:ok, upload} =
             CdStatements.create_policy_cd_statement_upload_background(
               policy,
               attrs,
               file_info,
               user.id
             )

    assert upload.status == 0

    assert_enqueued(
      worker: CdStatementImportWorker,
      args: %{"upload_id" => upload.id, "user_id" => user.id}
    )

    # Execute
    assert :ok =
             perform_job(CdStatementImportWorker, %{
               "upload_id" => upload.id,
               "user_id" => user.id
             })

    # Verify PubSub
    upload_id = upload.id
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 0, progress: 0}}
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 0, progress: 100}}
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 1, progress: 100}}

    # Verify status completed (1)
    reloaded = Repo.reload!(upload)
    assert reloaded.status == 1

    # Verify record created
    records = Repo.all(MasterCdStatementDataUpload)
    assert length(records) == 1
    assert hd(records).policy_number == "332204/48/2023/1119"
  end

  test "CD Statement worker records errors when policy number mismatch occurs", %{
    user: user,
    policy: policy,
    corporate: corporate,
    invalid_path: path
  } do
    Phoenix.PubSub.subscribe(CorporatePolicy.PubSub, "cd_uploads:#{policy.id}")

    attrs = %{
      "corporate_id" => to_string(corporate.corporate_id),
      "cd_number" => "CD12345"
    }

    file_info = %{
      public_path: path,
      original_file_name: "invalid_cd.csv",
      absolute_path: Path.expand("priv/static" <> path)
    }

    {:ok, upload} =
      CdStatements.create_policy_cd_statement_upload_background(
        policy,
        attrs,
        file_info,
        user.id
      )

    # Execute
    assert :ok =
             perform_job(CdStatementImportWorker, %{
               "upload_id" => upload.id,
               "user_id" => user.id
             })

    # Since it had validation error (policy number mismatch), status should end up as 2 (Failed/Errors)
    reloaded = Repo.reload!(upload)
    assert reloaded.status == 2

    # Errors should be logged in the database table
    errors = CdStatements.get_upload_errors(upload.id)
    assert length(errors) == 1
    assert hd(errors).errors == "Policy number does not match the current policy"
  end
end
