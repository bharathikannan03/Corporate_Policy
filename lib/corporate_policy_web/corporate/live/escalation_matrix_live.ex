defmodule CorporatePolicyWeb.Corporate.EscalationMatrixLive do
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

    corporate_name =
      (corporate && corporate.corporate_name) ||
        "Vibe Insurance Broking & Advisory Service pvt Ltd"

    corporate_id = corporate && corporate.corporate_id
    financial_years = Policies.list_financial_years()

    all_policies =
      if corporate_id,
        do: Policies.list_active_policies_by_corporate(corporate_id),
        else: Policies.list_active_policies()

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

    policy_types = if fetched_types == [], do: ["GMC", "GPA"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    escalation_matrices = Policies.list_escalation_matrices_for_policy(policy_id)

    socket =
      socket
      |> assign(:page_title, "Escalation Matrix - Corporate Portal")
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
      |> assign(:policy_id, policy_id)
      |> assign(:escalation_matrices, escalation_matrices)
      |> assign(:active_path, "/corporate/escalation-matrix")

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policy_numbers = get_numbers_for_type(socket.assigns.policies, type)
    active_policy_number = List.first(policy_numbers)

    selected_policy =
      get_selected_policy(socket.assigns.policies, type, active_policy_number)

    policy_id = selected_policy && selected_policy.id
    escalation_matrices = Policies.list_escalation_matrices_for_policy(policy_id)

    {:noreply,
     socket
     |> assign(:active_policy_type, type)
     |> assign(:policy_numbers, policy_numbers)
     |> assign(:active_policy_number, active_policy_number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:escalation_matrices, escalation_matrices)}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    selected_policy =
      get_selected_policy(socket.assigns.policies, socket.assigns.active_policy_type, number)

    policy_id = selected_policy && selected_policy.id
    escalation_matrices = Policies.list_escalation_matrices_for_policy(policy_id)

    {:noreply,
     socket
     |> assign(:active_policy_number, number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:escalation_matrices, escalation_matrices)}
  end

  @impl true
  def handle_event("change_financial_year", %{"fy_id" => fy_id_str}, socket) do
    fy_id = String.to_integer(fy_id_str)
    fy = Enum.find(socket.assigns.financial_years, &(&1.id == fy_id))
    fy_name = (fy && fy.year_name) || socket.assigns.current_fy_name

    policies =
      Enum.filter(socket.assigns.all_policies, &(&1.ref_fy_year_id == fy_id))

    fetched_types =
      policies
      |> Enum.map(&get_policy_type_name/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    policy_types = if fetched_types == [], do: ["GMC", "GPA"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    escalation_matrices = Policies.list_escalation_matrices_for_policy(policy_id)

    {:noreply,
     socket
     |> assign(:current_fy_name, fy_name)
     |> assign(:current_fy_id, fy_id)
     |> assign(:policies, policies)
     |> assign(:policy_types, policy_types)
     |> assign(:active_policy_type, active_policy_type)
     |> assign(:policy_numbers, policy_numbers)
     |> assign(:active_policy_number, active_policy_number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:escalation_matrices, escalation_matrices)}
  end

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
      <div class="space-y-4 my-4">
        <%!-- Title Bar --%>
        <div class="bg-white rounded-lg p-4 shadow-xs flex items-center justify-between border border-gray-200">
          <h2 class="text-xl font-bold text-gray-900">Escalation Matrix</h2>
        </div>
        <%!-- Escalation Matrix Cards Display --%>
        <div>
          <%= if Enum.empty?(@escalation_matrices) do %>
            <div class="bg-white rounded-xl shadow-xs border border-gray-200 p-12 text-center text-slate-500">
              <.icon name="hero-exclamation-circle" class="w-12 h-12 mx-auto text-slate-300 mb-3" />
              <p class="text-base font-medium">No user found for this policy.</p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
              <%= for matrix <- @escalation_matrices do %>
                <div class="bg-white rounded-xl shadow-xs border border-gray-200 p-5 relative overflow-hidden transition-all duration-200 hover:shadow-md hover:border-gray-300 flex flex-col justify-between">
                  <%!-- Level Tag --%>
                  <div class="absolute top-0 right-0 bg-amber-400 text-slate-900 font-bold text-[11px] px-3 py-1 rounded-bl-lg shadow-xs uppercase tracking-wider">
                    {matrix[:level] || "Level #{matrix[:escalation_level_id]}"}
                  </div>
                  
                  <div>
                    <%!-- Full Name --%>
                    <h3 class="text-base font-bold text-slate-800 pt-1 pr-16 mb-4">
                      {matrix[:fullname] || "N/A"}
                    </h3>
                    <%!-- Details List --%>
                    <div class="space-y-2.5 text-xs text-slate-600">
                      <%!-- Address --%>
                      <%= if matrix[:company_fulladdress] && matrix[:company_fulladdress] != "" do %>
                        <div class="flex items-start space-x-2.5">
                          <.icon name="hero-home" class="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                          <span class="leading-relaxed font-normal">{matrix.company_fulladdress}</span>
                        </div>
                      <% end %>
                      <%!-- Phone / Mobile --%>
                      <%= if (matrix[:mobile_number] && matrix[:mobile_number] != "") || (matrix[:phone_number] && matrix[:phone_number] != "") do %>
                        <div class="flex items-center space-x-2.5">
                          <.icon name="hero-phone" class="w-4 h-4 text-slate-400 shrink-0" />
                          <span class="font-normal">{matrix[:mobile_number] || matrix[:phone_number]}</span>
                        </div>
                      <% end %>
                      <%!-- Email --%>
                      <%= if matrix[:email_id] && matrix[:email_id] != "" do %>
                        <div class="flex items-center space-x-2.5">
                          <.icon name="hero-envelope" class="w-4 h-4 text-slate-400 shrink-0" />
                          <span class="font-normal text-slate-700 truncate">{matrix.email_id}</span>
                        </div>
                      <% end %>
                      <%!-- Role / Type --%>
                      <%= if matrix[:type] && matrix[:type] != "" do %>
                        <div class="flex items-center space-x-2.5 pt-1 border-t border-slate-100 mt-2">
                          <.icon name="hero-briefcase" class="w-4 h-4 text-slate-400 shrink-0" />
                          <span class="font-medium text-slate-500">{matrix.type}</span>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.corporate>
    """
  end
end
