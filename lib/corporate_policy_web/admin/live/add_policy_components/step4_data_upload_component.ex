defmodule CorporatePolicyWeb.Admin.Step4DataUploadComponent do
  use CorporatePolicyWeb, :live_component
  import Ecto.Query

  alias CorporatePolicy.StringUtils
  alias CorporatePolicyWeb.Pagination

  @impl true
  def update(assigns, socket) do
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
      |> assign(:error_message, nil)
      |> assign(:form, to_form(%{"data_type" => "", "remark" => ""}))
      |> allow_upload(:data_file, accept: ~w(.csv .pdf .zip), max_entries: 1)
      |> assign_uploads_page(uploads_list)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_upload", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end

  @impl true
  def handle_event("save_upload", %{"data_type" => data_type, "remark" => remark}, socket) do
    if is_nil(socket.assigns.policy) do
      err_msg =
        "Cannot upload data. Policy is missing or not saved properly. Please complete Step 1 first."

      send(self(), {:put_flash, :error, err_msg})
      {:noreply, socket |> assign(:error_message, err_msg) |> put_flash(:error, err_msg)}
    else
      policy_id = socket.assigns.policy.id

      uploaded_files =
        consume_uploaded_entries(socket, :data_file, fn %{path: path}, entry ->
          dest = Path.join("priv/static/uploads", filename(entry))
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

            uploads_list =
              CorporatePolicy.Repo.all(
                from u in CorporatePolicy.Policies.MasterPolicyDataUpload,
                  where: u.policy_id == ^policy_id,
                  order_by: [desc: u.inserted_at]
              )

            send(self(), {:put_flash, :info, "Data uploaded successfully."})

            {:noreply,
             socket
             |> assign(:uploads_list, uploads_list)
             |> assign_uploads_page(uploads_list)
             |> assign(:error_message, nil)
             |> assign(:form, to_form(%{"data_type" => "", "remark" => ""}))
             |> put_flash(:info, "Data uploaded successfully.")}
          rescue
            e ->
              require Logger
              Logger.error("Failed to process upload: #{inspect(e)}")

              error_msg =
                case e do
                  %RuntimeError{message: msg} ->
                    msg

                  %Postgrex.Error{postgres: %{message: msg}} when is_binary(msg) ->
                    "Database error: " <> msg

                  %Postgrex.Error{postgres: %{message: msg}} when not is_nil(msg) ->
                    "Database error: " <> inspect(msg)

                  _ ->
                    "Failed to parse and save file: " <> Exception.message(e)
                end

              send(self(), {:put_flash, :error, error_msg})

              {:noreply,
               socket
               |> assign(:error_message, error_msg)
               |> put_flash(:error, error_msg)}
          end

        _ ->
          err_msg = "Failed to upload file. Please select a valid file."
          send(self(), {:put_flash, :error, err_msg})
          {:noreply, socket |> assign(:error_message, err_msg) |> put_flash(:error, err_msg)}
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
    {:noreply, socket |> put_flash(:info, "Data upload step completed successfully.")}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, assign_uploads_page(socket, socket.assigns.uploads_list, page)}
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  defp available_data_types(policy) do
    types = ["Inception Data", "Endorsement Data", "Claim Dumps"]

    if policy && StringUtils.equal?(Map.get(policy, "line_of_business", ""), "health") do
      types ++ ["Ecards"]
    else
      types
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <%= if @error_message do %>
        <div class="mb-6 p-4 text-sm text-red-800 rounded-lg bg-red-50 border border-red-200 flex items-center justify-between shadow-sm">
          <div class="flex items-center gap-3">
            <svg class="w-6 h-6 flex-shrink-0 text-red-600" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
             <span class="font-semibold">{@error_message}</span>
          </div>
        </div>
      <% end %>
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
                    </path></svg> <span>No data</span>
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {upload, index} <- Enum.with_index(@uploads_page.entries, 1) do %>
                <tr>
                  <td>{(@uploads_page.page - 1) * @uploads_page.page_size + index}</td>
                  
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
      
      <.pagination
        page={@uploads_page.page}
        page_size={@uploads_page.page_size}
        total_entries={@uploads_page.total_entries}
        total_pages={@uploads_page.total_pages}
        event="paginate_table"
        target={@myself}
        class="mb-8 bg-gray-50 rounded-b-lg"
      />
      <div class="flex justify-end gap-4 mt-4 border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>
        
        <button type="button" phx-click="save_step4" phx-target={@myself} class="btn btn-success">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end

  defp assign_uploads_page(socket, uploads_list, page \\ nil) do
    current_page =
      page || if(socket.assigns[:uploads_page], do: socket.assigns.uploads_page.page, else: 1)

    assign(socket, :uploads_page, Pagination.paginate_list(uploads_list, current_page))
  end
end
