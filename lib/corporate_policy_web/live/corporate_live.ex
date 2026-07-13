defmodule CorporatePolicyWeb.CorporateLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    corporates = Corporates.list_corporates()

    socket =
      socket
      |> assign(:page_title, "All Corporates")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/corporate")
      |> stream(:corporates, corporates)
      |> assign(:corporates_empty?, corporates == [])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="corp-list-page">
        <%!-- Page header --%>
        <div class="corp-list-header" id="corp-list-header">
          <div>
            <h1 class="corp-list-title">All Corporates</h1>
            <p class="corp-list-subtitle">Manage corporate accounts and their details</p>
          </div>
          <.link navigate={~p"/admin/corporate/new"} id="add-corporate-btn" class="btn-primary">
            <.icon name="hero-plus" class="w-4 h-4" /> Add Corporate
          </.link>
        </div>

        <%!-- Table card --%>
        <div class="corp-table-card" id="corp-table-card">
          <table class="corp-table" id="corporates-table">
            <thead>
              <tr>
                <th class="corp-th">#</th>
                <th class="corp-th">Corporate Name</th>
                <th class="corp-th">Group Code</th>
                <th class="corp-th">City</th>
                <th class="corp-th">State</th>
                <th class="corp-th">PAN Number</th>
                <th class="corp-th">Status</th>
                <th class="corp-th">Actions</th>
              </tr>
            </thead>
            <tbody id="corporates-tbody" phx-update="stream">
              <tr class="hidden only:table-row corp-empty-row">
                <td colspan="8" class="corp-empty-cell">
                  <div class="corp-empty-state" id="corp-empty-state">
                    <.icon name="hero-building-office-2" class="w-12 h-12 text-gray-300 mb-3" />
                    <p class="corp-empty-text">No corporates yet</p>
                    <.link
                      navigate={~p"/admin/corporate/new"}
                      class="btn-primary mt-4"
                      id="add-first-corporate-btn"
                    >
                      Add your first corporate
                    </.link>
                  </div>
                </td>
              </tr>
              <%= for {id, corp} <- @streams.corporates do %>
                <tr id={id} class="corp-tr">
                  <td class="corp-td">{corp.corporate_id}</td>
                  <td class="corp-td corp-td--name">{corp.corporate_name}</td>
                  <td class="corp-td">
                    <span class="corp-code-badge">{corp.corporate_group_code}</span>
                  </td>
                  <td class="corp-td">{corp.city}</td>
                  <td class="corp-td">{corp.state}</td>
                  <td class="corp-td">{corp.pan_number}</td>
                  <td class="corp-td">
                    <%= if corp.corporate_status == 1 do %>
                      <span class="corp-status corp-status--active">Active</span>
                    <% else %>
                      <span class="corp-status corp-status--inactive">Inactive</span>
                    <% end %>
                  </td>
                  <td class="corp-td">
                    <div class="corp-actions">
                      <button
                        class="corp-action-btn corp-action-btn--view"
                        title="View"
                        id={"view-corp-#{corp.corporate_id}"}
                      >
                        <.icon name="hero-eye" class="w-4 h-4" />
                      </button>
                      <button
                        class="corp-action-btn corp-action-btn--edit"
                        title="Edit"
                        id={"edit-corp-#{corp.corporate_id}"}
                      >
                        <.icon name="hero-pencil" class="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
