defmodule CorporatePolicy.Workers.CdStatementImportWorker do
  use Oban.Worker, queue: :uploads, max_attempts: 1

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyCdStatement
  alias CorporatePolicy.CdStatements

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"upload_id" => upload_id, "user_id" => user_id}}) do
    case Repo.get(MasterPolicyCdStatement, upload_id) do
      nil ->
        Logger.error("CdStatementImportWorker: upload not found (ID: #{upload_id})")
        {:error, "Upload not found"}

      upload ->
        policy_id = upload.policy_id || "global"
        # Broadcast starting progress (0% progress, status 0 = Processing)
        broadcast_progress(policy_id, upload_id, 0, 0)

        progress_callback = fn percent ->
          broadcast_progress(policy_id, upload_id, 0, percent)
        end

        try do
          # absolute path of the uploaded file
          relative_path = String.trim_leading(upload.data_upload_file, "/")
          absolute_path = Path.expand(Path.join(["priv", "static", relative_path]))

          result =
            CdStatements.process_cd_statement_upload_file(
              upload,
              absolute_path,
              user_id,
              progress_callback
            )

          broadcast_progress(policy_id, upload_id, result.upload.status, 100)
          :ok
        rescue
          e ->
            error_msg = Exception.message(e)
            Logger.error("CdStatementImportWorker failed for upload #{upload_id}: #{error_msg}")

            # Mark status as 2 (Failed/Errors)
            upload
            |> Ecto.Changeset.change(status: 2)
            |> Repo.update!()

            broadcast_progress(policy_id, upload_id, 2, 100)
            {:ok, %{status: :failed, error: error_msg}}
        end
    end
  end

  defp broadcast_progress(policy_id, upload_id, status, progress) do
    Phoenix.PubSub.broadcast(
      CorporatePolicy.PubSub,
      "cd_uploads:#{policy_id}",
      {:upload_update, %{upload_id: upload_id, status: status, progress: progress}}
    )
  end
end
