defmodule CorporatePolicy.Workers.CsvImportWorkerTest do
  use CorporatePolicy.DataCase, async: false
  use Oban.Testing, repo: CorporatePolicy.Repo

  alias CorporatePolicy.Repo
  alias CorporatePolicy.DataUploadService

  alias CorporatePolicy.Policies.{
    Policy,
    LineOfBusiness,
    PolicyType,
    Insurer,
    MasterInceptionDataUpload,
    TrnMappingLiveEmployee
  }

  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Workers.CsvImportWorker

  setup do
    # Set up PubSub subscription
    Phoenix.PubSub.subscribe(CorporatePolicy.PubSub, "policy_uploads:all")

    user =
      Repo.insert!(%CorporatePolicy.Accounts.User{
        first_name: "Test",
        last_name: "User",
        email_address: "worker_test@example.com",
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
        status: 1
      })

    # Create a valid Inception Data CSV file
    csv_dir = Path.expand("tmp/tests")
    File.mkdir_p!(csv_dir)
    valid_csv_path = Path.join(csv_dir, "valid_inception.csv")

    File.write!(
      valid_csv_path,
      """
      Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile Number,Email,Sum Insured,DOJ
      EMP101,Worker Doe,Male,Employee,1990-01-01,36,9876543210,worker_doe@example.com,500000,2020-01-01
      """
    )

    invalid_csv_path = Path.join(csv_dir, "invalid_inception.csv")

    File.write!(
      invalid_csv_path,
      """
      Employee Code,Employee Name,Gender,Relationship,DOB,Age,Mobile Number,Email,Sum Insured,DOJ
      EMP102,Bad Employee,Male,Employee,1990-01-01,36,9876543210,,500000,2020-01-01
      """
    )

    on_exit(fn ->
      File.rm_rf!(csv_dir)
    end)

    {:ok, user: user, policy: policy, valid_csv: valid_csv_path, invalid_csv: invalid_csv_path}
  end

  test "process_upload_background queues an Oban job and CsvImportWorker processes it", %{
    user: user,
    policy: policy,
    valid_csv: csv_path
  } do
    # Subscribe to policy progress specifically
    Phoenix.PubSub.subscribe(CorporatePolicy.PubSub, "policy_uploads:#{policy.id}")

    # 1. Trigger background processing
    assert {:ok, upload} =
             DataUploadService.process_upload_background(
               policy.id,
               "Inception Data",
               "Test upload",
               csv_path,
               "valid_inception.csv",
               user.id
             )

    assert upload.status == 0

    # Assert job is enqueued
    assert_enqueued(worker: CsvImportWorker, args: %{"upload_id" => upload.id})

    # 2. Run the job
    assert :ok = perform_job(CsvImportWorker, %{"upload_id" => upload.id})

    # Verify PubSub messages were broadcasted
    upload_id = upload.id
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 1, progress: 0}}
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 1, progress: 100}}
    assert_receive {:upload_update, %{upload_id: ^upload_id, status: 2, progress: 100}}

    # Verify data in database
    assert Repo.reload!(upload).status == 2

    inception_rec =
      Repo.get_by(MasterInceptionDataUpload, ref_policy_id: policy.id, employee_code: "EMP101")

    assert inception_rec
    assert inception_rec.email == "worker_doe@example.com"

    live_rec =
      Repo.get_by(TrnMappingLiveEmployee, ref_policy_id: policy.id, employee_code: "EMP101")

    assert live_rec
  end

  test "CsvImportWorker handles validation failures gracefully and marks upload status as failed",
       %{
         user: user,
         policy: policy,
         invalid_csv: csv_path
       } do
    Phoenix.PubSub.subscribe(CorporatePolicy.PubSub, "policy_uploads:#{policy.id}")

    {:ok, upload} =
      DataUploadService.process_upload_background(
        policy.id,
        "Inception Data",
        "Test invalid upload",
        csv_path,
        "invalid_inception.csv",
        user.id
      )

    # Perform the job
    assert {:ok, %{status: :failed, error: _}} =
             perform_job(CsvImportWorker, %{"upload_id" => upload.id})

    # Verify status is marked as Failed (3) and remark holds error details
    reloaded = Repo.reload!(upload)
    assert reloaded.status == 3
    assert String.contains?(reloaded.remark, "Email Address is missing")
  end
end
