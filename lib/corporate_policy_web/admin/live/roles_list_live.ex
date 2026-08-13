defmodule CorporatePolicyWeb.Admin.RolesListLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Accounts
  alias CorporatePolicyWeb.Layouts

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    roles = Corporates.list_roles_configurations()

    roles_with_index =
      Enum.with_index(roles, 1)
      |> Enum.map(fn {role, idx} ->
        Map.put(role, :row_num, idx)
      end)

    socket =
      socket
      |> assign(:page_title, "Roles List")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/roles-configuration/list")
      |> stream(:roles, roles_with_index)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="roles-list-page">
        <!-- Page header -->
        <div class="corp-list-header" id="roles-list-header">
          <div>
            <h1 class="corp-list-title">Roles List</h1>
          </div>
          
          <div class="header-actions">
            <.link
              href={~p"/admin/roles-configuration/export"}
              target="_blank"
              class="btn-export"
              id="export-roles-btn"
              data-phx-no-disconnect
            >
              <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-1" /> Export
            </.link>
          </div>
        </div>
        <!-- Table card -->
        <div class="corp-table-card mt-6" id="roles-table-card">
          <div class="overflow-x-auto">
            <table class="corp-table" id="roles-table">
              <thead>
                <tr>
                  <th class="corp-th">SI NO</th>
                  
                  <th class="corp-th text-left">ROLE NAME</th>
                  
                  <th class="corp-th text-left">ACCESS</th>
                  
                  <th class="corp-th text-left">MAPPED TO</th>
                  
                  <th class="corp-th text-center">STATUS</th>
                  
                  <th class="corp-th text-center">ACTIONS</th>
                </tr>
              </thead>
              
              <tbody id="roles-tbody" phx-update="stream">
                <tr class="hidden only:table-row corp-empty-row" id="roles-empty-row">
                  <td colspan="6" class="corp-empty-cell text-center py-12">
                    <div class="corp-empty-state flex flex-col items-center">
                      <.icon name="hero-cog-6-tooth" class="w-12 h-12 text-gray-300 mb-3" />
                      <p class="corp-empty-text text-gray-500 font-medium">
                        No roles configured yet
                      </p>
                      
                      <.link
                        navigate={~p"/admin/roles-configuration/add"}
                        class="btn-primary mt-4"
                        id="add-first-role-btn"
                      >
                        Add your first role
                      </.link>
                    </div>
                  </td>
                </tr>
                
                <%= for {id, role} <- @streams.roles do %>
                  <tr id={id} class="corp-tr align-top">
                    <td class="corp-td font-medium text-slate-500 text-center">{role.row_num}</td>
                    
                    <td class="corp-td font-semibold text-slate-900">{role.role}</td>
                    
                    <td class="corp-td">
                      <div class="flex flex-col gap-1 text-slate-700 text-xs">
                        <%= for line <- role.access_lines do %>
                          <div>{line}</div>
                        <% end %>
                      </div>
                    </td>
                    
                    <td class="corp-td text-xs text-slate-600 max-w-xs break-words">
                      {role.mapped_to_text}
                    </td>
                    
                    <td class="corp-td text-center">
                      <%= if role.status == 1 do %>
                        <span class="corp-status corp-status--active">ACTIVE</span>
                      <% else %>
                        <span class="corp-status corp-status--inactive">INACTIVE</span>
                      <% end %>
                    </td>
                    
                    <td class="corp-td text-center">
                      <.link
                        navigate={~p"/admin/roles-configuration/#{role.role_id}/edit"}
                        class="btn btn-sm btn-primary inline-flex items-center"
                        id={"edit-role-#{role.role_id}-btn"}
                      >
                        Edit
                      </.link>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
