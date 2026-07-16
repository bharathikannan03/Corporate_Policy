defmodule CorporatePolicyWeb.Step7CDStatementsComponent do
  use CorporatePolicyWeb, :live_component

  @impl true
  def update(assigns, socket) do
    # Mock data for corporates and their CD accounts
    corporates = [
      %{id: 1, name: "Vibe Insurance Broking & Advisory Service pvt Ltd"},
      %{id: 2, name: "METHODHUB SOFTWARE LIMITED"},
      %{id: 3, name: "Test Corporate New"}
    ]

    cd_accounts = [
      %{
        id: 1,
        corporate_id: 1,
        cd_number: "5001",
        insurer: "Aditya Birla Health Insurance Co. Limited"
      },
      %{
        id: 2,
        corporate_id: 2,
        cd_number: "NC1111",
        insurer: "Aditya Birla Health Insurance Co. Limited"
      },
      %{
        id: 3,
        corporate_id: 3,
        cd_number: "001",
        insurer: "Bajaj Allianz Life Insurance Co. Ltd."
      }
    ]

    statements = assigns[:cd_statements] || []

    socket =
      socket
      |> assign(assigns)
      |> assign(:corporates, corporates)
      |> assign(:all_cd_accounts, cd_accounts)
      |> assign(:available_cd_accounts, [])
      |> assign(:cd_statements, statements)
      |> assign(:form, to_form(%{"corporate_id" => "", "cd_account_id" => ""}))
      |> assign(:show_add_modal, false)
      |> allow_upload(:cd_csv, accept: ~w(.csv), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_cd", %{"corporate_id" => corporate_id_str} = params, socket) do
    available_cd_accounts =
      if corporate_id_str != "" do
        corporate_id = String.to_integer(corporate_id_str)
        Enum.filter(socket.assigns.all_cd_accounts, &(&1.corporate_id == corporate_id))
      else
        []
      end

    {:noreply,
     socket
     |> assign(:available_cd_accounts, available_cd_accounts)
     |> assign(:form, to_form(params))}
  end

  def handle_event("validate_cd", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end

  @impl true
  def handle_event("open_add_modal", _, socket) do
    {:noreply, assign(socket, :show_add_modal, true)}
  end

  @impl true
  def handle_event("close_add_modal", _, socket) do
    {:noreply, assign(socket, :show_add_modal, false)}
  end

  @impl true
  def handle_event(
        "save_cd_upload",
        %{"corporate_id" => corporate_id_str, "cd_account_id" => cd_account_id_str},
        socket
      ) do
    uploaded_files =
      consume_uploaded_entries(socket, :cd_csv, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", filename(entry))
        File.cp!(path, dest)
        {:ok, %{original_file_name: entry.client_name, file_path: dest}}
      end)

    case uploaded_files do
      [_file_info] ->
        # Here we would normally parse the CSV and insert the records.
        # For now, just simulate success.
        _corporate_id = String.to_integer(corporate_id_str)
        _cd_account_id = String.to_integer(cd_account_id_str)

        # We mock inserting parsed transactions into the table
        # In a real app we would parse the CSV and insert the records.
        mocked_statement = %{
          id: System.unique_integer([:positive]),
          policy_number: "332204/48/2023/1119",
          particular: "Opening Balance",
          debit_amount: "",
          credit_amount: "500000",
          policy_endorsement_no: "",
          endorsement_issued_date: "03-03-2023",
          bank_name: "",
          cheque_no: "",
          remark: "",
          inserted_at: NaiveDateTime.local_now()
        }

        mocked_statement_2 = %{
          id: System.unique_integer([:positive]),
          policy_number: "332204/48/2023/1119",
          particular: "Policy Premium",
          debit_amount: "",
          credit_amount: "450000",
          policy_endorsement_no: "1123665",
          endorsement_issued_date: "05-03-2023",
          bank_name: "",
          cheque_no: "",
          remark: "",
          inserted_at: NaiveDateTime.local_now()
        }

        {:noreply,
         socket
         |> assign(:cd_statements, [
           mocked_statement,
           mocked_statement_2 | socket.assigns.cd_statements
         ])
         |> assign(:show_add_modal, false)
         |> put_flash(:info, "CD Statement CSV uploaded successfully.")}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to upload CD Statement CSV.")}
    end
  end

  @impl true
  def handle_event("remove_cd_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cd_csv, ref)}
  end

  @impl true
  def handle_event("remove_statement", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    updated_list = Enum.reject(socket.assigns.cd_statements, &(&1.id == id))
    {:noreply, assign(socket, :cd_statements, updated_list)}
  end

  @impl true
  def handle_event("save_step7", _params, socket) do
    # Final step, complete policy
    send(self(), {:step_completed, :step7, socket.assigns.policy})
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
      <div class="flex justify-end mb-6">
        <div class="flex gap-2">
          <button class="btn btn-outline">Export CSV</button>
          <button phx-click="open_add_modal" phx-target={@myself} class="btn btn-primary">Add CD Statements</button>
        </div>
      </div>

      <!-- CD Statements Table -->
      <div class="policy-table-wrapper mb-8">
        <table class="policy-table" style="font-size: 0.75rem;">
          <thead>
            <tr>
              <th>#</th>
              <th>POLICY NUMBER</th>
              <th>PARTICULAR</th>
              <th>DEBIT AMOUNT (DR)</th>
              <th>CREDIT AMOUNT (CR)</th>
              <th>POLICY ENDORSEMENT NO</th>
              <th>ENDORSEMENT ISSUED DATE</th>
              <th>BANK NAME</th>
              <th>CHEQUE NO</th>
              <th>REMARK</th>
              <th>CREATED AT</th>
              <th class="text-right">DELETE</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@cd_statements) do %>
              <tr>
                <td colspan="12" class="text-center py-8">
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
              <%= for {stmt, index} <- Enum.with_index(@cd_statements, 1) do %>
                <tr style="font-size: 0.875rem;">
                  <td>{index}</td>
                  <td class="font-medium">{stmt.policy_number}</td>
                  <td>{stmt.particular}</td>
                  <td class="text-red-500 font-medium">{stmt.debit_amount}</td>
                  <td class="text-green-600 font-medium">{stmt.credit_amount}</td>
                  <td>{stmt.policy_endorsement_no}</td>
                  <td>{stmt.endorsement_issued_date}</td>
                  <td>{stmt.bank_name}</td>
                  <td>{stmt.cheque_no}</td>
                  <td>{stmt.remark}</td>
                  <td class="whitespace-nowrap" style="font-size: 0.75rem;">
                    {Calendar.strftime(stmt.inserted_at, "%d-%b-%Y")}
                  </td>
                  <td class="text-right">
                    <button
                      type="button"
                      phx-click="remove_statement"
                      phx-value-id={stmt.id}
                      phx-target={@myself}
                      class="text-red-500 hover:text-red-700"
                    >
                      <svg
                        class="w-5 h-5 inline"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      ><path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                      >
                      </path></svg>
                    </button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>


      <div class="flex justify-end gap-4 mt-4 border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>
        <button type="button" phx-click="save_step7" phx-target={@myself} class="btn btn-primary">
          {if @edit_mode, do: "Save Changes", else: "Complete Policy"}
        </button>
      </div>

      <!-- Upload Modal -->
      <%= if @show_add_modal do %>
        <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[9999] p-4">
          <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center bg-blue-600 text-white p-4 rounded-t-lg">
              <h2 class="text-xl font-bold flex items-center">
                <button
                  type="button"
                  phx-click="close_add_modal"
                  phx-target={@myself}
                  class="mr-2 hover:bg-blue-700 p-1 rounded"
                >
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 19l-7-7 7-7"
                  >
                  </path></svg>
                </button>
                Back To CD Statement
              </h2>
              <button
                type="button"
                phx-click="close_add_modal"
                phx-target={@myself}
                class="text-white hover:text-gray-200"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                >
                </path></svg>
              </button>
            </div>

            <div class="p-6">
              <div class="flex justify-between items-center mb-6">
                <h3 class="text-2xl font-semibold">Add CD Statement</h3>
              </div>

              <.form
                for={@form}
                id="add-cd-form"
                phx-submit="save_cd_upload"
                phx-change="validate_cd"
                phx-target={@myself}
              >
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-6">
                  <!-- Left side: Dropdowns -->
                  <div class="space-y-4">
                    <div>
                      <label class="corp-label">Corporate name <span class="text-red-500">*</span></label>
                      <select name="corporate_id" class="corp-input" required>
                        <option value="" disabled selected={@form[:corporate_id].value == ""}>
                          Select Corporate name
                        </option>
                        <%= for corp <- @corporates do %>
                          <option
                            value={corp.id}
                            selected={@form[:corporate_id].value == to_string(corp.id)}
                          >
                            {corp.name}
                          </option>
                        <% end %>
                      </select>
                    </div>

                    <div>
                      <label class="corp-label">CD Accounts (Insurer | CD Number)
                      <span class="text-red-500">*</span></label>
                      <select
                        name="cd_account_id"
                        class="corp-input"
                        required
                        disabled={Enum.empty?(@available_cd_accounts)}
                      >
                        <option value="" disabled selected={@form[:cd_account_id].value == ""}>
                          Select CD Account
                        </option>
                        <%= for acc <- @available_cd_accounts do %>
                          <option
                            value={acc.id}
                            selected={@form[:cd_account_id].value == to_string(acc.id)}
                          >
                            {acc.insurer} | CD: {acc.cd_number}
                          </option>
                        <% end %>
                      </select>
                    </div>
                  </div>

                  <!-- Right side: File Upload -->
                  <div>
                    <label class="corp-label">CD Statement Data Upload</label>
                    <div
                      class="border-2 border-dashed border-gray-300 rounded-lg p-10 text-center bg-gray-50 flex flex-col items-center justify-center"
                      phx-drop-target={@uploads.cd_csv.ref}
                    >
                      <svg
                        class="w-12 h-12 text-blue-500 mb-4"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      ><path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                      >
                      </path></svg>
                      <.live_file_input
                        upload={@uploads.cd_csv}
                        class="hidden"
                      />
                      <label
                        for={@uploads.cd_csv.ref}
                        class="text-blue-600 font-medium hover:underline cursor-pointer"
                      >
                        Drag and drop a file here or click
                      </label>
                    </div>

                    <!-- Preview pending uploads -->
                    <%= for entry <- @uploads.cd_csv.entries do %>
                      <div class="flex justify-between items-center bg-white p-3 rounded border mt-4">
                        <span class="text-sm text-gray-700">{entry.client_name}</span>
                        <div class="flex items-center gap-4">
                          <span class="text-xs font-semibold text-green-600">{entry.progress}%</span>
                          <button
                            type="button"
                            phx-click="remove_cd_entry"
                            phx-value-ref={entry.ref}
                            phx-target={@myself}
                            class="text-red-500 hover:text-red-700"
                          >
                            &times; Cancel
                          </button>
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>

                <div class="flex justify-end pt-4 border-t border-gray-200">
                  <button
                    type="submit"
                    class="btn btn-primary"
                    disabled={
                      Enum.empty?(@uploads.cd_csv.entries) || @form[:cd_account_id].value == ""
                    }
                  >
                    Upload & Process CSV
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
