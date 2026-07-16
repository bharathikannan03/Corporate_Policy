defmodule CorporatePolicyWeb.Step6DocumentsComponent do
  use CorporatePolicyWeb, :live_component

  @impl true
  def update(assigns, socket) do
    documents = assigns[:documents] || []

    # Mock Data for Document Types and Names
    doc_types = [
      %{id: 1, name: "Policy Document"},
      %{id: 2, name: "Service Document"}
    ]

    doc_names = [
      %{id: 1, type_id: 1, name: "Policy copy"},
      %{id: 2, type_id: 2, name: "Claim form"},
      %{id: 3, type_id: 2, name: "Non Payable list"},
      %{id: 4, type_id: 2, name: "Day care list"},
      %{id: 5, type_id: 2, name: "Check list"}
    ]

    socket =
      socket
      |> assign(assigns)
      |> assign(:documents, documents)
      |> assign(:doc_types, doc_types)
      |> assign(:all_doc_names, doc_names)
      |> assign(:available_doc_names, [])
      |> assign(
        :form,
        to_form(%{"document_type_id" => "", "document_name_id" => "", "note" => ""})
      )
      |> allow_upload(:policy_doc, accept: ~w(.pdf), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_doc", %{"document_type_id" => type_id_str} = params, socket) do
    # Filter document names based on the selected type
    available_doc_names =
      if type_id_str != "" do
        type_id = String.to_integer(type_id_str)
        Enum.filter(socket.assigns.all_doc_names, &(&1.type_id == type_id))
      else
        []
      end

    {:noreply,
     socket
     |> assign(:available_doc_names, available_doc_names)
     |> assign(:form, to_form(params))}
  end

  def handle_event("validate_doc", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end

  @impl true
  def handle_event(
        "save_doc",
        %{"document_type_id" => type_id_str, "document_name_id" => name_id_str, "note" => note},
        socket
      ) do
    uploaded_files =
      consume_uploaded_entries(socket, :policy_doc, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", filename(entry))
        File.cp!(path, dest)
        {:ok, %{original_file_name: entry.client_name, file_path: dest}}
      end)

    case uploaded_files do
      [file_info] ->
        type_id = String.to_integer(type_id_str)
        name_id = String.to_integer(name_id_str)

        type = Enum.find(socket.assigns.doc_types, &(&1.id == type_id))
        name = Enum.find(socket.assigns.all_doc_names, &(&1.id == name_id))

        new_doc = %{
          id: System.unique_integer([:positive]),
          document_type_id: type.id,
          document_type: type.name,
          document_name_id: name.id,
          document_name: name.name,
          note: note,
          original_file_name: file_info.original_file_name,
          file_path: file_info.file_path,
          status: 0
        }

        {:noreply,
         socket
         |> assign(:documents, [new_doc | socket.assigns.documents])
         |> assign(
           :form,
           to_form(%{"document_type_id" => "", "document_name_id" => "", "note" => ""})
         )}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to upload document.")}
    end
  end

  @impl true
  def handle_event("remove_doc_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :policy_doc, ref)}
  end

  @impl true
  def handle_event("remove_document", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    updated_list = Enum.reject(socket.assigns.documents, &(&1.id == id))
    {:noreply, assign(socket, :documents, updated_list)}
  end

  @impl true
  def handle_event("save_step6", _params, socket) do
    send(self(), {:step_completed, :step6, socket.assigns.policy})
    {:noreply, socket}
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <!-- Add Document Form -->
      <.form
        for={@form}
        id="add-document-form"
        phx-submit="save_doc"
        phx-change="validate_doc"
        phx-target={@myself}
        class="bg-gray-50 p-4 rounded-lg mb-8"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <label class="corp-label">Document Type <span class="text-red-500">*</span></label>
            <select name="document_type_id" class="corp-input" required>
              <option value="" disabled selected={@form[:document_type_id].value == ""}>
                Select Document Type
              </option>
              <%= for type <- @doc_types do %>
                <option
                  value={type.id}
                  selected={@form[:document_type_id].value == to_string(type.id)}
                >
                  {type.name}
                </option>
              <% end %>
            </select>
          </div>

          <div>
            <label class="corp-label">Document Name <span class="text-red-500">*</span></label>
            <select
              name="document_name_id"
              class="corp-input"
              required
              disabled={Enum.empty?(@available_doc_names)}
            >
              <option value="" disabled selected={@form[:document_name_id].value == ""}>
                Type or select Document Name
              </option>
              <%= for name <- @available_doc_names do %>
                <option
                  value={name.id}
                  selected={@form[:document_name_id].value == to_string(name.id)}
                >
                  {name.name}
                </option>
              <% end %>
            </select>
          </div>
        </div>

        <div class="mb-4">
          <label class="corp-label">Note</label>
          <input
            type="text"
            name="note"
            value={@form[:note].value}
            class="corp-input"
            placeholder="Enter a note (Optional)"
          />
        </div>

        <div class="mb-4">
          <label class="corp-label">Attach Documents (PDF only) <span class="text-red-500">*</span></label>
          <div
            class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center"
            phx-drop-target={@uploads.policy_doc.ref}
          >
            <.live_file_input
              upload={@uploads.policy_doc}
              class="hidden"
            />
            <label for={@uploads.policy_doc.ref} class="cursor-pointer text-blue-600 hover:underline font-medium">
              Click to browse
            </label>
            <span class="text-gray-500"> or drag and drop your PDF here</span>
          </div>
        </div>

        <!-- Preview pending uploads -->
        <%= for entry <- @uploads.policy_doc.entries do %>
          <div class="flex justify-between items-center bg-white p-3 rounded border mb-4">
            <span class="text-sm text-gray-700">{entry.client_name}</span>
            <div class="flex items-center gap-4">
              <span class="text-xs font-semibold text-green-600">{entry.progress}%</span>
              <button
                type="button"
                phx-click="remove_doc_entry"
                phx-value-ref={entry.ref}
                phx-target={@myself}
                class="text-red-500 hover:text-red-700"
              >
                &times; Cancel
              </button>
            </div>
          </div>
        <% end %>

        <div class="flex justify-start mt-4">
          <button
            type="submit"
            class="btn btn-primary"
            disabled={Enum.empty?(@uploads.policy_doc.entries)}
          >
            Submit
          </button>
        </div>

        <!-- Info Note -->
        <div class="mt-6 bg-blue-50 border border-blue-200 p-4 rounded-lg flex items-start text-sm text-blue-800">
          <div class="mr-3 mt-0.5">
            <svg class="w-5 h-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            >
            </path></svg>
          </div>
          <div>
            <p class="font-semibold mb-1">Note:</p>
            <ul class="list-disc ml-5">
              <li>
                <strong>Service Document</strong> - Service documents which help for claim procedure
              </li>
              <li>
                <strong>Policy Documents (Policy Copies)</strong>
                - Policy Documents will be only visible to HR
              </li>
            </ul>
          </div>
        </div>
      </.form>

      <!-- Uploaded Documents Table -->
      <div class="policy-table-wrapper mb-8">
        <table class="policy-table">
          <thead>
            <tr>
              <th>S.No</th>
              <th>Document Type</th>
              <th>Document Name</th>
              <th>Attachment</th>
              <th>Note</th>
              <th class="text-right">Action</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@documents) do %>
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
              <%= for {doc, index} <- Enum.with_index(@documents, 1) do %>
                <tr>
                  <td>{index}</td>
                  <td>{doc.document_type}</td>
                  <td>{doc.document_name}</td>
                  <td class="font-medium text-blue-600 hover:underline cursor-pointer">
                    {doc.original_file_name}
                  </td>
                  <td>{doc.note}</td>
                  <td class="text-right">
                    <button
                      type="button"
                      phx-click="remove_document"
                      phx-value-id={doc.id}
                      phx-target={@myself}
                      class="text-red-500 hover:text-red-700"
                    >
                      Delete
                    </button>
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
        <button type="button" phx-click="save_step6" phx-target={@myself} class="btn btn-primary">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end
end
