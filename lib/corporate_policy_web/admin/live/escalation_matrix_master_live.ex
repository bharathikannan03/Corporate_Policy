defmodule CorporatePolicyWeb.Admin.EscalationMatrixMasterLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.EscalationMatrices

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    socket =
      socket
      |> assign(:page_title, "Escalation Matrix Users Master")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/escalation-matrix/user-master")
      |> assign(:deleting_id, nil)
      |> stream_configure(:escalation_matrices,
        dom_id: fn item -> "escalation-matrix-#{item.id}" end
      )
      |> fetch_page(1)

    {:ok, socket}
  end

  @impl true
  def handle_event("prev_page", _params, socket) do
    page = max(1, socket.assigns.page - 1)
    {:noreply, fetch_page(socket, page)}
  end

  @impl true
  def handle_event("next_page", _params, socket) do
    page = min(socket.assigns.total_pages, socket.assigns.page + 1)
    {:noreply, fetch_page(socket, page)}
  end

  @impl true
  def handle_event("delete_click", %{"id" => id}, socket) do
    {:noreply, assign(socket, deleting_id: id)}
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, deleting_id: nil)}
  end

  @impl true
  def handle_event("confirm_delete", _, socket) do
    case socket.assigns.deleting_id do
      nil ->
        {:noreply, socket}

      id ->
        record = EscalationMatrices.get_escalation_matrix!(id)

        case EscalationMatrices.delete_escalation_matrix(record) do
          {:ok, _deleted_rec} ->
            {:noreply,
             socket
             |> put_flash(:info, "User Escalation Matrix deleted successfully")
             |> assign(:deleting_id, nil)
             |> fetch_page(socket.assigns.page)}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Failed to delete User Escalation Matrix")
             |> assign(:deleting_id, nil)}
        end
    end
  end

  defp fetch_page(socket, page) do
    pagination = EscalationMatrices.list_escalation_matrices_paginated(page: page, limit: 10)

    {page, pagination} =
      if page > pagination.total_pages and pagination.total_pages > 0 do
        p = pagination.total_pages
        {p, EscalationMatrices.list_escalation_matrices_paginated(page: p, limit: 10)}
      else
        {page, pagination}
      end

    socket
    |> assign(:page, page)
    |> assign(:total_pages, pagination.total_pages)
    |> assign(:total_count, pagination.total_count)
    |> assign(:records_empty?, pagination.records == [])
    |> stream(:escalation_matrices, pagination.records, reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="escalation-master-page">
        <!-- Page header -->
        <div class="corp-list-header" id="escalation-master-header">
          <div>
            <h1 class="corp-list-title">Escalation Matrix Users Master</h1>
            
            <p class="corp-list-subtitle">Manage escalation matrix users, contacts, and roles</p>
          </div>
          
          <div class="header-actions">
            <.link
              href={~p"/admin/escalation-matrix/export"}
              target="_blank"
              class="btn-export"
              id="export-escalation-btn"
              data-phx-no-disconnect
            >
              <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-1" /> Export
            </.link>
            
            <.link
              navigate={~p"/admin/escalation-matrix/add-user"}
              id="add-escalation-user-btn"
              class="btn-primary"
            >
              <.icon name="hero-plus" class="w-4 h-4" /> Add User
            </.link>
          </div>
        </div>
        <!-- Table card -->
        <div class="corp-table-card mt-6" id="escalation-table-card">
          <div class="overflow-x-auto">
            <table class="corp-table" id="escalation-table">
              <thead>
                <tr>
                  <th class="corp-th">SI NO</th>
                  
                  <th class="corp-th">Full Name</th>
                  
                  <th class="corp-th">Phone Number</th>
                  
                  <th class="corp-th">Mobile Number</th>
                  
                  <th class="corp-th">Email</th>
                  
                  <th class="corp-th">Alt Email</th>
                  
                  <th class="corp-th">Address</th>
                  
                  <th class="corp-th">Type</th>
                  
                  <th class="corp-th">Status</th>
                  
                  <th class="corp-th">Created At</th>
                  
                  <th class="corp-th">Actions</th>
                </tr>
              </thead>
              
              <tbody id="escalation-tbody" phx-update="stream">
                <tr class="hidden only:table-row corp-empty-row" id="escalation-empty-row">
                  <td colspan="11" class="corp-empty-cell text-center py-12">
                    <div class="corp-empty-state flex flex-col items-center">
                      <.icon name="hero-users" class="w-12 h-12 text-gray-300 mb-3" />
                      <p class="corp-empty-text text-gray-500 font-medium">
                        No escalation matrix users yet
                      </p>
                      
                      <.link
                        navigate={~p"/admin/escalation-matrix/add-user"}
                        class="btn-primary mt-4"
                        id="add-first-escalation-user-btn"
                      >
                        Add your first user
                      </.link>
                    </div>
                  </td>
                </tr>
                
                <%= for {id, matrix} <- @streams.escalation_matrices do %>
                  <tr id={id} class="corp-tr">
                    <td class="corp-td font-medium text-slate-500">{Map.get(matrix, :row_num)}</td>
                    
                    <td class="corp-td corp-td--name font-semibold text-slate-800">
                      {matrix.fullname}
                    </td>
                    
                    <td class="corp-td text-slate-600">{matrix.phone_number || "—"}</td>
                    
                    <td class="corp-td text-slate-600">{matrix.mobile_number}</td>
                    
                    <td class="corp-td text-slate-600">{matrix.email_id}</td>
                    
                    <td class="corp-td text-slate-600">{matrix.alt_email_id || "—"}</td>
                    
                    <td
                      class="corp-td max-w-xs truncate text-slate-600"
                      title={matrix.company_fulladdress}
                    >
                      {matrix.company_fulladdress || "—"}
                    </td>
                    
                    <td class="corp-td">
                      <span class="px-2.5 py-1 text-xs font-semibold rounded-full bg-blue-50 text-blue-700 border border-blue-100">
                        {matrix.type || "—"}
                      </span>
                    </td>
                    
                    <td class="corp-td">
                      <%= if matrix.status == 1 do %>
                        <span class="corp-status corp-status--active">Active</span>
                      <% else %>
                        <span class="corp-status corp-status--inactive">Inactive</span>
                      <% end %>
                    </td>
                    
                    <td class="corp-td text-slate-500">
                      {if matrix.created_at,
                        do: Calendar.strftime(matrix.created_at, "%d-%m-%Y"),
                        else: "—"}
                    </td>
                    
                    <td class="corp-td">
                      <div class="flex items-center gap-2">
                        <.link
                          navigate={~p"/admin/escalation-matrix/edit-user/#{matrix.id}"}
                          class="corp-action-btn-text corp-action-btn-text--edit"
                          id={"edit-btn-#{matrix.id}"}
                        >
                          <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
                        </.link>
                        
                        <button
                          type="button"
                          phx-click="delete_click"
                          phx-value-id={matrix.id}
                          class="corp-action-btn-text corp-action-btn-text--delete"
                          id={"delete-btn-#{matrix.id}"}
                        >
                          <.icon name="hero-trash" class="w-4 h-4 mr-1" /> Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
          <!-- Pagination bar -->
          <%= if @total_pages > 1 do %>
            <div
              class="flex items-center justify-between px-6 py-4 bg-white border-t border-gray-100"
              id="escalation-pagination"
            >
              <div class="flex justify-between flex-1 sm:hidden">
                <button
                  phx-click="prev_page"
                  disabled={@page == 1}
                  class={[
                    "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50",
                    @page == 1 && "opacity-50 cursor-not-allowed"
                  ]}
                  id="btn-prev-mobile"
                >
                  Previous
                </button>
                
                <button
                  phx-click="next_page"
                  disabled={@page == @total_pages}
                  class={[
                    "relative ml-3 inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50",
                    @page == @total_pages && "opacity-50 cursor-not-allowed"
                  ]}
                  id="btn-next-mobile"
                >
                  Next
                </button>
              </div>
              
              <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
                <div>
                  <p class="text-sm text-gray-500 font-medium">
                    Showing page <span class="font-semibold text-blue-600">{@page}</span>
                    of <span class="font-semibold text-slate-700">{@total_pages}</span>
                    (<span class="font-semibold text-slate-700">{@total_count}</span>
                    total records)
                  </p>
                </div>
                
                <div>
                  <nav class="inline-flex items-center gap-1.5" aria-label="Pagination">
                    <button
                      phx-click="prev_page"
                      disabled={@page == 1}
                      class={[
                        "inline-flex items-center justify-center w-8 h-8 rounded-md border border-gray-200 text-gray-500 bg-white hover:bg-gray-50 transition-colors cursor-pointer",
                        @page == 1 && "opacity-50 cursor-not-allowed hover:bg-white"
                      ]}
                      id="btn-prev-desktop"
                    >
                      <span class="sr-only">Previous</span>
                      <.icon name="hero-chevron-left" class="w-4 h-4" />
                    </button>
                    
                    <button
                      phx-click="next_page"
                      disabled={@page == @total_pages}
                      class={[
                        "inline-flex items-center justify-center w-8 h-8 rounded-md border border-gray-200 text-gray-500 bg-white hover:bg-gray-50 transition-colors cursor-pointer",
                        @page == @total_pages && "opacity-50 cursor-not-allowed hover:bg-white"
                      ]}
                      id="btn-next-desktop"
                    >
                      <span class="sr-only">Next</span>
                      <.icon name="hero-chevron-right" class="w-4 h-4" />
                    </button>
                  </nav>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
      <!-- Delete Confirmation Modal -->
      <%= if @deleting_id do %>
        <div
          class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs transition-opacity duration-200"
          id="delete-confirmation-modal"
        >
          <div
            class="bg-white rounded-xl shadow-xl max-w-md w-full overflow-hidden transform scale-100 transition-all border border-slate-100"
            phx-click-away="cancel_delete"
            phx-window-keydown="cancel_delete"
            phx-key="escape"
          >
            <div class="p-6">
              <div class="flex items-center justify-center w-12 h-12 mx-auto bg-red-100 rounded-full text-red-600 mb-4">
                <.icon name="hero-exclamation-triangle" class="w-6 h-6" />
              </div>
              
              <h3 class="text-lg font-semibold text-center text-slate-900 mb-2">
                Delete Escalation Matrix User
              </h3>
              
              <p class="text-slate-600 text-center text-sm">
                Are you sure you want to delete this escalation matrix user? This action cannot be undone.
              </p>
            </div>
            
            <div class="flex items-center justify-end gap-3 px-6 py-4 bg-slate-50 border-t border-slate-100">
              <button
                type="button"
                phx-click="cancel_delete"
                class="btn-secondary px-4 py-2 text-sm font-medium rounded-lg cursor-pointer transition duration-150 hover:bg-slate-200"
                id="confirm-modal-cancel-btn"
              >
                Cancel
              </button>
              
              <button
                type="button"
                phx-click="confirm_delete"
                class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 text-sm font-medium rounded-lg shadow-md cursor-pointer transition duration-150"
                id="confirm-modal-delete-btn"
              >
                Yes, Delete
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.admin>
    """
  end
end
