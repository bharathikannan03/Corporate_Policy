defmodule CorporatePolicyWeb.Corporate.EmployeeActivityLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Layouts
  alias CorporatePolicyWeb.Pagination

  @impl true
  def mount(_params, session, socket) do
    user_id = session["current_user_id"]

    current_user =
      socket.assigns[:current_user] || (user_id && Accounts.get_user(user_id))

    corporate =
      if current_user && current_user.ref_corporate_id do
        Corporates.get_corporate!(current_user.ref_corporate_id)
      else
        nil
      end

    corporate_name = (corporate && corporate.corporate_name) || "Corporate Portal"
    corporate_id = corporate && corporate.corporate_id

    financial_years = Policies.list_financial_years()

    all_policies =
      if corporate_id, do: Policies.list_active_policies_by_corporate(corporate_id), else: []

    current_fy =
      case all_policies do
        [first_policy | _] ->
          first_policy.financial_year_ref || Enum.find(financial_years, &(&1.status == 1)) ||
            List.first(financial_years)

        [] ->
          Enum.find(financial_years, &(&1.status == 1)) || List.first(financial_years)
      end

    current_fy_name = (current_fy && current_fy.year_name) || "2025-2026"

    # Load logs
    logs = if corporate_id, do: Policies.list_employee_logs_by_corporate(corporate_id), else: []

    table_entries =
      logs
      |> Enum.with_index(1)
      |> Enum.map(fn {log, index} ->
        Map.put(log, :si_no, index)
      end)

    socket =
      socket
      |> assign(:page_title, "Employee Activity - Corporate Portal")
      |> assign(:current_user, current_user)
      |> assign(:corporate, corporate)
      |> assign(:corporate_name, corporate_name)
      |> assign(:corporate_id, corporate_id)
      |> assign(:financial_years, financial_years)
      |> assign(:current_fy_name, current_fy_name)
      |> assign(:active_path, "/corporate/employee")
      |> assign(:table_entries, table_entries)
      |> assign_paginated_entries(table_entries, 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)
    {:noreply, assign_paginated_entries(socket, socket.assigns.table_entries, page)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.corporate
      flash={@flash}
      current_user={@current_user}
      corporate={@corporate}
      corporate_name={@corporate_name}
      financial_years={@financial_years}
      current_fy_name={@current_fy_name}
      policy_types={[]}
      active_policy_type=""
      policy_numbers={[]}
      active_policy_number=""
      active_path={@active_path}
    >
      <div class="space-y-4 my-4">
        <%!-- Title Bar --%>
        <div class="bg-white rounded-lg p-4 shadow-xs flex items-center justify-between border border-gray-200">
          <h2 class="text-xl font-bold text-gray-900">Employee Activity</h2>
        </div>
        <%!-- Logs Display Card --%>
        <div class="bg-white rounded-xl shadow-xs border border-gray-200 p-6">
          <%!-- Centered Corporate Name & Export Button Bar --%>
          <div class="flex flex-col md:flex-row md:items-center justify-between pb-4 border-b border-gray-100 mb-6 gap-4">
            <div class="flex-1 text-center md:text-left">
              <h3 class="text-base font-bold text-gray-800 uppercase tracking-wide">
                {@corporate_name}
                <span class="text-slate-400 font-normal lowercase">(Financial Year: {@current_fy_name})</span>
              </h3>
            </div>

            <div>
              <a
                href={~p"/corporate/employee-activity/export"}
                class="btn bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-2 rounded-lg flex items-center gap-2 text-sm transition-colors"
              >
                <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> <span>Export</span>
              </a>
            </div>
          </div>

          <div class="overflow-x-auto corp-table-card mb-4">
            <table class="corp-table">
              <thead>
                <tr>
                  <th class="corp-th p-4 border-b text-left">SI NO</th>

                  <th class="corp-th p-4 border-b text-left">POLICY NUMBER</th>

                  <th class="corp-th p-4 border-b text-left">EMPLOYEE NAME</th>

                  <th class="corp-th p-4 border-b text-left">EMPLOYEE CODE</th>

                  <th class="corp-th p-4 border-b text-left">MOBILE NUMBER</th>

                  <th class="corp-th p-4 border-b text-left">EMAIL ID</th>

                  <th class="corp-th p-4 border-b text-left">ACTION</th>

                  <th class="corp-th p-4 border-b text-left">DEVICE TYPE</th>

                  <th class="corp-th p-4 border-b text-left">CREATED AT</th>
                </tr>
              </thead>

              <tbody>
                <%= if Enum.empty?(@paginated_entries.entries) do %>
                  <tr>
                    <td colspan="9" class="p-8 text-center text-slate-500 bg-slate-50">
                      No activity logs found for this corporate.
                    </td>
                  </tr>
                <% else %>
                  <%= for entry <- @paginated_entries.entries do %>
                    <tr class="corp-tr hover:bg-slate-50 transition-colors">
                      <td class="corp-td p-4 border-b font-medium text-slate-800">
                        {entry.si_no}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800 font-mono text-xs">
                        {entry.policy_number}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800 font-semibold">
                        {entry.employee_name}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.employee_code}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.mobile_number}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.email}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800">
                        <span class="px-2 py-1 bg-slate-100 rounded text-xs font-semibold text-slate-700">
                          {entry.action}
                        </span>
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.device_type}
                      </td>

                      <td class="corp-td p-4 border-b text-slate-800 text-xs">
                        {format_datetime(entry.created_at)}
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>

          <.pagination
            page={@paginated_entries.page}
            page_size={@paginated_entries.page_size}
            total_entries={@paginated_entries.total_entries}
            total_pages={@paginated_entries.total_pages}
            event="paginate_table"
          />
        </div>
      </div>
    </Layouts.corporate>
    """
  end

  defp assign_paginated_entries(socket, table_entries, page) do
    assign(socket, :paginated_entries, Pagination.paginate_list(table_entries, page))
  end

  defp format_datetime(datetime) do
    NaiveDateTime.to_iso8601(datetime) <> "Z"
  end
end
