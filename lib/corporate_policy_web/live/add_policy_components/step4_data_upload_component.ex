defmodule CorporatePolicyWeb.Step4DataUploadComponent do
  use CorporatePolicyWeb, :live_component
  import Ecto.Query

  @impl true
  def update(assigns, socket) do
    # Fetch existing uploads for the policy
    uploads_list =
      if assigns[:policy] do
        CorporatePolicy.Repo.all(
          from u in CorporatePolicy.Policies.MasterPolicyDataUpload,
            where: u.policy_id == ^assigns.policy.id,
            order_by: [desc: u.inserted_at]
        )
      else
        []
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:uploads_list, uploads_list)
      |> assign(:form, to_form(%{"data_type" => "", "remark" => ""}))
      |> allow_upload(:data_file, accept: ~w(.csv .pdf .zip), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_upload", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end

  @impl true
  def handle_event("save_upload", %{"data_type" => data_type, "remark" => remark}, socket) do
    if is_nil(socket.assigns.policy) do
      {:noreply, put_flash(socket, :error, "Cannot upload data. Policy is missing or not saved properly. Please complete Step 1 first.")}
    else
      policy_id = socket.assigns.policy.id

    uploaded_files =
      consume_uploaded_entries(socket, :data_file, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", filename(entry))
        # Ensure uploads directory exists
        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, %{original_file_name: entry.client_name, file_path: dest}}
      end)

    case uploaded_files do
      [file_info] ->
        try do
          CorporatePolicy.DataUploadService.process_upload(
            policy_id,
            data_type,
            remark,
            file_info.file_path,
            file_info.original_file_name
          )

          # Fetch updated list
          uploads_list =
            CorporatePolicy.Repo.all(
              from u in CorporatePolicy.Policies.MasterPolicyDataUpload,
                where: u.policy_id == ^policy_id,
                order_by: [desc: u.inserted_at]
            )

          {:noreply,
           socket
           |> assign(:uploads_list, uploads_list)
           |> assign(:form, to_form(%{"data_type" => "", "remark" => ""}))
           |> put_flash(:info, "Data uploaded successfully.")}
        rescue
          e ->
            require Logger
            Logger.error("Failed to process upload: #{inspect(e)}")
            {:noreply, put_flash(socket, :error, "Failed to parse and save file. Please check file format.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to upload file.")}
    end
    end
  end

  @impl true
  def handle_event("remove_upload_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :data_file, ref)}
  end

  @impl true
  def handle_event("save_step4", _params, socket) do
    send(self(), {:step_completed, :step4, socket.assigns.policy})
    {:noreply, socket}
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  defp available_data_types(policy) do
    types = ["Inception Data", "Endorsement Data", "Claim Dumps"]

    # Assuming policy map has line_of_business defined
    if policy && Map.get(policy, "line_of_business", "") |> String.downcase() == "health" do
      types ++ ["Ecards"]
    else
      types
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <!-- File Upload Form -->
      <.form
        for={@form}
        id="data-upload-form"
        phx-submit="save_upload"
        phx-change="validate_upload"
        phx-target={@myself}
        class="bg-gray-50 p-4 rounded-lg mb-8"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <label class="corp-label">Select Data Type <span class="text-red-500">*</span></label>
            <select name="data_type" class="corp-input" required>
              <option value="" disabled selected={@form[:data_type].value == ""}>
                Select Data Type
              </option>
              <%= for type <- available_data_types(@policy) do %>
                <option value={type} selected={@form[:data_type].value == type}>{type}</option>
              <% end %>
            </select>
            <p class="text-xs text-gray-400 mt-1">
              Ecards allowed only for Health LOB (PDF/ZIP). Others must be CSV.
            </p>
          </div>

          <div>
            <label class="corp-label">Remark</label>
            <input
              type="text"
              name="remark"
              value={@form[:remark].value}
              class="corp-input"
              placeholder="Add an optional remark"
            />
          </div>
        </div>

        <div class="mb-4">
          <label class="corp-label">Upload File <span class="text-red-500">*</span></label>
          <div
            class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center"
            phx-drop-target={@uploads.data_file.ref}
          >
            <.live_file_input upload={@uploads.data_file} class="hidden" />
            <label for={@uploads.data_file.ref} class="cursor-pointer text-primary hover:underline">
              Click to browse
            </label>
            <span class="text-gray-500"> or drag and drop here</span>
          </div>
        </div>

        <!-- Preview pending uploads -->
        <%= for entry <- @uploads.data_file.entries do %>
          <div class="flex justify-between items-center bg-white p-3 rounded border mb-4">
            <span class="text-sm text-gray-700">{entry.client_name}</span>
            <div class="flex items-center gap-4">
              <span class="text-xs font-semibold text-green-600">{entry.progress}%</span>
              <button
                type="button"
                phx-click="remove_upload_entry"
                phx-value-ref={entry.ref}
                phx-target={@myself}
                class="text-red-500 hover:text-red-700"
              >
                &times; Cancel
              </button>
            </div>
          </div>
        <% end %>

        <div class="flex justify-end mt-4">
          <button
            type="submit"
            class="btn btn-outline btn-primary"
            disabled={Enum.empty?(@uploads.data_file.entries)}
          >
            Upload Data
          </button>
        </div>
      </.form>

      <!-- Uploaded Files Table -->
      <div class="policy-table-wrapper mb-8">
        <table class="policy-table">
          <thead>
            <tr>
              <th>#</th>
              <th>FILE NAME</th>
              <th>DATA TYPE</th>
              <th>REMARK</th>
              <th>STATUS</th>
              <th>CREATED AT</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@uploads_list) do %>
              <tr>
                <td colspan="6" class="text-center py-8">
                  <div class="flex flex-col items-center justify-center text-gray-400">
                    <svg class="w-12 h-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                    >
                    </path></svg>
                    <span>No data</span>
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {upload, index} <- Enum.with_index(@uploads_list, 1) do %>
                <tr>
                  <td>{index}</td>
                  <td class="font-medium text-blue-600 hover:underline cursor-pointer">
                    {upload.original_file_name}
                  </td>
                  <td>{upload.data_type}</td>
                  <td>{upload.remark}</td>
                  <td>
                    <span class="badge badge-success badge-sm text-white border-none bg-green-500">Uploaded</span>
                  </td>
                  <td class="whitespace-nowrap">
                    {Calendar.strftime(upload.inserted_at, "%d-%b-%Y %I:%M %p")}
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <!-- Pagination Controls for Table (Mocked) -->
      <div class="flex justify-between items-center mb-8 bg-gray-50 p-2 rounded-b-lg border-t-0">
        <button class="btn btn-sm btn-primary">Previous</button>
        <button class="btn btn-sm btn-primary">Next</button>
      </div>

      <div class="flex justify-end gap-4 mt-4 border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>
        <button type="button" phx-click="save_step4" phx-target={@myself} class="btn btn-primary">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end
end
