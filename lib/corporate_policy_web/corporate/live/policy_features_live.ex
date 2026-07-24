defmodule CorporatePolicyWeb.Corporate.PolicyFeaturesLive do
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

    # We must assign policy numbers and active number to avoid layout crash
    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)

    # Build the paginated sum insured list for GMC or active type
    table_entries = build_table_entries(policies, active_policy_type)

    socket =
      socket
      |> assign(:page_title, "Policy Features - Corporate Portal")
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
      # Layous expectations
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:active_path, "/corporate/policy-features")
      # Table data and modal
      |> assign(:table_entries, table_entries)
      |> assign(:show_modal, false)
      |> assign(:selected_policy_number, nil)
      |> assign(:selected_sum_insured, nil)
      |> assign(:modal_features, [])
      |> assign_paginated_entries(table_entries, 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policies = socket.assigns.policies
    table_entries = build_table_entries(policies, type)

    fetched_numbers = get_numbers_for_type(policies, type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)

    socket =
      socket
      |> assign(:active_policy_type, type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:table_entries, table_entries)
      |> assign_paginated_entries(table_entries, 1)

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
    table_entries = build_table_entries(policies, active_policy_type)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)

    socket =
      socket
      |> assign(:current_fy_name, fy_name)
      |> assign(:current_fy_id, fy_id)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:table_entries, table_entries)
      |> assign_paginated_entries(table_entries, 1)

    {:noreply, socket}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)
    {:noreply, assign_paginated_entries(socket, socket.assigns.table_entries, page)}
  end

  @impl true
  def handle_event(
        "show_policy_benefit",
        %{
          "policy-id" => policy_id_str,
          "feature-id" => feature_id_str,
          "policy-number" => policy_number,
          "sum-insured" => sum_insured_str
        },
        socket
      ) do
    policy_id = String.to_integer(policy_id_str)
    feature_id = if feature_id_str == "", do: nil, else: String.to_integer(feature_id_str)

    mapped_values = Policies.list_features_by_identifier(policy_id, feature_id)

    modal_features =
      Enum.map(mapped_values, fn mv ->
        %{
          name: mv.ref_policy_feature_template_field_name,
          value: mv.policy_feature_template_field_value
        }
      end)

    formatted_si =
      case sum_insured_str do
        "" -> nil
        val -> "₹#{val}"
      end

    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:selected_policy_number, policy_number)
      |> assign(:selected_sum_insured, formatted_si)
      |> assign(:modal_features, modal_features)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    socket =
      socket
      |> assign(:show_modal, false)
      |> assign(:selected_policy_number, nil)
      |> assign(:selected_sum_insured, nil)
      |> assign(:modal_features, [])

    {:noreply, socket}
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
      <div class="space-y-4 my-4">
        <%!-- Title Bar --%>
        <div class="bg-white rounded-lg p-4 shadow-xs flex items-center justify-between border border-gray-200">
          <h2 class="text-xl font-bold text-gray-900">Policy Features</h2>
        </div>
         <%!-- Table Display Card --%>
        <div class="bg-white rounded-xl shadow-xs border border-gray-200 p-6">
          <div class="overflow-x-auto corp-table-card mb-4">
            <table class="corp-table">
              <thead>
                <tr>
                  <th class="corp-th p-4 border-b text-left">SI NO</th>
                  
                  <th class="corp-th p-4 border-b text-left">POLICY NUMBER</th>
                  
                  <th class="corp-th p-4 border-b text-left">SUM INSURED</th>
                  
                  <th class="corp-th p-4 border-b text-left">QUICK VIEW</th>
                </tr>
              </thead>
              
              <tbody>
                <%= if Enum.empty?(@paginated_entries.entries) do %>
                  <tr>
                    <td colspan="4" class="p-8 text-center text-slate-500 bg-slate-50">
                      No policies found for this category.
                    </td>
                  </tr>
                <% else %>
                  <%= for entry <- @paginated_entries.entries do %>
                    <tr class="corp-tr hover:bg-slate-50 transition-colors">
                      <td class="corp-td p-4 border-b font-medium text-slate-800">
                        {entry.si_no}
                      </td>
                      
                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.policy_number}
                      </td>
                      
                      <td class="corp-td p-4 border-b text-slate-800">
                        {entry.sum_insured || "-"}
                      </td>
                      
                      <td class="corp-td p-4 border-b text-left">
                        <button
                          type="button"
                          phx-click="show_policy_benefit"
                          phx-value-policy-id={entry.policy_id}
                          phx-value-feature-id={entry.feature_identifier_id || ""}
                          phx-value-policy-number={entry.policy_number}
                          phx-value-sum-insured={entry.sum_insured || ""}
                          class="btn-primary"
                        >
                          <.icon name="hero-eye" class="w-4 h-4" /> <span>Policy Benefit</span>
                        </button>
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
       <%!-- Policy Benefits Details Modal Popup --%>
      <%= if @show_modal do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4 backdrop-blur-xs">
          <div class="w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-2xl bg-white p-6 shadow-2xl space-y-5 border border-slate-200">
            <%!-- Modal Header --%>
            <div class="flex items-start justify-between border-b border-gray-200 pb-3">
              <div>
                <h3 class="text-lg font-bold text-gray-900">
                  Policy Details - {@selected_policy_number}
                  <%= if @selected_sum_insured do %>
                    <span class="text-blue-600 ml-1">| Sum Insured: {@selected_sum_insured}</span>
                  <% end %>
                </h3>
              </div>
              
              <button
                type="button"
                phx-click="close_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors p-1 rounded-lg hover:bg-slate-100"
              >
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>
            </div>
             <%!-- Modal Body --%>
            <div class="py-2">
              <%= if Enum.empty?(@modal_features) do %>
                <div class="bg-slate-50 border border-slate-200 rounded-xl p-10 text-center text-slate-500">
                  <.icon name="hero-exclamation-circle" class="w-12 h-12 mx-auto text-slate-300 mb-3" />
                  <p class="text-base font-semibold">No feature available for this policy</p>
                </div>
              <% else %>
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-5">
                  <%= for feature <- @modal_features do %>
                    <div class="border border-blue-500 rounded-lg overflow-hidden flex flex-col shadow-xs hover:shadow-md transition-shadow">
                      <div class="bg-blue-600 text-white font-semibold px-4 py-2 flex justify-between items-center text-xs">
                        <span class="truncate pr-2">{feature.name}</span>
                        <.icon name="hero-information-circle" class="w-4 h-4 text-white/90 shrink-0" />
                      </div>
                      
                      <div class="bg-white text-slate-700 px-4 py-3 flex-1 text-xs leading-relaxed flex items-center min-h-[60px]">
                        {feature.value}
                      </div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
             <%!-- Modal Footer --%>
            <div class="flex justify-end pt-3 border-t border-gray-100">
              <button
                type="button"
                phx-click="close_modal"
                class="btn btn-secondary px-5 py-2 text-xs"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.corporate>
    """
  end

  # --- Helper Functions ---

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

  defp build_table_entries(policies, active_type) do
    filtered_policies =
      Enum.filter(policies, fn p ->
        type_name = get_policy_type_name(p)
        type_name == active_type or (is_nil(type_name) and active_type == "GMC")
      end)

    filtered_policies
    |> Enum.flat_map(fn p ->
      sum_insureds = Policies.list_sum_insureds_for_policy(p.id)

      if Enum.empty?(sum_insureds) do
        [
          %{
            policy_id: p.id,
            policy_number: p.policy_number,
            sum_insured: nil,
            feature_identifier_id: nil
          }
        ]
      else
        Enum.map(sum_insureds, fn si ->
          %{
            policy_id: p.id,
            policy_number: p.policy_number,
            sum_insured: si.sum_insured,
            feature_identifier_id: si.feature_identifier_id
          }
        end)
      end
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, index} ->
      Map.put(entry, :si_no, index)
    end)
  end

  defp assign_paginated_entries(socket, table_entries, page) do
    assign(socket, :paginated_entries, Pagination.paginate_list(table_entries, page))
  end
end
