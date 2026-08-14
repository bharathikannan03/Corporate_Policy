defmodule CorporatePolicyWeb.Admin.Step7CDStatementsComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.CdStatements

  @impl true
  def update(assigns, socket) do
    search = socket.assigns[:search] || ""
    sort_by = socket.assigns[:sort_by] || "policy_number"
    sort_dir = socket.assigns[:sort_dir] || "desc"
    page = socket.assigns[:page] || 1

    socket =
      socket
      |> assign(assigns)
      |> assign(:search, search)
      |> assign(:sort_by, sort_by)
      |> assign(:sort_dir, sort_dir)
      |> assign(:page, page)
      |> assign(:delete_id, nil)
      |> load_rows()

    {:ok, socket}
  end

  @impl true
  def handle_event("search_rows", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> assign(:page, 1) |> load_rows()}
  end

  @impl true
  def handle_event("sort_rows", %{"sort_by" => sort_by}, socket) do
    sort_dir =
      if socket.assigns.sort_by == sort_by and socket.assigns.sort_dir == "asc",
        do: "desc",
        else: "asc"

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_dir, sort_dir)
     |> assign(:page, 1)
     |> load_rows()}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, page) |> load_rows()}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, :delete_id, String.to_integer(id))}
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :delete_id, nil)}
  end

  @impl true
  def handle_event("delete_row", %{"id" => id}, socket) do
    case CdStatements.delete_policy_cd_statement_row(
           String.to_integer(id),
           socket.assigns.policy.id,
           socket.assigns.current_user.id
         ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:delete_id, nil)
         |> put_flash(:info, "CD Statement row deleted successfully.")
         |> load_rows()}

      {:error, message} ->
        {:noreply, socket |> assign(:delete_id, nil) |> put_flash(:error, message)}
    end
  end

  @impl true
  def handle_event("save_step7", _params, socket) do
    send(self(), {:step_completed, :step7, socket.assigns.policy})
    {:noreply, put_flash(socket, :info, "CD Statements saved successfully.")}
  end

  defp load_rows(%{assigns: %{policy: nil}} = socket) do
    assign(socket, :rows_page, %{
      entries: [],
      page: 1,
      page_size: 15,
      total_entries: 0,
      total_pages: 1
    })
  end

  defp load_rows(socket) do
    page_data =
      CdStatements.list_policy_cd_statement_rows(socket.assigns.policy.id, %{
        "page" => socket.assigns.page,
        "search" => socket.assigns.search,
        "sort_by" => socket.assigns.sort_by,
        "sort_dir" => socket.assigns.sort_dir
      })

    assign(socket, :rows_page, page_data)
  end

  attr :active, :boolean, required: true
  attr :direction, :string, required: true

  defp sort_icon(assigns) do
    label =
      cond do
        assigns.active and assigns.direction == "asc" -> "^"
        assigns.active and assigns.direction == "desc" -> "v"
        true -> "<>"
      end

    assigns = assign(assigns, :label, label)

    ~H"""
    <span class="text-xs text-gray-400">{@label}</span>
    """
  end

  defp amount_text(nil), do: ""
  defp amount_text(value), do: Decimal.to_string(value)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <div class="mb-6 rounded-xl border border-blue-100 bg-white shadow-sm">
        <div class="rounded-t-xl bg-sky-100 px-4 py-3 text-sm font-medium text-slate-700">
          Policy Details
        </div>
        
        <div class="grid grid-cols-1 gap-4 px-4 py-5 text-sm md:grid-cols-3">
          <div>
            <div>Policy Number : {(@policy && @policy.policy_number) || "-"}</div>
            
            <div>Insurer : {(@policy && @policy.select_insurer) || "-"}</div>
          </div>
          
          <div>
            <div>
              Policy Start Date : {(@policy && @policy.policy_start_date &&
                                      Calendar.strftime(@policy.policy_start_date, "%d-%m-%Y")) || "-"}
            </div>
            
            <div>TPA : {(@policy && @policy.select_tpa) || "-"}</div>
          </div>
          
          <div>
            <div>
              Policy End Date : {(@policy && @policy.policy_end_date &&
                                    Calendar.strftime(@policy.policy_end_date, "%d-%m-%Y")) || "-"}
            </div>
            
            <div>Corporate Name : {(@policy && @policy.corporate_name) || "-"}</div>
          </div>
        </div>
      </div>
      
      <div class="mb-4 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div class="flex gap-2">
          <input
            type="text"
            name="search"
            value={@search}
            placeholder="Search policy number, particular, endorsement"
            phx-keyup="search_rows"
            phx-debounce="300"
            phx-target={@myself}
            class="corp-input w-full md:w-80"
          />
        </div>
        
        <div class="flex gap-2">
          <%= if @policy do %>
            <.link
              href={~p"/admin/policy-details/#{@policy.id}/cd-statements/export"}
              class="btn btn-secondary"
            >
              Export CSV
            </.link>
            
            <.link
              navigate={~p"/admin/policy-details/#{@policy.id}/cd-statements/new"}
              class="btn btn-primary"
            >
              Add CD Statements
            </.link>
          <% else %>
            <button type="button" class="btn btn-secondary" disabled>Export CSV</button>
            <button type="button" class="btn btn-primary" disabled>Add CD Statements</button>
          <% end %>
        </div>
      </div>
      
      <div class="corp-table-card">
        <div class="overflow-x-auto">
          <table class="corp-table">
            <thead>
              <tr>
                <th class="corp-th">#</th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="policy_number"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Policy Number
                    <.sort_icon active={@sort_by == "policy_number"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="particular"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Particular <.sort_icon active={@sort_by == "particular"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="debit_amount"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Debit Amount (DR)
                    <.sort_icon active={@sort_by == "debit_amount"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="credit_amount"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Credit Amount (CR)
                    <.sort_icon active={@sort_by == "credit_amount"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="policy_endorsement_no"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Policy Endorsement No
                    <.sort_icon active={@sort_by == "policy_endorsement_no"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="endorsement_issued_date"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Endorsement Issued Date
                    <.sort_icon active={@sort_by == "endorsement_issued_date"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="bank_name"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Bank Name <.sort_icon active={@sort_by == "bank_name"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="cheque_no"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Cheque No <.sort_icon active={@sort_by == "cheque_no"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="remark"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Remark <.sort_icon active={@sort_by == "remark"} direction={@sort_dir} />
                  </button>
                </th>
                
                <th class="corp-th text-center">Delete</th>
                
                <th class="corp-th">
                  <button
                    type="button"
                    phx-click="sort_rows"
                    phx-value-sort_by="inserted_at"
                    phx-target={@myself}
                    class="flex items-center gap-1"
                  >
                    Created At <.sort_icon active={@sort_by == "inserted_at"} direction={@sort_dir} />
                  </button>
                </th>
              </tr>
            </thead>
            
            <tbody>
              <%= if @rows_page.entries == [] do %>
                <tr class="corp-empty-row">
                  <td colspan="12" class="corp-empty-cell py-10">
                    <div class="corp-empty-state">
                      <.icon name="hero-banknotes" class="mb-3 h-12 w-12 text-gray-300" />
                      <p class="corp-empty-text">No CD Statement rows found for this policy</p>
                    </div>
                  </td>
                </tr>
              <% else %>
                <%= for {row, index} <- Enum.with_index(@rows_page.entries, 1) do %>
                  <tr class="corp-tr">
                    <td class="corp-td">{(@rows_page.page - 1) * @rows_page.page_size + index}</td>
                    
                    <td class="corp-td font-medium">{row.policy_number}</td>
                    
                    <td class="corp-td">{row.particular}</td>
                    
                    <td class="corp-td">{amount_text(row.debit_amount)}</td>
                    
                    <td class="corp-td">{amount_text(row.credit_amount)}</td>
                    
                    <td class="corp-td">{row.policy_endorsement_no}</td>
                    
                    <td class="corp-td">{row.endorsement_issued_date}</td>
                    
                    <td class="corp-td">{row.bank_name}</td>
                    
                    <td class="corp-td">{row.cheque_no}</td>
                    
                    <td class="corp-td">{row.remark}</td>
                    
                    <td class="corp-td text-center">
                      <button
                        type="button"
                        phx-click="confirm_delete"
                        phx-value-id={row.id}
                        phx-target={@myself}
                        class="corp-action-btn-text corp-action-btn-text--delete"
                        title="Delete"
                      >
                        <.icon name="hero-trash" class="h-4 w-4" />
                      </button>
                    </td>
                    
                    <td class="corp-td whitespace-nowrap">
                      {Calendar.strftime(row.inserted_at, "%d/%-m/%Y, %-I:%M:%S %P")}
                    </td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
      
      <.pagination
        page={@rows_page.page}
        page_size={@rows_page.page_size}
        total_entries={@rows_page.total_entries}
        total_pages={@rows_page.total_pages}
        event="paginate_table"
        target={@myself}
      />
      <div class="corp-form-actions border-t pt-4">
        <button type="button" phx-click="save_step7" phx-target={@myself} class="btn btn-success">
          {if @edit_mode, do: "Save Changes", else: "Complete Policy"}
        </button>
      </div>
      
      <%= if @delete_id do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
            <h3 class="mb-2 text-lg font-semibold">Delete CD Statement Row</h3>
            
            <p class="mb-6 text-sm text-base-content/70">
              Are you sure you want to delete this CD Statement row?
            </p>
            
            <div class="flex justify-end gap-2">
              <button
                type="button"
                phx-click="cancel_delete"
                phx-target={@myself}
                class="btn btn-secondary"
              >
                Cancel
              </button>
              
              <button
                type="button"
                phx-click="delete_row"
                phx-value-id={@delete_id}
                phx-target={@myself}
                class="btn btn-error"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
