defmodule CorporatePolicy.Workers.CsvImportWorker do
  use Oban.Worker, queue: :uploads, max_attempts: 1

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyDataUpload
  alias CorporatePolicy.DataUploadService

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"upload_id" => upload_id}}) do
    case Repo.get(MasterPolicyDataUpload, upload_id) do
      nil ->
        Logger.error("CsvImportWorker: upload not found (ID: #{upload_id})")
        {:error, "Upload not found"}

      upload ->
        policy_id = upload.policy_id
        # Broadcast starting progress (0% progress, status 1 = Processing)
        broadcast_progress(policy_id, upload_id, 1, 0)

        # Update status in DB to 1 (Processing)
        upload
        |> Ecto.Changeset.change(status: 1)
        |> Repo.update!()

        progress_callback = fn percent ->
          broadcast_progress(policy_id, upload_id, 1, percent)
        end

        try do
          # Run the file processing inside a database transaction to ensure atomicity
          Repo.transaction(fn ->
            DataUploadService.process_file_with_progress(
              upload.data_type,
              upload.file_path,
              policy_id,
              upload.created_by,
              upload.id,
              progress_callback
            )
          end)

          # Update status in DB to 2 (Completed)
          upload
          |> Ecto.Changeset.change(status: 2)
          |> Repo.update!()

          broadcast_progress(policy_id, upload_id, 2, 100)
          :ok
        rescue
          e ->
            error_msg =
              case e do
                %RuntimeError{message: msg} -> msg
                _ -> Exception.message(e)
              end

            Logger.error("CsvImportWorker failed for upload #{upload_id}: #{error_msg}")

            # Append error details to the remark field and mark status as 3 (Failed)
            new_remark =
              if upload.remark && upload.remark != "" do
                "#{upload.remark} (Error: #{error_msg})"
              else
                "Error: #{error_msg}"
              end
              |> String.slice(0, 99)

            upload
            |> Ecto.Changeset.change(status: 3, remark: new_remark)
            |> Repo.update!()

            broadcast_progress(policy_id, upload_id, 3, 100)
            {:ok, %{status: :failed, error: error_msg}}
        end
    end
  end

  defp broadcast_progress(policy_id, upload_id, status, progress) do
    Phoenix.PubSub.broadcast(
      CorporatePolicy.PubSub,
      "policy_uploads:#{policy_id}",
      {:upload_update, %{upload_id: upload_id, status: status, progress: progress}}
    )
  end
end
