defmodule CorporatePolicyWeb.Corporate.CashlessHospitalsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Layouts

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
    current_fy_id = current_fy && current_fy.id

    policies =
      if current_fy_id do
        Enum.filter(all_policies, &(&1.ref_fy_year_id == current_fy_id))
      else
        all_policies
      end

    fetched_types =
      policies
      |> Enum.map(&get_policy_type_name/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    policy_types = fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)

    socket =
      socket
      |> assign(:page_title, "Cashless Hospitals - Corporate Portal")
      |> assign(:current_user, current_user)
      |> assign(:corporate, corporate)
      |> assign(:corporate_name, corporate_name)
      |> assign(:corporate_id, corporate_id)
      |> assign(:financial_years, financial_years)
      |> assign(:current_fy_name, current_fy_name)
      |> assign(:current_fy_id, current_fy_id)
      |> assign(:all_policies, all_policies)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:search, "")
      |> assign(:page, 1)
      |> assign(:active_path, "/corporate/cashless-hospitals")
      |> load_hospitals()

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policies = socket.assigns.policies
    fetched_numbers = get_numbers_for_type(policies, type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, type, active_policy_number)

    socket =
      socket
      |> assign(:active_policy_type, type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:page, 1)
      |> load_hospitals()

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    policies = socket.assigns.policies
    type = socket.assigns.active_policy_type
    selected_policy = get_selected_policy(policies, type, number)

    socket =
      socket
      |> assign(:active_policy_number, number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:page, 1)
      |> load_hospitals()

    {:noreply, socket}
  end

  @impl true
  def handle_event("change_fy", %{"fy_name" => fy_name}, socket) do
    financial_years = socket.assigns.financial_years
    selected_fy = Enum.find(financial_years, &(&1.year_name == fy_name))
    fy_id = selected_fy && selected_fy.id
    corporate_id = socket.assigns.corporate_id

    policies =
      if corporate_id do
        Policies.list_active_policies_by_corporate(corporate_id, fy_id)
      else
        []
      end

    policy_types =
      policies
      |> Enum.map(&get_policy_type_name/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    active_policy_type = List.first(policy_types)
    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)

    socket =
      socket
      |> assign(:current_fy_name, fy_name)
      |> assign(:current_fy_id, fy_id)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:page, 1)
      |> load_hospitals()

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_table", %{"search" => search}, socket) do
    socket =
      socket
      |> assign(:search, search)
      |> assign(:page, 1)
      |> load_hospitals()

    {:noreply, socket}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)

    socket =
      socket
      |> assign(:page, page)
      |> load_hospitals()

    {:noreply, socket}
  end

  defp load_hospitals(socket) do
    selected_policy = socket.assigns.selected_policy
    ref_tpa_id = selected_policy && selected_policy.ref_tpa_id

    result =
      Policies.list_cashless_hospitals_by_tpa_paginated(
        ref_tpa_id,
        page: socket.assigns.page,
        search: socket.assigns.search
      )

    socket
    |> assign(:paginated_hospitals, result)
  end

  # ─── Helpers ─────────────────────────────────────────────────────────────────

  defp get_policy_type_name(policy) do
    cond do
      policy.policy_type_ref && Map.get(policy.policy_type_ref, :policy_type_value) ->
        policy.policy_type_ref.policy_type_value

      policy.policy_type_ref && Map.get(policy.policy_type_ref, :name) ->
        policy.policy_type_ref.name

      is_binary(policy.policy_type) and policy.policy_type != "" ->
        policy.policy_type

      true ->
        nil
    end
  end

  defp get_numbers_for_type(_policies, nil), do: []

  defp get_numbers_for_type(policies, target_type) do
    policies
    |> Enum.filter(fn p ->
      type_name = get_policy_type_name(p)
      type_name == target_type or (is_nil(type_name) and target_type == "GMC")
    end)
    |> Enum.map(& &1.policy_number)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp get_selected_policy([], _type, _number), do: nil
  defp get_selected_policy(policies, nil, _number), do: List.first(policies)
  defp get_selected_policy(policies, _type, nil), do: List.first(policies)

  defp get_selected_policy(policies, type, number) do
    Enum.find(policies, fn p ->
      type_name = get_policy_type_name(p)

      (type_name == type or (is_nil(type_name) and type == "GMC")) and
        p.policy_number == number
    end) || List.first(policies)
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
      policy_types={@policy_types}
      active_policy_type={@active_policy_type}
      policy_numbers={@policy_numbers}
      active_policy_number={@active_policy_number}
      active_path={@active_path}
    >
      <div class="space-y-6 my-4">
        <%!-- Title & Search Bar Card --%>
        <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h2 class="text-xl font-bold text-gray-900">Cashless Hospitals</h2>

            <p class="text-xs text-gray-500 mt-1">
              Showing cashless hospitals for TPA:
              <span class="font-semibold text-blue-600">{if @selected_policy &&
                                                              @selected_policy.tpa_ref,
                                                            do: @selected_policy.tpa_ref.name,
                                                            else: "N/A"}</span>
            </p>
          </div>

          <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
            <form id="search-form" phx-change="search_table" class="relative max-w-xs w-full">
              <input
                type="text"
                name="search"
                value={@search}
                placeholder="Search by Hospital Name, City..."
                class="w-full rounded-lg border border-gray-300 pl-10 pr-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              />
              <div class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
                <.icon name="hero-magnifying-glass" class="w-4 h-4" />
              </div>
            </form>

            <.link
              href={
                ~p"/corporate/cashless-hospitals/export?tpa_id={@selected_policy && @selected_policy.ref_tpa_id}&search={@search}"
              }
              class="btn btn-primary text-white flex items-center justify-center gap-2 text-sm font-medium h-10 px-4"
              download
            >
              <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> <span>Export CSV</span>
            </.link>
          </div>
        </div>
        <%!-- Table Display Card --%>
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div class="corp-table-card">
            <div class="overflow-x-auto">
              <table class="corp-table w-full text-left">
                <thead>
                  <tr>
                    <th class="corp-th">#</th>

                    <th class="corp-th">HOSPITAL NAME</th>

                    <th class="corp-th">TPA NAME</th>

                    <th class="corp-th">INSURER NAME</th>

                    <th class="corp-th">CITY</th>

                    <th class="corp-th">STATE</th>

                    <th class="corp-th">PINCODE</th>

                    <th class="corp-th">CONTACT DETAILS</th>

                    <th class="corp-th text-right">ADDRESS</th>
                  </tr>
                </thead>

                <tbody id="cashless-hospitals-table-body">
                  <%= if Enum.empty?(@paginated_hospitals.entries) do %>
                    <tr class="corp-tr">
                      <td colspan="9" class="corp-td text-center text-gray-400 py-12">
                        <div class="flex flex-col items-center justify-center">
                          <.icon name="hero-building-office-2" class="w-12 h-12 text-gray-300 mb-2" />
                          <span>No cashless hospital records found</span>
                        </div>
                      </td>
                    </tr>
                  <% else %>
                    <%= for hospital <- @paginated_hospitals.entries do %>
                      <tr class="corp-tr border-b border-gray-100 hover:bg-gray-50 transition-colors">
                        <td class="corp-td font-medium text-gray-700">{hospital.row_num}</td>

                        <td class="corp-td font-semibold text-gray-900">{hospital.hospital_name}</td>

                        <td class="corp-td text-gray-600">{hospital.tpa_name || "Internal TPA"}</td>

                        <td class="corp-td text-gray-600">{hospital.insurer_name}</td>

                        <td class="corp-td text-gray-700">{hospital.city || "-"}</td>

                        <td class="corp-td text-gray-700">{hospital.state || "-"}</td>

                        <td class="corp-td text-gray-500 font-mono">{hospital.pincode || "-"}</td>

                        <td class="corp-td">
                          <div class="flex flex-col text-xs space-y-1">
                            <%= if hospital.phone && hospital.phone != "" do %>
                              <span class="flex items-center gap-1.5 text-gray-700">
                                <.icon name="hero-phone" class="w-3.5 h-3.5 text-gray-400 shrink-0" /> {hospital.phone}
                              </span>
                            <% end %>

                            <%= if hospital.email && hospital.email != "" do %>
                              <span
                                class="flex items-center gap-1.5 text-gray-700 truncate max-w-[200px]"
                                title={hospital.email}
                              >
                                <.icon
                                  name="hero-envelope"
                                  class="w-3.5 h-3.5 text-gray-400 shrink-0"
                                /> {hospital.email}
                              </span>
                            <% end %>

                            <%= if (is_nil(hospital.phone) || hospital.phone == "") && (is_nil(hospital.email) || hospital.email == "") do %>
                              <span class="text-gray-400">-</span>
                            <% end %>
                          </div>
                        </td>

                        <td
                          class="corp-td text-right text-gray-600 max-w-xs truncate"
                          title={hospital.hospital_address}
                        >
                          {hospital.hospital_address}
                        </td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>
            <%!-- Pagination --%>
            <%= if @paginated_hospitals.total_pages > 1 do %>
              <.pagination
                page={@paginated_hospitals.page}
                page_size={@paginated_hospitals.page_size}
                total_entries={@paginated_hospitals.total_entries}
                total_pages={@paginated_hospitals.total_pages}
                event="paginate_table"
              />
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.corporate>
    """
  end
end
