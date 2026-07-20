defmodule CorporatePolicyWeb.Admin.CorporateLive do
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

    page = 1
    active_tab = "all"

    pagination = Corporates.list_corporates_paginated(page: page, limit: 15, status: active_tab)

    socket =
      socket
      |> assign(:page_title, "All Corporates")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/corporate")
      |> assign(:active_tab, active_tab)
      |> assign(:page, page)
      |> assign(:total_pages, pagination.total_pages)
      |> assign(:total_count, pagination.total_count)
      |> stream_configure(:corporates, dom_id: fn corp -> "corporates-#{corp.corporate_id}" end)
      |> stream(:corporates, pagination.records)
      |> assign(:corporates_empty?, pagination.records == [])

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
          <%!-- Tabs to filter status --%>
          <div class="status-tabs" id="status-tabs">
            <button
              phx-click="filter_status"
              phx-value-status="all"
              class={["tab-btn", @active_tab == "all" && "tab-btn--active"]}
              id="tab-all"
            >
              ALL
            </button>

            <button
              phx-click="filter_status"
              phx-value-status="active"
              class={["tab-btn", @active_tab == "active" && "tab-btn--active"]}
              id="tab-active"
            >
              ACTIVE
            </button>

            <button
              phx-click="filter_status"
              phx-value-status="inactive"
              class={["tab-btn", @active_tab == "inactive" && "tab-btn--active"]}
              id="tab-inactive"
            >
              IN-ACTIVE
            </button>
          </div>

          <div class="header-actions">
            <.link
              href={~p"/admin/corporate/export?status=#{@active_tab}"}
              target="_blank"
              class="btn-export"
              id="export-corporates-btn"
              data-phx-no-disconnect
            >
              <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-1" /> Export
            </.link>

            <.link navigate={~p"/admin/corporate/new"} id="add-corporate-btn" class="btn-primary">
              <.icon name="hero-plus" class="w-4 h-4" /> Add Corporate
            </.link>
          </div>
        </div>
        <%!-- Table card --%>
        <div class="corp-table-card" id="corp-table-card">
          <div class="overflow-x-auto">
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
                <tr class="hidden only:table-row corp-empty-row" id="corporates-empty-row">
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
                    <td class="corp-td">{Map.get(corp, :row_num)}</td>

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
                        <.link
                          navigate={~p"/admin/corporate/#{corp.corporate_id}/edit"}
                          class="corp-action-btn-text corp-action-btn-text--edit"
                          title="Edit Corporate"
                          id={"edit-corp-#{corp.corporate_id}"}
                        >
                          <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit Corporate
                        </.link>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
          <%!-- Pagination bar --%>
          <%= if @total_pages > 1 do %>
            <div
              class="flex items-center justify-between px-6 py-4 bg-white border-t border-gray-100"
              id="corporates-pagination"
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
                  <p class="text-sm text-gray-500">
                    Showing page <span class="font-semibold text-gray-700">{@page}</span>
                    of <span class="font-semibold text-gray-700">{@total_pages}</span>
                    (<span class="font-semibold text-gray-700">{@total_count}</span>
                    total records)
                  </p>
                </div>

                <div>
                  <nav class="inline-flex items-center gap-1" aria-label="Pagination">
                    <button
                      phx-click="prev_page"
                      disabled={@page == 1}
                      class={[
                        "inline-flex items-center justify-center w-8 h-8 rounded-md border border-gray-200 text-gray-500 bg-white hover:bg-gray-50 transition-colors",
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
                        "inline-flex items-center justify-center w-8 h-8 rounded-md border border-gray-200 text-gray-500 bg-white hover:bg-gray-50 transition-colors",
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
    </Layouts.admin>
    """
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    socket =
      socket
      |> assign(:active_tab, status)
      |> fetch_page(1)

    {:noreply, socket}
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

  defp fetch_page(socket, page) do
    active_tab = socket.assigns.active_tab
    pagination = Corporates.list_corporates_paginated(page: page, limit: 15, status: active_tab)

    socket
    |> assign(:page, page)
    |> assign(:total_pages, pagination.total_pages)
    |> assign(:total_count, pagination.total_count)
    |> assign(:corporates_empty?, pagination.records == [])
    |> stream(:corporates, pagination.records, reset: true)
  end
end
