defmodule CorporatePolicyWeb.Corporate.EnrollmentDetailsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Corporate.PolicyDetailsComponent
  alias CorporatePolicyWeb.Corporate.EnrollmentDetailsLive.ListView
  alias CorporatePolicyWeb.Layouts

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

    corporate_name =
      (corporate && corporate.corporate_name) ||
        "Vibe Insurance Broking & Advisory Service pvt Ltd"

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

    policy_types = if fetched_types == [], do: ["GMC", "GPA"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    member_counts = Policies.get_policy_member_counts(policy_id)

    filter_params = %{
      "page" => 1,
      "employee_name" => "",
      "employee_code" => "",
      "sum_insured" => "",
      "mobile_number" => "",
      "email" => ""
    }

    employees_page = Policies.list_policy_employees_paginated(policy_id, filter_params)

    # List View States
    active_list_type = "active"
    list_counts = Policies.get_policy_list_counts(policy_id)

    list_filter_params = %{
      "page" => 1,
      "employee_name" => "",
      "employee_code" => "",
      "sum_insured" => "",
      "mobile_number" => "",
      "email" => ""
    }

    list_view_page =
      Policies.list_policy_list_view_paginated(policy_id, active_list_type, list_filter_params)

    socket =
      socket
      |> assign(:page_title, "Enrollment Details")
      |> assign(:current_user, current_user)
      |> assign(:corporate, corporate)
      |> assign(:corporate_name, corporate_name)
      |> assign(:corporate_id, corporate_id)
      |> assign(:financial_years, financial_years)
      |> assign(:current_fy_name, current_fy_name)
      |> assign(:current_fy_id, current_fy_id)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:member_counts, member_counts)
      |> assign(:show_policy_details, true)
      |> assign(:active_nav_tab, "enrollment_details")
      |> assign(:filter_params, filter_params)
      |> assign(:employees_page, employees_page)
      # List View Assigns
      |> assign(:active_list_type, active_list_type)
      |> assign(:list_counts, list_counts)
      |> assign(:list_filter_params, list_filter_params)
      |> assign(:list_view_page, list_view_page)
      |> assign(:active_path, "/corporate/enrollment-details")
      # Dependent Modal State
      |> assign(:show_dependents_modal, false)
      |> assign(:selected_employee_code, nil)
      |> assign(:selected_employee_name, nil)
      |> assign(:dependent_search, "")
      |> assign(:dependent_page_num, 1)
      |> assign(:dependents_page, %{
        entries: [],
        page: 1,
        page_size: 10,
        total_entries: 0,
        total_pages: 1
      })

    {:ok, socket}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policies = socket.assigns.policies
    fetched_numbers = get_numbers_for_type(policies, type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)
    selected_policy = get_selected_policy(policies, type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    member_counts = Policies.get_policy_member_counts(policy_id)
    filter_params = Map.put(socket.assigns.filter_params, "page", 1)
    employees_page = Policies.list_policy_employees_paginated(policy_id, filter_params)

    list_counts = Policies.get_policy_list_counts(policy_id)

    list_view_page =
      Policies.list_policy_list_view_paginated(
        policy_id,
        socket.assigns.active_list_type,
        socket.assigns.list_filter_params
      )

    socket =
      socket
      |> assign(:active_policy_type, type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:member_counts, member_counts)
      |> assign(:filter_params, filter_params)
      |> assign(:employees_page, employees_page)
      |> assign(:list_counts, list_counts)
      |> assign(:list_view_page, list_view_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    policies = socket.assigns.policies
    type = socket.assigns.active_policy_type
    selected_policy = get_selected_policy(policies, type, number)
    policy_id = selected_policy && selected_policy.id

    member_counts = Policies.get_policy_member_counts(policy_id)
    filter_params = Map.put(socket.assigns.filter_params, "page", 1)
    employees_page = Policies.list_policy_employees_paginated(policy_id, filter_params)

    list_counts = Policies.get_policy_list_counts(policy_id)

    list_view_page =
      Policies.list_policy_list_view_paginated(
        policy_id,
        socket.assigns.active_list_type,
        socket.assigns.list_filter_params
      )

    socket =
      socket
      |> assign(:active_policy_number, number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:member_counts, member_counts)
      |> assign(:filter_params, filter_params)
      |> assign(:employees_page, employees_page)
      |> assign(:list_counts, list_counts)
      |> assign(:list_view_page, list_view_page)

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

    member_counts = Policies.get_policy_member_counts(policy_id)
    filter_params = Map.put(socket.assigns.filter_params, "page", 1)
    employees_page = Policies.list_policy_employees_paginated(policy_id, filter_params)

    list_counts = Policies.get_policy_list_counts(policy_id)

    list_view_page =
      Policies.list_policy_list_view_paginated(
        policy_id,
        socket.assigns.active_list_type,
        socket.assigns.list_filter_params
      )

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
      |> assign(:member_counts, member_counts)
      |> assign(:filter_params, filter_params)
      |> assign(:employees_page, employees_page)
      |> assign(:list_counts, list_counts)
      |> assign(:list_view_page, list_view_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_policy_details", _params, socket) do
    {:noreply, update(socket, :show_policy_details, &not/1)}
  end

  @impl true
  def handle_event("select_nav_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_nav_tab, tab)}
  end

  @impl true
  def handle_event("select_list_type", %{"type" => type}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    reset_params = Map.put(socket.assigns.list_filter_params, "page", 1)
    list_view_page = Policies.list_policy_list_view_paginated(policy_id, type, reset_params)

    socket =
      socket
      |> assign(:active_list_type, type)
      |> assign(:list_filter_params, reset_params)
      |> assign(:list_view_page, list_view_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_list_view", params, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    new_params = Map.merge(socket.assigns.list_filter_params, params) |> Map.put("page", 1)

    list_view_page =
      Policies.list_policy_list_view_paginated(
        policy_id,
        socket.assigns.active_list_type,
        new_params
      )

    socket =
      socket
      |> assign(:list_filter_params, new_params)
      |> assign(:list_view_page, list_view_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("goto_list_view_page", %{"page" => page}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    new_params = Map.put(socket.assigns.list_filter_params, "page", page)

    list_view_page =
      Policies.list_policy_list_view_paginated(
        policy_id,
        socket.assigns.active_list_type,
        new_params
      )

    socket =
      socket
      |> assign(:list_filter_params, new_params)
      |> assign(:list_view_page, list_view_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_employees", params, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    new_params = Map.merge(socket.assigns.filter_params, params) |> Map.put("page", 1)
    employees_page = Policies.list_policy_employees_paginated(policy_id, new_params)

    socket =
      socket
      |> assign(:filter_params, new_params)
      |> assign(:employees_page, employees_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("goto_employee_page", %{"page" => page}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    new_params = Map.put(socket.assigns.filter_params, "page", page)
    employees_page = Policies.list_policy_employees_paginated(policy_id, new_params)

    socket =
      socket
      |> assign(:filter_params, new_params)
      |> assign(:employees_page, employees_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("view_dependents", %{"code" => code, "name" => name}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id

    dependents_page =
      Policies.list_employee_dependents_paginated(policy_id, code, %{"page" => 1, "search" => ""})

    socket =
      socket
      |> assign(:show_dependents_modal, true)
      |> assign(:selected_employee_code, code)
      |> assign(:selected_employee_name, name)
      |> assign(:dependent_search, "")
      |> assign(:dependent_page_num, 1)
      |> assign(:dependents_page, dependents_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_dependents_modal", _params, socket) do
    socket =
      socket
      |> assign(:show_dependents_modal, false)
      |> assign(:selected_employee_code, nil)
      |> assign(:selected_employee_name, nil)
      |> assign(:dependent_search, "")

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_dependents", %{"search" => search}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    code = socket.assigns.selected_employee_code

    dependents_page =
      Policies.list_employee_dependents_paginated(policy_id, code, %{
        "page" => 1,
        "search" => search
      })

    socket =
      socket
      |> assign(:dependent_search, search)
      |> assign(:dependent_page_num, 1)
      |> assign(:dependents_page, dependents_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("goto_dependent_page", %{"page" => page}, socket) do
    policy_id = socket.assigns.selected_policy && socket.assigns.selected_policy.id
    code = socket.assigns.selected_employee_code
    search = socket.assigns.dependent_search

    dependents_page =
      Policies.list_employee_dependents_paginated(policy_id, code, %{
        "page" => page,
        "search" => search
      })

    socket =
      socket
      |> assign(:dependent_page_num, page)
      |> assign(:dependents_page, dependents_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("view_card", %{"code" => code}, socket) do
    {:noreply, put_flash(socket, :info, "ECard generated for Employee Code: #{code}")}
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
      <%!-- Top White Header Bar with Navigation Tabs (Image 1 Navbar) --%>
      <div class="bg-white rounded-lg p-4 mb-4 flex flex-col md:flex-row items-start md:items-center justify-between border border-gray-200 shadow-xs gap-3">
        <h2 class="text-xl font-bold text-gray-800">Enrollment Details</h2>
        
        <div class="flex items-center space-x-2">
          <button
            type="button"
            phx-click="select_nav_tab"
            phx-value-tab="enrollment_details"
            class={[
              "px-4 py-2 rounded-md text-xs font-semibold transition-colors shadow-xs",
              @active_nav_tab == "enrollment_details" && "bg-blue-600 text-white",
              @active_nav_tab != "enrollment_details" &&
                "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
            ]}
          >
            Enrollment Details
          </button>
          
          <button
            type="button"
            phx-click="select_nav_tab"
            phx-value-tab="list_view"
            class={[
              "px-4 py-2 rounded-md text-xs font-semibold transition-colors shadow-xs",
              @active_nav_tab == "list_view" && "bg-blue-600 text-white",
              @active_nav_tab != "list_view" &&
                "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
            ]}
          >
            List View
          </button>
          
          <button
            type="button"
            phx-click="select_nav_tab"
            phx-value-tab="upload_enrollment"
            class={[
              "px-4 py-2 rounded-md text-xs font-semibold transition-colors shadow-xs",
              @active_nav_tab == "upload_enrollment" && "bg-blue-600 text-white",
              @active_nav_tab != "upload_enrollment" &&
                "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
            ]}
          >
            Upload Enrollment
          </button>
        </div>
      </div>
      
      <%= if @active_nav_tab == "list_view" do %>
        <PolicyDetailsComponent.policy_details
          selected_policy={@selected_policy}
          member_counts={@member_counts}
          show_details={@show_policy_details}
          show_member_cards={false}
        />
        <ListView.render_list_view
          selected_policy={@selected_policy}
          list_counts={@list_counts}
          active_list_type={@active_list_type}
          list_view_page={@list_view_page}
          list_filter_params={@list_filter_params}
        />
      <% else %>
        <%!-- Policy Details Reusable Component --%>
        <PolicyDetailsComponent.policy_details
          selected_policy={@selected_policy}
          member_counts={@member_counts}
          show_details={@show_policy_details}
        /> <%!-- Employee Data Table Section (Image 2) --%> />
        <%!-- Employee Data Table Section (Image 2) --%>
        <div class="bg-white rounded-lg border border-gray-200 shadow-xs mt-6 p-4">
          <%!-- Export Button Header --%>
          <div class="flex items-center justify-end mb-4">
            <a
              href={
                ~p"/corporate/enrollment-details/export?policy_id=#{if @selected_policy, do: @selected_policy.id, else: ""}"
              }
              target="_blank"
              class="bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold px-4 py-2 rounded-md flex items-center space-x-1.5 shadow-xs transition-colors"
            >
              <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> <span>Export</span>
            </a>
          </div>
           <%!-- Filter Bar Form --%>
          <form phx-change="filter_employees" id="employee-table-filters" class="mb-3">
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-2 text-xs">
              <input
                type="text"
                name="employee_name"
                value={@filter_params["employee_name"]}
                placeholder="Search Employee Name"
                class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
              />
              <input
                type="text"
                name="employee_code"
                value={@filter_params["employee_code"]}
                placeholder="Search Employee Code"
                class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
              />
              <input
                type="text"
                name="sum_insured"
                value={@filter_params["sum_insured"]}
                placeholder="Search Sum Insured"
                class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
              />
              <input
                type="text"
                name="mobile_number"
                value={@filter_params["mobile_number"]}
                placeholder="Search Mobile Number"
                class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
              />
              <input
                type="text"
                name="email"
                value={@filter_params["email"]}
                placeholder="Search Email"
                class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </form>
           <%!-- Table Container --%>
          <div class="overflow-x-auto border border-gray-200 rounded-md">
            <table class="w-full text-left border-collapse text-xs">
              <thead>
                <tr class="bg-gray-100 border-b border-gray-200 text-gray-700 font-semibold uppercase tracking-wider">
                  <th class="p-3">SI NO</th>
                  
                  <th class="p-3">EMPLOYEE NAME</th>
                  
                  <th class="p-3">EMPLOYEE CODE</th>
                  
                  <th class="p-3">GENDER</th>
                  
                  <th class="p-3">MEMBER ID</th>
                  
                  <th class="p-3">SUM INSURED</th>
                  
                  <th class="p-3 text-center">DEPENDENT</th>
                  
                  <th class="p-3 text-center">CARDS</th>
                  
                  <th class="p-3 text-center">INTIMATE</th>
                  
                  <th class="p-3">EMPLOYEE MOBILE NUMBER</th>
                  
                  <th class="p-3">EMPLOYEE EMAIL</th>
                </tr>
              </thead>
              
              <tbody class="divide-y divide-gray-200 bg-white">
                <%= if @employees_page.entries == [] do %>
                  <tr>
                    <td colspan="11" class="p-6 text-center text-gray-500 font-medium">
                      No employee records found for this policy.
                    </td>
                  </tr>
                <% else %>
                  <%= for {emp, index} <- Enum.with_index(@employees_page.entries, 1) do %>
                    <tr class="hover:bg-gray-50 transition-colors">
                      <td class="p-3 text-gray-600 font-medium">
                        {(@employees_page.page - 1) * @employees_page.page_size + index}
                      </td>
                      
                      <td class="p-3 font-semibold text-gray-800">{emp.employee_name}</td>
                      
                      <td class="p-3 text-gray-600">{emp.employee_code}</td>
                      
                      <td class="p-3 text-gray-600">{emp.gender || "-"}</td>
                      
                      <td class="p-3 text-gray-600">{emp.member_card_number || "-"}</td>
                      
                      <td class="p-3 text-gray-600">{emp.sum_insured || "-"}</td>
                      
                      <td class="p-3 text-center">
                        <button
                          type="button"
                          phx-click="view_dependents"
                          phx-value-code={emp.employee_code}
                          phx-value-name={emp.employee_name}
                          class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-md text-xs font-medium inline-flex items-center space-x-1 shadow-2xs transition-colors"
                        >
                          <.icon name="hero-user-group" class="w-3.5 h-3.5" />
                          <span>View Dependent</span>
                        </button>
                      </td>
                      
                      <td class="p-3 text-center">
                        <button
                          type="button"
                          phx-click="view_card"
                          phx-value-code={emp.employee_code}
                          class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-md text-xs font-medium inline-flex items-center space-x-1 shadow-2xs transition-colors"
                        >
                          <span>View Card</span>
                        </button>
                      </td>
                      
                      <td class="p-3 text-center">
                        <.link
                          navigate={
                            ~p"/corporate/claims-submission/add?employee_code=#{emp.employee_code}"
                          }
                          class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-md text-xs font-medium inline-flex items-center space-x-1 shadow-2xs transition-colors"
                        >
                          <span>Intimate Claim</span>
                        </.link>
                      </td>
                      
                      <td class="p-3 text-gray-600">{emp.mobile_number || "-"}</td>
                      
                      <td class="p-3 text-gray-600">{emp.email || "-"}</td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>
           <%!-- Pagination Footer (15 / page) --%>
          <div class="flex flex-col sm:flex-row items-center justify-between mt-4 text-xs text-gray-600 gap-3">
            <div>
              Showing {if @employees_page.total_entries == 0,
                do: 0,
                else: (@employees_page.page - 1) * @employees_page.page_size + 1} to {min(
                @employees_page.page * @employees_page.page_size,
                @employees_page.total_entries
              )} of {@employees_page.total_entries} entries
            </div>
            
            <div class="flex items-center space-x-2">
              <button
                type="button"
                disabled={@employees_page.page <= 1}
                phx-click="goto_employee_page"
                phx-value-page={@employees_page.page - 1}
                class="px-2.5 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50"
              >
                &lt;
              </button>
              
              <%= for p <- 1..max(@employees_page.total_pages, 1) do %>
                <button
                  type="button"
                  phx-click="goto_employee_page"
                  phx-value-page={p}
                  class={[
                    "px-3 py-1 border rounded-md text-xs font-medium transition-colors",
                    p == @employees_page.page && "bg-blue-600 text-white border-blue-600",
                    p != @employees_page.page &&
                      "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
                  ]}
                >
                  {p}
                </button>
              <% end %>
              
              <button
                type="button"
                disabled={@employees_page.page >= @employees_page.total_pages}
                phx-click="goto_employee_page"
                phx-value-page={@employees_page.page + 1}
                class="px-2.5 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50"
              >
                &gt;
              </button>
              
              <span class="ml-2 border border-gray-300 rounded-md px-2 py-1 bg-white font-medium text-gray-700">
                15/page
              </span>
            </div>
          </div>
        </div>
      <% end %>
       <%!-- Family Dependent Modal Popup (Image 3) --%>
      <%= if @show_dependents_modal do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div class="bg-white rounded-xl shadow-2xl max-w-3xl w-full p-6 overflow-hidden border border-gray-200 animate-fade-in">
            <%!-- Modal Header --%>
            <div class="flex items-center justify-between border-b border-gray-200 pb-3 mb-4">
              <h3 class="text-base font-bold text-gray-800">Family Dependent</h3>
              
              <button
                type="button"
                phx-click="close_dependents_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors p-1 rounded-full"
              >
                <.icon name="hero-x-mark" class="w-5 h-5" />
              </button>
            </div>
             <%!-- Search Box --%>
            <div class="flex justify-end mb-4">
              <div class="relative w-64">
                <.icon
                  name="hero-magnifying-glass"
                  class="w-4 h-4 text-gray-400 absolute left-3 top-2.5"
                />
                <input
                  type="text"
                  placeholder="Search Dependents"
                  value={@dependent_search}
                  phx-keyup="search_dependents"
                  phx-debounce="200"
                  class="w-full pl-9 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>
             <%!-- Dependents Table --%>
            <div class="overflow-x-auto border border-gray-100 rounded-lg">
              <table class="w-full text-left border-collapse text-xs">
                <thead>
                  <tr class="bg-gray-50 text-gray-600 font-semibold border-b border-gray-200">
                    <th class="p-3">Relation</th>
                    
                    <th class="p-3">Name</th>
                    
                    <th class="p-3">Gender</th>
                    
                    <th class="p-3">DOB</th>
                    
                    <th class="p-3">Age</th>
                    
                    <th class="p-3">Mobile Number</th>
                    
                    <th class="p-3">Email</th>
                  </tr>
                </thead>
                
                <tbody class="divide-y divide-gray-100 bg-white">
                  <%= if @dependents_page.entries == [] do %>
                    <tr>
                      <td colspan="7" class="p-6 text-center text-gray-500 font-semibold text-sm">
                        Dependent not available
                      </td>
                    </tr>
                  <% else %>
                    <%= for dep <- @dependents_page.entries do %>
                      <tr class="hover:bg-gray-50">
                        <td class="p-3 text-gray-700">{dep.relationship}</td>
                        
                        <td class="p-3 font-medium text-gray-900">{dep.employee_name}</td>
                        
                        <td class="p-3 text-gray-600">{dep.gender || "-"}</td>
                        
                        <td class="p-3 text-gray-600">{dep.dob || "-"}</td>
                        
                        <td class="p-3 text-gray-600">{dep.age || "-"}</td>
                        
                        <td class="p-3 text-gray-600">{dep.mobile_number || "-"}</td>
                        
                        <td class="p-3 text-gray-600">{dep.email || "-"}</td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>
             <%!-- Modal Pagination Footer (10 / page) --%>
            <div class="flex items-center justify-end mt-4 text-xs text-gray-600 space-x-2">
              <button
                type="button"
                disabled={@dependents_page.page <= 1}
                phx-click="goto_dependent_page"
                phx-value-page={@dependents_page.page - 1}
                class="px-2 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50"
              >
                &lt;
              </button>
              
              <span class="px-2.5 py-1 border border-blue-600 rounded-md bg-white font-medium text-blue-600">
                {@dependents_page.page}
              </span>
              
              <button
                type="button"
                disabled={@dependents_page.page >= @dependents_page.total_pages}
                phx-click="goto_dependent_page"
                phx-value-page={@dependents_page.page + 1}
                class="px-2 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50"
              >
                &gt;
              </button>
              
              <span class="ml-2 border border-gray-300 rounded-md px-2 py-1 bg-white font-medium text-gray-700">
                10/page
              </span>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.corporate>
    """
  end

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
end
