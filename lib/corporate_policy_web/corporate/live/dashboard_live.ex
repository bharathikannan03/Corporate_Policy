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

    policy_types = if fetched_types == [], do: ["GMC", "Parent Policy"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["2-81-25-00003017-000"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)
    claim_stats = Policies.get_dashboard_claim_stats(policy_id)

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
      |> assign(:claim_stats, claim_stats)
      |> assign(:active_path, "/corporate/dashboard")

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policies = socket.assigns.policies
    fetched_numbers = get_numbers_for_type(policies, type)
    policy_numbers = if fetched_numbers == [], do: ["2-81-25-00003017-000"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, type, active_policy_number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)
    claim_stats = Policies.get_dashboard_claim_stats(policy_id)

    socket =
      socket
      |> assign(:active_policy_type, type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:list_counts, list_counts)
      |> assign(:claim_stats, claim_stats)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    policies = socket.assigns.policies
    type = socket.assigns.active_policy_type
    selected_policy = get_selected_policy(policies, type, number)
    policy_id = selected_policy && selected_policy.id
    list_counts = Policies.get_policy_list_counts(policy_id)
    claim_stats = Policies.get_dashboard_claim_stats(policy_id)

    socket =
      socket
      |> assign(:active_policy_number, number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:list_counts, list_counts)
      |> assign(:claim_stats, claim_stats)

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
    claim_stats = Policies.get_dashboard_claim_stats(policy_id)

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
      |> assign(:claim_stats, claim_stats)

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
                else: "Aditya Birla Health Insurance Co. Limited"}
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
              {if @selected_policy, do: @selected_policy.policy_number, else: "2-81-25-00003017-000"}
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
                else: "Internal TPA"}
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
              <!-- Inception: 85.5% (Blue) -->
              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#3b82f6"
                stroke-width="4"
                pathLength="100"
                stroke-dasharray="85.5 14.5"
                stroke-dashoffset="0"
              >
              </circle>
              <!-- Addition: 6.6% (Orange/Amber) -->
              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#f59e0b"
                stroke-width="4"
                pathLength="100"
                stroke-dasharray="6.6 93.4"
                stroke-dashoffset="-85.5"
              >
              </circle>
              <!-- Deletion: 7.9% (Green) -->
              <circle
                cx="18"
                cy="18"
                r="14"
                fill="none"
                stroke="#10b981"
                stroke-width="4"
                pathLength="100"
                stroke-dasharray="7.9 92.1"
                stroke-dashoffset="-92.1"
              >
              </circle>
            </svg>
          </div>
           <%!-- Legend --%>
          <div class="w-full space-y-1.5 text-xs text-gray-600 mt-2">
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-blue-500 rounded-xs inline-block"></span>
              <span>Inception Premium: ₹17,10,524</span>
            </div>
            
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-amber-500 rounded-xs inline-block"></span>
              <span>Addition Premium: ₹1,31,931</span>
            </div>
            
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-emerald-500 rounded-xs inline-block"></span>
              <span>Deletion Premium: ₹1,58,041</span>
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
              
              <%= if @claim_stats.claim_analysis_in_ratio.claims_paid_ratio > 0 or @claim_stats.claim_analysis_in_ratio.claims_underprocess_ratio > 0 do %>
                <!-- Claim Ratio (Pink) -->
                <circle
                  cx="18"
                  cy="18"
                  r="14"
                  fill="none"
                  stroke="#ec4899"
                  stroke-width="4"
                  pathLength="100"
                  stroke-dasharray={"#{@claim_stats.claim_analysis_in_ratio.claims_paid_ratio} #{100 - @claim_stats.claim_analysis_in_ratio.claims_paid_ratio}"}
                  stroke-dashoffset="0"
                >
                </circle>
                <!-- Incurred Claim Ratio (Cyan) -->
                <circle
                  cx="18"
                  cy="18"
                  r="14"
                  fill="none"
                  stroke="#06b6d4"
                  stroke-width="4"
                  pathLength="100"
                  stroke-dasharray={"#{@claim_stats.claim_analysis_in_ratio.claims_underprocess_ratio} #{100 - @claim_stats.claim_analysis_in_ratio.claims_underprocess_ratio}"}
                  stroke-dashoffset={"-#{@claim_stats.claim_analysis_in_ratio.claims_paid_ratio}"}
                >
                </circle>
              <% else %>
                <circle cx="18" cy="18" r="14" fill="none" stroke="#e5e7eb" stroke-width="4" />
              <% end %>
            </svg>
          </div>
           <%!-- Legend --%>
          <div class="w-full space-y-1.5 text-xs text-gray-600 mt-2">
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-pink-500 rounded-xs inline-block"></span>
              <span>Claim Ratio: {@claim_stats.claim_analysis_in_ratio.claims_paid_ratio}%</span>
            </div>
            
            <div class="flex items-center space-x-2">
              <span class="w-2.5 h-2.5 bg-cyan-500 rounded-xs inline-block"></span>
              <span>Incurred Claim Ratio: {@claim_stats.claim_analysis_in_ratio.claims_underprocess_ratio}%</span>
            </div>
          </div>
        </div>
         <%!-- Active Employees Card --%>
        <div class="corp-active-employees-card p-5">
          <div
            class="bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white rounded-lg p-6 text-center shadow-md mb-4 flex flex-col justify-center"
            style="min-height: 120px;"
          >
            <h3 class="text-xs font-bold uppercase tracking-wider opacity-90">ACTIVE EMPLOYEES</h3>
            
            <div class="text-4xl font-black mt-2 tracking-tight">
              {@claim_stats.enrollment_list.active_list}
            </div>
          </div>
          
          <div class="space-y-3 flex-1 flex flex-col justify-center">
            <div class="flex items-center justify-between pb-2 border-b border-slate-100 text-xs">
              <span class="text-slate-500 font-medium">Inception Employees</span>
              <.link
                navigate={~p"/corporate/enrollment-details"}
                class="text-blue-600 hover:text-blue-800 underline font-bold"
              >
                {@claim_stats.enrollment_list.inception_list}
              </.link>
            </div>
            
            <div class="flex items-center justify-between pb-2 border-b border-slate-100 text-xs">
              <span class="text-slate-500 font-medium">Addition Employees</span>
              <.link
                navigate={~p"/corporate/enrollment-details"}
                class="text-blue-600 hover:text-blue-800 underline font-bold"
              >
                {@claim_stats.enrollment_list.addition_list}
              </.link>
            </div>
            
            <div class="flex items-center justify-between text-xs">
              <span class="text-slate-500 font-medium">Deletion Employees</span>
              <.link
                navigate={~p"/corporate/enrollment-details"}
                class="text-blue-600 hover:text-blue-800 underline font-bold"
              >
                {@claim_stats.enrollment_list.deletion_list}
              </.link>
            </div>
          </div>
        </div>
      </div>
       <%!-- Bottom Row: Claims Analysis (Amount) & Claims Analysis (Count) --%>
      <div class="corp-claims-grid">
        <%!-- Claims Analysis (In Amount) --%>
        <div class="corp-claims-card">
          <h3 class="corp-card-title text-left mb-4">CLAIMS ANALYSIS (IN AMOUNT)</h3>
           <% paid = @claim_stats.claim_analysis_in_amount.claims_paid
          underprocess = @claim_stats.claim_analysis_in_amount.claims_underprocess
          closed = @claim_stats.claim_analysis_in_amount.claims_closed
          rejected = @claim_stats.claim_analysis_in_amount.claims_rejected
          total_amount = paid + underprocess + closed + rejected

          {p_pct, up_pct, c_pct, r_pct} =
            if total_amount > 0 do
              {
                paid / total_amount * 100.0,
                underprocess / total_amount * 100.0,
                closed / total_amount * 100.0,
                rejected / total_amount * 100.0
              }
            else
              {0.0, 0.0, 0.0, 0.0}
            end %>
          <%= if total_amount > 0 do %>
            <div class="flex-1 flex flex-col justify-between">
              <div class="relative w-44 h-44 my-2 mx-auto flex items-center justify-center">
                <svg class="w-full h-full transform -rotate-90" viewBox="0 0 32 32">
                  <!-- Paid (Blue) -->
                  <%= if p_pct > 0 do %>
                    <circle
                      cx="16"
                      cy="16"
                      r="8"
                      fill="none"
                      stroke="#3b82f6"
                      stroke-width="16"
                      pathLength="100"
                      stroke-dasharray={"#{p_pct} #{100 - p_pct}"}
                      stroke-dashoffset="0"
                    />
                  <% end %>
                  <!-- Under Process (Orange) -->
                  <%= if up_pct > 0 do %>
                    <circle
                      cx="16"
                      cy="16"
                      r="8"
                      fill="none"
                      stroke="#f59e0b"
                      stroke-width="16"
                      pathLength="100"
                      stroke-dasharray={"#{up_pct} #{100 - up_pct}"}
                      stroke-dashoffset={"-#{p_pct}"}
                    />
                  <% end %>
                  <!-- Closed (Green) -->
                  <%= if c_pct > 0 do %>
                    <circle
                      cx="16"
                      cy="16"
                      r="8"
                      fill="none"
                      stroke="#10b981"
                      stroke-width="16"
                      pathLength="100"
                      stroke-dasharray={"#{c_pct} #{100 - c_pct}"}
                      stroke-dashoffset={"-#{p_pct + up_pct}"}
                    />
                  <% end %>
                  <!-- Rejected (Pink) -->
                  <%= if r_pct > 0 do %>
                    <circle
                      cx="16"
                      cy="16"
                      r="8"
                      fill="none"
                      stroke="#ec4899"
                      stroke-width="16"
                      pathLength="100"
                      stroke-dasharray={"#{r_pct} #{100 - r_pct}"}
                      stroke-dashoffset={"-#{p_pct + up_pct + c_pct}"}
                    />
                  <% end %>
                </svg>
              </div>
               <%!-- Legend Centered bottom --%>
              <div class="flex flex-wrap items-center justify-center gap-x-4 gap-y-1 text-xs text-slate-600 mt-4 border-t border-slate-100 pt-3">
                <div class="flex items-center space-x-1.5">
                  <span class="w-2.5 h-2.5 rounded-full bg-blue-500 inline-block"></span>
                  <span class="font-medium">Paid: {format_currency(paid)}</span>
                </div>
                
                <div class="flex items-center space-x-1.5">
                  <span class="w-2.5 h-2.5 rounded-full bg-amber-500 inline-block"></span>
                  <span class="font-medium">Under Process: {format_currency(underprocess)}</span>
                </div>
                
                <div class="flex items-center space-x-1.5">
                  <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 inline-block"></span>
                  <span class="font-medium">Closed: {format_currency(closed)}</span>
                </div>
                
                <div class="flex items-center space-x-1.5">
                  <span class="w-2.5 h-2.5 rounded-full bg-pink-500 inline-block"></span>
                  <span class="font-medium">Rejected: {format_currency(rejected)}</span>
                </div>
              </div>
            </div>
          <% else %>
            <div class="corp-no-data flex-1 flex items-center justify-center">
              No Data Found
            </div>
          <% end %>
        </div>
         <%!-- Claims Analysis (In Count) --%>
        <div class="corp-claims-card">
          <h3 class="corp-card-title text-left mb-4">CLAIM ANALYSIS (IN COUNT)</h3>
           <% paid_count = @claim_stats.claim_analysis_in_count.claims_paid_count
          underprocess_count = @claim_stats.claim_analysis_in_count.claims_underprocess_count
          closed_count = @claim_stats.claim_analysis_in_count.claims_closed_count
          rejected_count = @claim_stats.claim_analysis_in_count.claims_rejected_count
          reported_count = @claim_stats.claim_analysis_in_count.reported_claims_count

          max_val = Enum.max([paid_count, underprocess_count, closed_count, rejected_count])
          max_val = if max_val == 0, do: 4, else: max_val %>
          <%= if reported_count > 0 do %>
            <div class="flex-1 flex flex-col justify-between">
              <svg class="w-full h-48" viewBox="0 0 450 200">
                <!-- Horizontal Grid Lines -->
                <line
                  x1="40"
                  y1="20"
                  x2="430"
                  y2="20"
                  stroke="#f1f5f9"
                  stroke-dasharray="3 3"
                  stroke-width="1"
                />
                <line
                  x1="40"
                  y1="55"
                  x2="430"
                  y2="55"
                  stroke="#f1f5f9"
                  stroke-dasharray="3 3"
                  stroke-width="1"
                />
                <line
                  x1="40"
                  y1="90"
                  x2="430"
                  y2="90"
                  stroke="#f1f5f9"
                  stroke-dasharray="3 3"
                  stroke-width="1"
                />
                <line
                  x1="40"
                  y1="125"
                  x2="430"
                  y2="125"
                  stroke="#f1f5f9"
                  stroke-dasharray="3 3"
                  stroke-width="1"
                /> <line x1="40" y1="160" x2="430" y2="160" stroke="#cbd5e1" stroke-width="1" />
                <!-- Y-Axis Labels -->
                <text x="30" y="24" font-size="10" fill="#64748b" text-anchor="end">
                  {format_y_label(max_val)}
                </text>
                
                <text x="30" y="59" font-size="10" fill="#64748b" text-anchor="end">
                  {format_y_label(max_val * 0.75)}
                </text>
                
                <text x="30" y="94" font-size="10" fill="#64748b" text-anchor="end">
                  {format_y_label(max_val * 0.5)}
                </text>
                
                <text x="30" y="129" font-size="10" fill="#64748b" text-anchor="end">
                  {format_y_label(max_val * 0.25)}
                </text>
                
                <text x="30" y="164" font-size="10" fill="#64748b" text-anchor="end">0</text>
                <!-- Bars -->
                <!-- Paid -->
                <% paid_h = paid_count / max_val * 140 %>
                <%= if paid_h > 0 do %>
                  <rect x="70" y={160 - paid_h} width="35" height={paid_h} fill="#3b82f6" rx="4" />
                <% end %>
                <!-- Under Process -->
                <% up_h = underprocess_count / max_val * 140 %>
                <%= if up_h > 0 do %>
                  <rect x="165" y={160 - up_h} width="35" height={up_h} fill="#f59e0b" rx="4" />
                <% end %>
                <!-- Closed -->
                <% closed_h = closed_count / max_val * 140 %>
                <%= if closed_h > 0 do %>
                  <rect x="260" y={160 - closed_h} width="35" height={closed_h} fill="#10b981" rx="4" />
                <% end %>
                <!-- Rejected -->
                <% rejected_h = rejected_count / max_val * 140 %>
                <%= if rejected_h > 0 do %>
                  <rect
                    x="355"
                    y={160 - rejected_h}
                    width="35"
                    height={rejected_h}
                    fill="#ec4899"
                    rx="4"
                  />
                <% end %>
                <!-- X-Axis Labels -->
                <text
                  x="87.5"
                  y="180"
                  font-size="10"
                  fill="#64748b"
                  text-anchor="middle"
                  font-weight="500"
                >
                  Paid
                </text>
                
                <text
                  x="182.5"
                  y="180"
                  font-size="10"
                  fill="#64748b"
                  text-anchor="middle"
                  font-weight="500"
                >
                  Under Process
                </text>
                
                <text
                  x="277.5"
                  y="180"
                  font-size="10"
                  fill="#64748b"
                  text-anchor="middle"
                  font-weight="500"
                >
                  Closed
                </text>
                
                <text
                  x="372.5"
                  y="180"
                  font-size="10"
                  fill="#64748b"
                  text-anchor="middle"
                  font-weight="500"
                >
                  Rejected
                </text>
              </svg>
               <%!-- Legend / Totals --%>
              <div class="flex flex-wrap items-center justify-center gap-x-4 gap-y-1 text-xs text-slate-600 mt-4 border-t border-slate-100 pt-3">
                <div class="flex items-center space-x-1">
                  <span class="w-2 h-2 rounded-full bg-blue-500 inline-block"></span>
                  <span>Paid: {paid_count}</span>
                </div>
                
                <div class="flex items-center space-x-1">
                  <span class="w-2 h-2 rounded-full bg-amber-500 inline-block"></span>
                  <span>Under Process: {underprocess_count}</span>
                </div>
                
                <div class="flex items-center space-x-1">
                  <span class="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span>
                  <span>Closed: {closed_count}</span>
                </div>
                
                <div class="flex items-center space-x-1">
                  <span class="w-2 h-2 rounded-full bg-pink-500 inline-block"></span>
                  <span>Rejected: {rejected_count}</span>
                </div>
                
                <div class="flex items-center space-x-1 font-bold">
                  <span>Total: {reported_count}</span>
                </div>
              </div>
            </div>
          <% else %>
            <div class="corp-no-data flex-1 flex items-center justify-center">
              No Data Found
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.corporate>
    """
  end

  # ─── Helpers ─────────────────────────────────────────────────────────────────

  defp format_currency(amount) do
    if is_number(amount) do
      parts = :erlang.float_to_binary(amount / 1.0, decimals: 2) |> String.split(".")
      integer_part = Enum.at(parts, 0)
      decimal_part = Enum.at(parts, 1)

      "₹" <> format_indian_style(integer_part) <> "." <> decimal_part
    else
      "₹0.00"
    end
  end

  defp format_indian_style(num_str) when is_binary(num_str) do
    len = String.length(num_str)

    cond do
      len <= 3 ->
        num_str

      true ->
        {rest, last_three} = String.split_at(num_str, -3)
        rest_formatted = format_twos(rest)
        rest_formatted <> "," <> last_three
    end
  end

  defp format_twos(str) do
    str
    |> String.reverse()
    |> String.codepoints()
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.join/1)
    |> Enum.join(",")
    |> String.reverse()
  end

  defp format_y_label(val) when is_float(val) do
    if val == Float.floor(val) do
      round(val)
    else
      Float.round(val, 1)
    end
  end

  defp format_y_label(val), do: val

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
      is_nil(policy) -> "Internal TPA"
      is_binary(policy.select_tpa) and policy.select_tpa != "" -> policy.select_tpa
      policy.tpa_ref -> policy.tpa_ref.name
      true -> "Internal TPA"
    end
  end

  defp format_policy_period(%{policy_start_date: s, policy_end_date: e})
       when not is_nil(s) and not is_nil(e) do
    "#{format_date(s)} to #{format_date(e)}"
  end

  defp format_policy_period(_), do: "25-07-2025 to 24-07-2026"

  defp format_date(%Date{} = d), do: Calendar.strftime(d, "%d-%m-%Y")
  defp format_date(d) when is_binary(d), do: d
  defp format_date(_), do: ""
end
