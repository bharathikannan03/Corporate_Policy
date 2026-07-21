defmodule CorporatePolicyWeb.Admin.TotalClaimReportedLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Claims
  alias CorporatePolicy.Claims.MasterClaimSubmission

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    {:ok,
     socket
     |> assign(:page_title, "Total Claim Reported")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/total-claim-reported")
     |> assign(:claim_statuses, Claims.claim_statuses())
     |> assign(:show_documents_modal, false)
     |> assign(:show_logs_modal, false)
     |> assign(:selected_claim, nil)
     |> load_claims(%{})}
  end

  @impl true
  def handle_event("filter", params, socket) do
    {:noreply, load_claims(socket, Map.put(params, "page", 1))}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    params =
      socket.assigns.claims_page
      |> Map.take([:search, :status, :sort_by, :sort_dir])
      |> stringify()

    {:noreply, load_claims(socket, Map.put(params, "page", page))}
  end

  def handle_event("sort", %{"field" => field, "direction" => direction}, socket) do
    params =
      socket.assigns.claims_page
      |> Map.take([:search, :status])
      |> stringify()
      |> Map.merge(%{"sort_by" => field, "sort_dir" => direction, "page" => 1})

    {:noreply, load_claims(socket, params)}
  end

  def handle_event("view_documents", %{"id" => id}, socket) do
    claim = Claims.get_claim_with_details!(id)

    {:noreply,
     socket
     |> assign(:selected_claim, claim)
     |> assign(:show_documents_modal, true)
     |> assign(:show_logs_modal, false)}
  end

  def handle_event("view_logs", %{"id" => id}, socket) do
    claim = Claims.get_claim_with_details!(id)

    {:noreply,
     socket
     |> assign(:selected_claim, claim)
     |> assign(:show_logs_modal, true)
     |> assign(:show_documents_modal, false)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_documents_modal, false)
     |> assign(:show_logs_modal, false)
     |> assign(:selected_claim, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="total-claim-reported-page">
        <div class="corp-list-header" id="total-claim-reported-header">
          <div>
            <h1 class="corp-list-title">Claims Reported List</h1>
            
            <p class="corp-list-subtitle">
              Displays all details captured from the Claim Details form, including status and timestamps.
            </p>
          </div>
          
          <div class="header-actions">
            <.link href={~p"/admin/total-claim-reported/export"} class="btn-primary">
              <.icon name="hero-arrow-down-tray" class="w-4 h-4 mr-1" /> Export
            </.link>
          </div>
        </div>
        
        <div class="corp-table-card">
          <div class="flex flex-col gap-4 p-4 border-b border-gray-200 md:flex-row md:items-end md:justify-between">
            <.form
              for={to_form(%{"search" => @claims_page.search, "status" => @claims_page.status})}
              id="total-claim-reported-filter-form"
              phx-change="filter"
              class="grid grid-cols-1 gap-4 md:grid-cols-3 md:w-full"
            >
              <div>
                <label class="corp-label">Search</label>
                <input
                  type="text"
                  name="search"
                  value={@claims_page.search}
                  placeholder="Claim no, corporate, patient..."
                  class="corp-input"
                />
              </div>
              
              <div>
                <label class="corp-label">Status</label>
                <select name="status" class="corp-input">
                  <option value="">All Statuses</option>
                  
                  <%= for status <- @claim_statuses do %>
                    <option value={status} selected={@claims_page.status == status}>{status}</option>
                  <% end %>
                </select>
              </div>
            </.form>
          </div>
          
          <div class="overflow-x-auto">
            <table class="corp-table" id="total-claim-reported-table">
              <thead>
                <tr>
                  <th class="corp-th">SI NO</th>
                  
                  <th class="corp-th">
                    {sortable_link(assigns, "Corporate Name", "corporate_name")}
                  </th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Policy Number", "policy_number")}</th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Employee Code", "employee_code")}</th>
                  
                  <th class="corp-th">Employee Name</th>
                  
                  <th class="corp-th">
                    {sortable_link(assigns, "Beneficiary Name", "patient_name")}
                  </th>
                  
                  <th class="corp-th">Relation</th>
                  
                  <th class="corp-th">Claim Type</th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Claim Status", "claim_status")}</th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Claim No", "claim_number")}</th>
                  
                  <th class="corp-th">Intimation No</th>
                  
                  <th class="corp-th">
                    {sortable_link(assigns, "Hospitalization Date", "hospitalization_date")}
                  </th>
                  
                  <th class="corp-th">
                    {sortable_link(assigns, "Discharge Date", "discharge_date")}
                  </th>
                  
                  <th class="corp-th">Hospital Name</th>
                  
                  <th class="corp-th">Amount Claimed</th>
                  
                  <th class="corp-th">Claim Reason</th>
                  
                  <th class="corp-th">Hospital Address</th>
                  
                  <th class="corp-th">City</th>
                  
                  <th class="corp-th">State</th>
                  
                  <th class="corp-th">Pincode</th>
                  
                  <th class="corp-th">Treatment Details</th>
                  
                  <th class="corp-th">Remarks</th>
                  
                  <th class="corp-th">Portal</th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Submitted At", "submitted_at")}</th>
                  
                  <th class="corp-th">{sortable_link(assigns, "Created At", "inserted_at")}</th>
                  
                  <th class="corp-th">Claim Docs</th>
                  
                  <th class="corp-th">Logs</th>
                </tr>
              </thead>
              
              <tbody>
                <%= if @claims_page.entries == [] do %>
                  <tr class="corp-empty-row">
                    <td colspan="27" class="corp-empty-cell">
                      <div class="corp-empty-state">
                        <.icon name="hero-inbox" class="w-12 h-12 text-gray-300 mb-3" />
                        <p class="corp-empty-text">No claims reported yet</p>
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for {claim, index} <- Enum.with_index(@claims_page.entries, 1) do %>
                    <tr class="corp-tr">
                      <td class="corp-td">
                        {(@claims_page.page - 1) * @claims_page.page_size + index}
                      </td>
                      
                      <td class="corp-td">{claim.corporate_name}</td>
                      
                      <td class="corp-td">{claim.policy_number}</td>
                      
                      <td class="corp-td">{claim.employee_code}</td>
                      
                      <td class="corp-td">{blank_dash(claim.employee_name)}</td>
                      
                      <td class="corp-td">{claim.patient_name}</td>
                      
                      <td class="corp-td">{blank_dash(claim.relationship)}</td>
                      
                      <td class="corp-td">{claim.claim_type}</td>
                      
                      <td class="corp-td">
                        <span class={MasterClaimSubmission.status_badge_class(claim.claim_status)}>
                          {claim.claim_status}
                        </span>
                      </td>
                      
                      <td class="corp-td">{claim.claim_number}</td>
                      
                      <td class="corp-td">{blank_dash(claim.intimation_number)}</td>
                      
                      <td class="corp-td">{format_date(claim.hospitalization_date)}</td>
                      
                      <td class="corp-td">{format_date(claim.discharge_date)}</td>
                      
                      <td class="corp-td">{claim.hospital_name}</td>
                      
                      <td class="corp-td">{format_amount(claim.estimated_amount)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.claim_reason)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.hospital_address)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.city)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.state)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.pincode)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.treatment_details)}</td>
                      
                      <td class="corp-td">{blank_dash(claim.remarks)}</td>
                      
                      <td class="corp-td">{portal_label(claim.portal_id)}</td>
                      
                      <td class="corp-td">{format_datetime(claim.submitted_at)}</td>
                      
                      <td class="corp-td">{format_datetime(claim.inserted_at)}</td>
                      
                      <td class="corp-td">
                        <button
                          type="button"
                          phx-click="view_documents"
                          phx-value-id={claim.id}
                          class="btn-primary text-xs px-3 py-1"
                        >
                          View
                        </button>
                      </td>
                      
                      <td class="corp-td">
                        <button
                          type="button"
                          phx-click="view_logs"
                          phx-value-id={claim.id}
                          class="btn-secondary text-xs px-3 py-1"
                        >
                          View
                        </button>
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>
          
          <div class="flex items-center justify-between p-4 border-t border-gray-200">
            <div class="text-sm text-gray-500">
              Showing {if @claims_page.total_entries == 0,
                do: 0,
                else: (@claims_page.page - 1) * @claims_page.page_size + 1} to {min(
                @claims_page.page * @claims_page.page_size,
                @claims_page.total_entries
              )} of {@claims_page.total_entries} entries
            </div>
            
            <div class="flex items-center gap-2">
              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page - 1}
                class="btn btn-sm btn-secondary"
                disabled={@claims_page.page <= 1}
              >
                Previous
              </button>
              
              <span class="text-sm font-medium px-3 py-1 border rounded-md">
                {@claims_page.page} / {@claims_page.total_pages}
              </span>
              
              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page + 1}
                class="btn btn-sm btn-primary"
                disabled={@claims_page.page >= @claims_page.total_pages}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <%= if @show_documents_modal and @selected_claim do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div class="w-full max-w-4xl rounded-2xl bg-white p-6 shadow-2xl">
            <div class="flex items-start justify-between gap-4 mb-4">
              <div>
                <h3 class="text-lg font-semibold">Claim Documents</h3>
                
                <p class="text-sm text-gray-500">
                  {@selected_claim.claim_number} - {@selected_claim.patient_name}
                </p>
              </div>
              
              <button
                type="button"
                phx-click="close_modal"
                class="text-gray-400 transition hover:text-gray-600"
              >
                <.icon name="hero-x-mark" class="w-5 h-5" />
              </button>
            </div>
            
            <div class="overflow-x-auto">
              <table class="corp-table">
                <thead>
                  <tr>
                    <th class="corp-th">SI NO</th>
                    
                    <th class="corp-th">Document Name</th>
                    
                    <th class="corp-th">Attachment</th>
                    
                    <th class="corp-th">Uploaded At</th>
                  </tr>
                </thead>
                
                <tbody>
                  <%= if @selected_claim.documents == [] do %>
                    <tr class="corp-empty-row">
                      <td colspan="4" class="corp-empty-cell">No documents uploaded.</td>
                    </tr>
                  <% else %>
                    <%= for {document, index} <- Enum.with_index(@selected_claim.documents, 1) do %>
                      <tr class="corp-tr">
                        <td class="corp-td">{index}</td>
                        
                        <td class="corp-td">{document.document_name}</td>
                        
                        <td class="corp-td">
                          <a
                            href={static_upload_path(document.file_path)}
                            target="_blank"
                            class="text-blue-600 hover:underline"
                          >
                            {document.original_file_name}
                          </a>
                        </td>
                        
                        <td class="corp-td">{format_datetime(document.inserted_at)}</td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      <% end %>
      
      <%= if @show_logs_modal and @selected_claim do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div class="w-full max-w-5xl rounded-2xl bg-white p-6 shadow-2xl">
            <div class="flex items-start justify-between gap-4 mb-4">
              <div>
                <h3 class="text-lg font-semibold">Claim Logs</h3>
                
                <p class="text-sm text-gray-500">
                  Complete audit trail for {@selected_claim.claim_number}
                </p>
              </div>
              
              <button
                type="button"
                phx-click="close_modal"
                class="text-gray-400 transition hover:text-gray-600"
              >
                <.icon name="hero-x-mark" class="w-5 h-5" />
              </button>
            </div>
            
            <div class="overflow-x-auto">
              <table class="corp-table">
                <thead>
                  <tr>
                    <th class="corp-th">SI NO</th>
                    
                    <th class="corp-th">Claim ID</th>
                    
                    <th class="corp-th">Policy ID</th>
                    
                    <th class="corp-th">Portal ID</th>
                    
                    <th class="corp-th">Submitted By</th>
                    
                    <th class="corp-th">Action</th>
                    
                    <th class="corp-th">User ID</th>
                    
                    <th class="corp-th">Timestamp</th>
                    
                    <th class="corp-th">Remarks</th>
                  </tr>
                </thead>
                
                <tbody>
                  <%= if @selected_claim.logs == [] do %>
                    <tr class="corp-empty-row">
                      <td colspan="9" class="corp-empty-cell">No logs available for this claim.</td>
                    </tr>
                  <% else %>
                    <%= for {log, index} <- Enum.with_index(@selected_claim.logs, 1) do %>
                      <tr class="corp-tr">
                        <td class="corp-td">{index}</td>
                        
                        <td class="corp-td">{log.claim_id}</td>
                        
                        <td class="corp-td">{log.policy_id}</td>
                        
                        <td class="corp-td">{log.portal_id}</td>
                        
                        <td class="corp-td">{blank_dash(log.submitted_by)}</td>
                        
                        <td class="corp-td">{log.action}</td>
                        
                        <td class="corp-td">{blank_dash(log.user_id)}</td>
                        
                        <td class="corp-td">{format_datetime(log.inserted_at)}</td>
                        
                        <td class="corp-td">{blank_dash(log.remarks)}</td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.admin>
    """
  end

  defp load_claims(socket, params) do
    claims_page = Claims.list_claims(socket.assigns.current_user, :admin, params)
    assign(socket, :claims_page, claims_page)
  end

  defp stringify(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp sortable_link(assigns, label, field) do
    direction =
      if assigns.claims_page.sort_by == field and assigns.claims_page.sort_dir == "asc",
        do: "desc",
        else: "asc"

    assigns =
      assign(assigns,
        sortable_label: label,
        sortable_field: field,
        sortable_dir: direction
      )

    ~H"""
    <button
      type="button"
      phx-click="sort"
      phx-value-field={@sortable_field}
      phx-value-direction={@sortable_dir}
      class="corp-sort-button"
    >
      {@sortable_label} <.icon name="hero-arrows-up-down" class="w-4 h-4 text-gray-400" />
    </button>
    """
  end

  defp format_date(nil), do: "-"
  defp format_date(%Date{} = date), do: Calendar.strftime(date, "%d-%m-%Y")

  defp format_datetime(nil), do: "-"
  defp format_datetime(%DateTime{} = datetime), do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp format_datetime(%NaiveDateTime{} = datetime),
    do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp format_amount(nil), do: "-"
  defp format_amount(%Decimal{} = amount), do: Decimal.to_string(amount)
  defp format_amount(amount), do: to_string(amount)

  defp portal_label(1), do: "Admin"
  defp portal_label(2), do: "Corporate"
  defp portal_label(3), do: "Employee"
  defp portal_label(_), do: "-"

  defp blank_dash(nil), do: "-"
  defp blank_dash(""), do: "-"
  defp blank_dash(value), do: value

  defp static_upload_path(path) when is_binary(path) do
    "/#{path |> String.replace("\\", "/") |> String.trim_leading("/")}"
  end
end
