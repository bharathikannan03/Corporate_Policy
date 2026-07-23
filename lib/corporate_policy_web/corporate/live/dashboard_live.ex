defmodule CorporatePolicyWeb.Corporate.DashboardLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies

  @impl true
  def mount(_params, session, socket) do
    user_id = session["current_user_id"]

    current_user =
      socket.assigns[:current_user] || (user_id && CorporatePolicy.Accounts.get_user(user_id))

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
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)

    socket =
      socket
      |> assign(:page_title, "Corporate Dashboard")
      |> assign(:current_user, current_user)
      |> assign(:corporate, corporate)
      |> assign(:corporate_name, corporate_name)
      |> assign(:corporate_id, corporate_id)
      |> assign(:financial_years, financial_years)
      |> assign(:current_fy_name, current_fy_name)
      |> assign(:current_fy_id, current_fy && current_fy.id)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:list_counts, list_counts)
      |> assign(:active_path, "/corporate/dashboard")

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policies = socket.assigns.policies
    fetched_numbers = get_numbers_for_type(policies, type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, type, active_policy_number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)

    socket =
      socket
      |> assign(:active_policy_type, type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:list_counts, list_counts)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    policies = socket.assigns.policies
    type = socket.assigns.active_policy_type
    selected_policy = get_selected_policy(policies, type, number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)

    socket =
      socket
      |> assign(:active_policy_number, number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:list_counts, list_counts)

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
    policy_numbers = get_numbers_for_type(policies, active_policy_type)
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)

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
      |> assign(:list_counts, list_counts)

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
      <%!-- Top 4 Info Cards Grid --%>
      <div class="corp-info-grid">
        <%!-- Insurer Name --%>
        <div class="corp-info-card">
          <div class="corp-info-icon-box corp-info-icon-box--blue">
            <.icon name="hero-document-text" class="w-6 h-6" />
          </div>

          <div class="min-w-0">
            <p class="corp-info-label">Insurer Name</p>

            <p class="corp-info-value truncate">
              {if @selected_policy,
                do: @selected_policy.select_insurer || get_insurer_name(@selected_policy),
                else: "N/A"}
            </p>
          </div>
        </div>
        <%!-- Policy Number --%>
        <div class="corp-info-card">
          <div class="corp-info-icon-box corp-info-icon-box--red">
            <.icon name="hero-document" class="w-6 h-6" />
          </div>

          <div class="min-w-0">
            <p class="corp-info-label">Policy Number</p>

            <p class="corp-info-value truncate">
              {if @selected_policy, do: @selected_policy.policy_number, else: "N/A"}
            </p>
          </div>
        </div>
        <%!-- Policy Period --%>
        <div class="corp-info-card">
          <div class="corp-info-icon-box corp-info-icon-box--green">
            <.icon name="hero-calendar" class="w-6 h-6" />
          </div>

          <div class="min-w-0">
            <p class="corp-info-label">Policy Period</p>

            <p class="corp-info-value truncate">
              {format_policy_period(@selected_policy)}
            </p>
          </div>
        </div>
        <%!-- TPA --%>
        <div class="corp-info-card">
          <div class="corp-info-icon-box corp-info-icon-box--orange">
            <.icon name="hero-user-group" class="w-6 h-6" />
          </div>

          <div class="min-w-0">
            <p class="corp-info-label">TPA</p>

            <p class="corp-info-value truncate">
              {if @selected_policy,
                do: @selected_policy.select_tpa || get_tpa_name(@selected_policy),
                else: "N/A"}
            </p>
          </div>
        </div>
      </div>
      <%!-- Middle Row: Premium Analysis + Claim Ratio Analysis + Active Employees --%>
      <div class="corp-middle-grid">
        <%!-- Premium Analysis Card --%>
        <div class="corp-chart-card">
          <h3 class="corp-card-title">PREMIUM ANALYSIS</h3>
          <%!-- Donut Chart SVG --%>
          <div class="relative w-44 h-44 my-2 flex items-center justify-center">
            <svg class="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
              <circle cx="18" cy="18" r="14" fill="none" stroke="#e5e7eb" stroke-width="4"></circle>

              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#3b82f6"
                stroke-width="4"
                stroke-dasharray="35 65"
                stroke-dashoffset="0"
              >
              </circle>

              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#10b981"
                stroke-width="4"
                stroke-dasharray="25 75"
                stroke-dashoffset="-35"
              >
              </circle>

              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#f59e0b"
                stroke-width="4"
                stroke-dasharray="15 85"
                stroke-dashoffset="-60"
              >
              </circle>
            </svg>
          </div>
          <%!-- Legend --%>
          <div class="w-full space-y-1.5 text-xs text-gray-600 mt-2">
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-blue-500 rounded-xs inline-block"></span>
              <span>Inception Premium: ₹0</span>
            </div>

            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-amber-500 rounded-xs inline-block"></span>
              <span>Addition Premium: ₹0</span>
            </div>

            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-emerald-500 rounded-xs inline-block"></span>
              <span>Deletion Premium: ₹0</span>
            </div>
          </div>
        </div>
        <%!-- Claim Ratio Analysis Card --%>
        <div class="corp-chart-card">
          <h3 class="corp-card-title">CLAIM RATIO ANALYSIS</h3>
          <%!-- Donut Chart SVG --%>
          <div class="relative w-44 h-44 my-2 flex items-center justify-center">
            <svg class="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
              <circle cx="18" cy="18" r="14" fill="none" stroke="#e5e7eb" stroke-width="4"></circle>

              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#ec4899"
                stroke-width="4"
                stroke-dasharray="50 50"
                stroke-dashoffset="0"
              >
              </circle>

              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#06b6d4"
                stroke-width="4"
                stroke-dasharray="50 50"
                stroke-dashoffset="-50"
              >
              </circle>
            </svg>
          </div>
          <%!-- Legend --%>
          <div class="w-full space-y-1.5 text-xs text-gray-600 mt-2">
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-pink-500 rounded-xs inline-block"></span>
              <span>Claim Ratio: 0%</span>
            </div>

            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-cyan-500 rounded-xs inline-block"></span>
              <span>Incurred Claim Ratio: 0%</span>
            </div>
          </div>
        </div>
        <%!-- Active Employees Card --%>
        <div class="corp-active-employees-card">
          <div class="corp-employees-header">
            <h3 class="corp-employees-header-title">ACTIVE EMPLOYEES</h3>

            <div class="corp-employees-header-count">{@list_counts.active_count}</div>
          </div>

          <div class="corp-employees-rows">
            <div class="corp-emp-row">
              <span class="corp-emp-label">Inception Employees</span>
              <span class="corp-emp-val">{@list_counts.inception_count}</span>
            </div>

            <div class="corp-emp-row">
              <span class="corp-emp-label">Addition Employees</span>
              <span class="corp-emp-val">{@list_counts.addition_count}</span>
            </div>

            <div class="corp-emp-row">
              <span class="corp-emp-label">Deletion Employees</span>
              <span class="corp-emp-val">{@list_counts.deletion_count}</span>
            </div>
          </div>
        </div>
      </div>
      <%!-- Bottom Row: Claims Analysis (Amount) & Claims Analysis (Count) --%>
      <div class="corp-claims-grid">
        <%!-- Claims Analysis (In Amount) --%>
        <div class="corp-claims-card">
          <h3 class="corp-card-title text-left">CLAIMS ANALYSIS (IN AMOUNT)</h3>

          <div class="corp-no-data">
            No Data Found
          </div>
        </div>
        <%!-- Claims Analysis (In Count) --%>
        <div class="corp-claims-card">
          <h3 class="corp-card-title text-left">CLAIM ANALYSIS (IN COUNT)</h3>

          <div class="corp-no-data">
            No Data Found
          </div>
        </div>
      </div>
    </Layouts.corporate>
    """
  end

  # ─── Helpers ─────────────────────────────────────────────────────────────────

  defp get_policy_type_name(policy) do
    policy.policy_type || (policy.policy_type_ref && policy.policy_type_ref.policy_type_value)
  end

  defp get_numbers_for_type(_policies, nil), do: []

  defp get_numbers_for_type(policies, type) do
    policies
    |> Enum.filter(&(get_policy_type_name(&1) == type))
    |> Enum.map(& &1.policy_number)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp get_selected_policy([], _type, _number), do: nil
  defp get_selected_policy(policies, nil, _number), do: List.first(policies)
  defp get_selected_policy(policies, _type, nil), do: List.first(policies)

  defp get_selected_policy(policies, type, number) do
    Enum.find(policies, fn p ->
      get_policy_type_name(p) == type and p.policy_number == number
    end)
  end

  defp get_insurer_name(policy) do
    cond do
      is_nil(policy) -> "N/A"
      is_binary(policy.select_insurer) and policy.select_insurer != "" -> policy.select_insurer
      policy.insurer_ref -> policy.insurer_ref.name
      true -> "N/A"
    end
  end

  defp get_tpa_name(policy) do
    cond do
      is_nil(policy) -> "N/A"
      is_binary(policy.select_tpa) and policy.select_tpa != "" -> policy.select_tpa
      policy.tpa_ref -> policy.tpa_ref.name
      true -> "N/A"
    end
  end

  defp format_policy_period(%{policy_start_date: s, policy_end_date: e})
       when not is_nil(s) and not is_nil(e) do
    "#{format_date(s)} to #{format_date(e)}"
  end

  defp format_policy_period(_), do: "N/A"

  defp format_date(%Date{} = d), do: Calendar.strftime(d, "%d-%m-%Y")
  defp format_date(d) when is_binary(d), do: d
  defp format_date(_), do: ""
end
