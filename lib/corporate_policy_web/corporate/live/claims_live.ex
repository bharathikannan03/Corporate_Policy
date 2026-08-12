defmodule CorporatePolicyWeb.Corporate.ClaimsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Corporate.PolicyDetailsComponent
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

    claim_summary = Policies.get_total_claim_summary(policy_id)

    filter_params = %{
      "page" => 1,
      "search" => ""
    }

    claims_page = Policies.list_total_claim_reports_paginated(policy_id, filter_params)

    socket =
      socket
      |> assign(:page_title, "Claims - Corporate Portal")
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
      |> assign(:claim_summary, claim_summary)
      |> assign(:claims_page, claims_page)
      |> assign(:show_details, true)
      |> assign(:show_details_modal, false)
      |> assign(:selected_claim_row, nil)
      |> assign(:active_path, "/corporate/claims")

    {:ok, socket}
  end

  @impl true
  def handle_event("change_fy", %{"fy_name" => fy_name}, socket) do
    fy = Enum.find(socket.assigns.financial_years, &(&1.year_name == fy_name))
    fy_id = fy && fy.id

    policies =
      if fy_id do
        Enum.filter(socket.assigns.all_policies, &(&1.ref_fy_year_id == fy_id))
      else
        socket.assigns.all_policies
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

    claim_summary = Policies.get_total_claim_summary(policy_id)

    claims_page =
      Policies.list_total_claim_reports_paginated(policy_id, %{
        "page" => 1,
        "search" => socket.assigns.claims_page.search
      })

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
     |> assign(:claim_summary, claim_summary)
     |> assign(:claims_page, claims_page)}
  end

  def handle_event("select_policy_type", %{"type" => type}, socket) do
    fetched_numbers = get_numbers_for_type(socket.assigns.policies, type)
    policy_numbers = fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(socket.assigns.policies, type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    claim_summary = Policies.get_total_claim_summary(policy_id)

    claims_page =
      Policies.list_total_claim_reports_paginated(policy_id, %{
        "page" => 1,
        "search" => socket.assigns.claims_page.search
      })

    {:noreply,
     socket
     |> assign(:active_policy_type, type)
     |> assign(:policy_numbers, policy_numbers)
     |> assign(:active_policy_number, active_policy_number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:claim_summary, claim_summary)
     |> assign(:claims_page, claims_page)}
  end

  def handle_event("select_policy_number", %{"number" => number}, socket) do
    selected_policy =
      get_selected_policy(socket.assigns.policies, socket.assigns.active_policy_type, number)

    policy_id = selected_policy && selected_policy.id

    claim_summary = Policies.get_total_claim_summary(policy_id)

    claims_page =
      Policies.list_total_claim_reports_paginated(policy_id, %{
        "page" => 1,
        "search" => socket.assigns.claims_page.search
      })

    {:noreply,
     socket
     |> assign(:active_policy_number, number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:claim_summary, claim_summary)
     |> assign(:claims_page, claims_page)}
  end

  def handle_event("toggle_policy_details", _params, socket) do
    {:noreply, assign(socket, :show_details, !socket.assigns.show_details)}
  end

  def handle_event("filter", %{"search" => search}, socket) do
    params = %{"page" => 1, "search" => search}
    claims_page = Policies.list_total_claim_reports_paginated(socket.assigns.policy_id, params)

    {:noreply, assign(socket, :claims_page, claims_page)}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    params = %{"page" => page, "search" => socket.assigns.claims_page.search}
    claims_page = Policies.list_total_claim_reports_paginated(socket.assigns.policy_id, params)

    {:noreply, assign(socket, :claims_page, claims_page)}
  end

  def handle_event("view_row_details", %{"id" => id}, socket) do
    claim_id = String.to_integer(id)

    selected_claim =
      Enum.find(socket.assigns.claims_page.entries, &(&1.id == claim_id)) ||
        Policies.get_total_claim_report!(claim_id)

    {:noreply,
     socket
     |> assign(:selected_claim_row, selected_claim)
     |> assign(:show_details_modal, true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_details_modal, false)
     |> assign(:selected_claim_row, nil)}
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
        <%!-- Title Bar with Action Buttons --%>
        <div class="bg-white rounded-lg p-4 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-4 border border-gray-200">
          <h2 class="text-xl font-bold text-gray-900">Claim Details</h2>

          <div class="flex items-center space-x-2">
            <button
              type="button"
              class="px-4 py-1.5 rounded-md text-xs font-semibold bg-[#0070ba] text-white shadow-xs"
            >
              Claim Details
            </button>

            <.link
              navigate={~p"/corporate/claims-submission/add"}
              class="px-4 py-1.5 rounded-md text-xs font-semibold bg-white text-[#0070ba] border border-[#0070ba] hover:bg-blue-50 transition-colors"
            >
              Intimate Claim
            </.link>
          </div>
        </div>
        <%!-- Collapsible Policy Details Accordion --%>
        <PolicyDetailsComponent.policy_details
          selected_policy={@selected_policy}
          show_details={@show_details}
          show_member_cards={false}
        /> <%!-- 4 Summary Statistics Cards Row --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <%!-- Claims Paid --%>
          <div class="bg-white rounded-xl p-4 flex items-center space-x-4 border border-gray-200 shadow-xs">
            <div class="w-12 h-12 bg-[#0070ba] rounded-xl flex items-center justify-center text-white shrink-0 shadow-xs">
              <.icon name="hero-user" class="w-6 h-6" />
            </div>

            <div class="text-xs space-y-1">
              <p class="font-bold text-gray-800 text-sm">Claims paid</p>

              <p class="text-gray-600 font-medium">
                Amount -
                <span class="font-bold text-gray-900">{format_amount(@claim_summary.paid_amount)}</span>
              </p>

              <p class="text-gray-600 font-medium">
                Count - <span class="font-bold text-gray-900">{@claim_summary.paid_count}</span>
              </p>
            </div>
          </div>
          <%!-- Claims Under Process --%>
          <div class="bg-white rounded-xl p-4 flex items-center space-x-4 border border-gray-200 shadow-xs">
            <div class="w-12 h-12 bg-[#0070ba] rounded-xl flex items-center justify-center text-white shrink-0 shadow-xs">
              <.icon name="hero-user" class="w-6 h-6" />
            </div>

            <div class="text-xs space-y-1">
              <p class="font-bold text-gray-800 text-sm">Claims under process</p>

              <p class="text-gray-600 font-medium">
                Amount -
                <span class="font-bold text-gray-900">{format_amount(@claim_summary.process_amount)}</span>
              </p>

              <p class="text-gray-600 font-medium">
                Count - <span class="font-bold text-gray-900">{@claim_summary.process_count}</span>
              </p>
            </div>
          </div>
          <%!-- Claims Closed / Rejected --%>
          <div class="bg-white rounded-xl p-4 flex items-center space-x-4 border border-gray-200 shadow-xs">
            <div class="w-12 h-12 bg-[#0070ba] rounded-xl flex items-center justify-center text-white shrink-0 shadow-xs">
              <.icon name="hero-user" class="w-6 h-6" />
            </div>

            <div class="text-xs space-y-1">
              <p class="font-bold text-gray-800 text-sm">Claims closed / Rejected</p>

              <p class="text-gray-600 font-medium">
                Amount -
                <span class="font-bold text-gray-900">{format_amount(@claim_summary.rejected_amount)}</span>
              </p>

              <p class="text-gray-600 font-medium">
                Count - <span class="font-bold text-gray-900">{@claim_summary.rejected_count}</span>
              </p>
            </div>
          </div>
          <%!-- Reported Claims --%>
          <div class="bg-white rounded-xl p-4 flex items-center space-x-4 border border-gray-200 shadow-xs">
            <div class="w-12 h-12 bg-[#0070ba] rounded-xl flex items-center justify-center text-white shrink-0 shadow-xs">
              <.icon name="hero-user" class="w-6 h-6" />
            </div>

            <div class="text-xs space-y-1">
              <p class="font-bold text-gray-800 text-sm">Reported Claims</p>

              <p class="text-gray-600 font-medium">
                Amount -
                <span class="font-bold text-gray-900">{format_amount(@claim_summary.reported_amount)}</span>
              </p>

              <p class="text-gray-600 font-medium">
                Count - <span class="font-bold text-gray-900">{@claim_summary.reported_count}</span>
              </p>
            </div>
          </div>
        </div>
        <%!-- Data Table Section --%>
        <div class="corp-table-card">
          <div class="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 border-b border-gray-200">
            <form phx-change="filter" class="w-full sm:w-72">
              <input
                type="text"
                name="search"
                value={@claims_page.search}
                placeholder="Search employee, claim no, hospital..."
                class="corp-input text-xs"
              />
            </form>

            <.link
              href={~p"/corporate/claims/export?policy_id=#{@policy_id || ""}"}
              class="px-4 py-1.5 rounded-md text-xs font-semibold bg-[#0070ba] text-white hover:bg-blue-600 transition-colors flex items-center space-x-1.5 shadow-xs shrink-0"
            >
              <.icon name="hero-arrow-up-on-square" class="w-4 h-4" /> <span>Export</span>
            </.link>
          </div>

          <div class="overflow-x-auto">
            <table class="corp-table text-xs whitespace-nowrap" id="total-claims-table">
              <thead>
                <tr class="bg-gray-50 border-b border-gray-200">
                  <th class="corp-th">SI NO</th>

                  <th class="corp-th">DETAILS</th>

                  <th class="corp-th">EMPLOYEE ID</th>

                  <th class="corp-th">EMPLOYEE NAME</th>

                  <th class="corp-th">BENEFICIARY NAME</th>

                  <th class="corp-th">RELATION</th>

                  <th class="corp-th">CLAIM TYPE</th>

                  <th class="corp-th">CLAIM STATUS</th>

                  <th class="corp-th">CLAIM NO</th>

                  <th class="corp-th">TPA CLAIM NO</th>

                  <th class="corp-th">HOSPITALIZATION DATE</th>

                  <th class="corp-th">HOSPITAL NAME</th>

                  <th class="corp-th">DISCHARGE DATE</th>

                  <th class="corp-th">AMOUNT CLAIMED</th>

                  <th class="corp-th">AMOUNT SANCTIONED</th>

                  <th class="corp-th">CLAIM PAID AMOUNT</th>

                  <th class="corp-th">PATIENT GENDER</th>

                  <th class="corp-th">HOSPITAL STATE</th>

                  <th class="corp-th">NETWORK STATUS</th>

                  <th class="corp-th">TREATMENT TYPE</th>

                  <th class="corp-th">LEVEL OF CARE</th>

                  <th class="corp-th">CAUSE</th>

                  <th class="corp-th">CITY</th>

                  <th class="corp-th">AGE</th>

                  <th class="corp-th">CLAIM FILE SUBMITTED DT</th>

                  <th class="corp-th">CLAIM SETTLED DATE</th>

                  <th class="corp-th">DISEASE CATEGORY</th>

                  <th class="corp-th">CLAIM REGISTERED DATE</th>

                  <th class="corp-th">INTIMATION METHOD</th>

                  <th class="corp-th">SUM INSURED</th>

                  <th class="corp-th">TDS AMOUNT</th>

                  <th class="corp-th">DEDUCTION AMOUNT</th>

                  <th class="corp-th">DEDUCTION REASON</th>

                  <th class="corp-th">DEFICIENCY INTIMATED DATE</th>

                  <th class="corp-th">DEFICIENCY SUBMISSION DATE</th>

                  <th class="corp-th">ICD CODE</th>

                  <th class="corp-th">CLOSE REASONS</th>

                  <th class="corp-th">DEFICIENCY REASON</th>

                  <th class="corp-th">CLAIM SUB STATUS</th>
                </tr>
              </thead>

              <tbody>
                <%= if @claims_page.entries == [] do %>
                  <tr class="corp-empty-row">
                    <td colspan="39" class="corp-empty-cell py-12 text-center text-gray-400">
                      <div class="flex flex-col items-center justify-center">
                        <.icon name="hero-inbox" class="w-10 h-10 text-gray-300 mb-2" />
                        <span class="text-sm font-medium">No data</span>
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for {claim, index} <- Enum.with_index(@claims_page.entries, 1) do %>
                    <tr class="corp-tr border-b border-gray-100 hover:bg-gray-50/50">
                      <td class="corp-td font-medium">
                        {(@claims_page.page - 1) * @claims_page.page_size + index}
                      </td>

                      <td class="corp-td">
                        <button
                          type="button"
                          phx-click="view_row_details"
                          phx-value-id={claim.id}
                          class="px-2.5 py-1 rounded bg-blue-50 text-blue-600 font-semibold hover:bg-blue-100 transition-colors"
                        >
                          View
                        </button>
                      </td>

                      <td class="corp-td">{blank_dash(claim.employee_code)}</td>

                      <td class="corp-td font-medium text-gray-900">
                        {blank_dash(claim.employee_name)}
                      </td>

                      <td class="corp-td">{blank_dash(claim.patient_name)}</td>

                      <td class="corp-td">{blank_dash(claim.relationship)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_type)}</td>

                      <td class="corp-td">
                        <span class={status_badge_class(claim.claim_status)}>
                          {blank_dash(claim.claim_status)}
                        </span>
                      </td>

                      <td class="corp-td font-mono">{blank_dash(claim.insurance_claim_no)}</td>

                      <td class="corp-td font-mono">{blank_dash(claim.tpa_claim_no)}</td>

                      <td class="corp-td">{blank_dash(claim.date_of_hospitalization)}</td>

                      <td class="corp-td">{blank_dash(claim.hospital_name)}</td>

                      <td class="corp-td">{blank_dash(claim.date_of_discharge)}</td>

                      <td class="corp-td">{format_amount(claim.amount_claimed)}</td>

                      <td class="corp-td">{format_amount(claim.amount_sanctioned)}</td>

                      <td class="corp-td">{format_amount(claim.claim_paid_amount)}</td>

                      <td class="corp-td">{blank_dash(claim.patient_gender)}</td>

                      <td class="corp-td">{blank_dash(claim.hospital_state)}</td>

                      <td class="corp-td">{blank_dash(claim.network_status)}</td>

                      <td class="corp-td">{blank_dash(claim.treatment_type)}</td>

                      <td class="corp-td">{blank_dash(claim.level_of_care)}</td>

                      <td class="corp-td">{blank_dash(claim.cause)}</td>

                      <td class="corp-td">{blank_dash(claim.city)}</td>

                      <td class="corp-td">{blank_dash(claim.age)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_file_submitted_dt)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_settled_date)}</td>

                      <td class="corp-td">{blank_dash(claim.disease_category)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_registered_date)}</td>

                      <td class="corp-td">{blank_dash(claim.intimation_method)}</td>

                      <td class="corp-td">{format_amount(claim.sum_insured)}</td>

                      <td class="corp-td">{format_amount(claim.tds_amount)}</td>

                      <td class="corp-td">{format_amount(claim.deduction_amount)}</td>

                      <td class="corp-td">{blank_dash(claim.deduction_reason)}</td>

                      <td class="corp-td">{blank_dash(claim.deficiency_intimated_date)}</td>

                      <td class="corp-td">{blank_dash(claim.deficiency_submission_date)}</td>

                      <td class="corp-td">{blank_dash(claim.icd_code)}</td>

                      <td class="corp-td">{blank_dash(claim.close_reasons)}</td>

                      <td class="corp-td">{blank_dash(claim.deficiency_reason)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_sub_status)}</td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>
          <%!-- Table Footer / Pagination --%>
          <div class="flex items-center justify-between p-4 border-t border-gray-200 text-xs">
            <div class="text-gray-500">
              Showing {if @claims_page.total_entries == 0,
                do: 0,
                else: (@claims_page.page - 1) * @claims_page.page_size + 1} to {min(
                @claims_page.page * @claims_page.page_size,
                @claims_page.total_entries
              )} of {@claims_page.total_entries} entries
            </div>

            <div class="flex items-center space-x-2">
              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page - 1}
                class="px-3 py-1 rounded border border-gray-300 text-gray-700 bg-white font-medium hover:bg-gray-50 disabled:opacity-50"
                disabled={@claims_page.page <= 1}
              >
                Previous
              </button>

              <span class="font-medium text-gray-700 px-2">
                {@claims_page.page} / {@claims_page.total_pages}
              </span>

              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page + 1}
                class="px-3 py-1 rounded bg-[#0070ba] text-white font-medium hover:bg-blue-600 disabled:opacity-50"
                disabled={@claims_page.page >= @claims_page.total_pages}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
      <%!-- View Details Modal --%>
      <%= if @show_details_modal and @selected_claim_row do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div class="w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-2xl bg-white p-6 shadow-2xl space-y-4">
            <div class="flex items-start justify-between border-b border-gray-200 pb-3">
              <div>
                <h3 class="text-lg font-bold text-gray-900">Total Claim Details</h3>

                <p class="text-xs text-gray-500">
                  Employee: {@selected_claim_row.employee_name} ({@selected_claim_row.employee_code})
                </p>
              </div>

              <button
                type="button"
                phx-click="close_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
              <div class="space-y-2 border p-3 rounded-lg bg-gray-50">
                <p>
                  <span class="font-bold text-gray-700">Employee Code:</span> {blank_dash(
                    @selected_claim_row.employee_code
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Employee Name:</span> {blank_dash(
                    @selected_claim_row.employee_name
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Beneficiary Name:</span> {blank_dash(
                    @selected_claim_row.patient_name
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Relation:</span> {blank_dash(
                    @selected_claim_row.relationship
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Age / Gender:</span> {blank_dash(
                    @selected_claim_row.age
                  )} / {blank_dash(@selected_claim_row.patient_gender)}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Claim Type:</span> {blank_dash(
                    @selected_claim_row.claim_type
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Claim Status:</span> {blank_dash(
                    @selected_claim_row.claim_status
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Claim Sub Status:</span> {blank_dash(
                    @selected_claim_row.claim_sub_status
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Insurance Claim No:</span> {blank_dash(
                    @selected_claim_row.insurance_claim_no
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">TPA Claim No:</span> {blank_dash(
                    @selected_claim_row.tpa_claim_no
                  )}
                </p>
              </div>

              <div class="space-y-2 border p-3 rounded-lg bg-gray-50">
                <p>
                  <span class="font-bold text-gray-700">Hospital Name:</span> {blank_dash(
                    @selected_claim_row.hospital_name
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Hospital State / City:</span> {blank_dash(
                    @selected_claim_row.hospital_state
                  )} / {blank_dash(@selected_claim_row.city)}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Hospitalization Date:</span> {blank_dash(
                    @selected_claim_row.date_of_hospitalization
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Discharge Date:</span> {blank_dash(
                    @selected_claim_row.date_of_discharge
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Amount Claimed:</span> {format_amount(
                    @selected_claim_row.amount_claimed
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Amount Sanctioned:</span> {format_amount(
                    @selected_claim_row.amount_sanctioned
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Claim Paid Amount:</span> {format_amount(
                    @selected_claim_row.claim_paid_amount
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Treatment Type:</span> {blank_dash(
                    @selected_claim_row.treatment_type
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Network Status:</span> {blank_dash(
                    @selected_claim_row.network_status
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Sum Insured:</span> {format_amount(
                    @selected_claim_row.sum_insured
                  )}
                </p>
              </div>

              <div class="md:col-span-2 border p-3 rounded-lg bg-white space-y-2">
                <p>
                  <span class="font-bold text-gray-700">Disease Category / Cause:</span> {blank_dash(
                    @selected_claim_row.disease_category
                  )} / {blank_dash(@selected_claim_row.cause)}
                </p>

                <p>
                  <span class="font-bold text-gray-700">ICD Code:</span> {blank_dash(
                    @selected_claim_row.icd_code
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">TDS Amount:</span> {format_amount(
                    @selected_claim_row.tds_amount
                  )} |
                  <span class="font-bold text-gray-700">Deduction Amount:</span> {format_amount(
                    @selected_claim_row.deduction_amount
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Deduction Reason:</span> {blank_dash(
                    @selected_claim_row.deduction_reason
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Close Reasons:</span> {blank_dash(
                    @selected_claim_row.close_reasons
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Deficiency Reason:</span> {blank_dash(
                    @selected_claim_row.deficiency_reason
                  )}
                </p>

                <p>
                  <span class="font-bold text-gray-700">Deficiency Dates:</span>
                  Intimated: {blank_dash(@selected_claim_row.deficiency_intimated_date)} | Submitted: {blank_dash(
                    @selected_claim_row.deficiency_submission_date
                  )}
                </p>
              </div>
            </div>

            <div class="flex justify-end pt-2">
              <button
                type="button"
                phx-click="close_modal"
                class="px-4 py-2 text-xs font-semibold bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
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

  defp get_policy_type_name(policy) do
    cond do
      is_binary(policy.policy_type) and policy.policy_type != "" ->
        policy.policy_type

      is_map(policy.policy_type_ref) and
          is_binary(Map.get(policy.policy_type_ref, :policy_type_value)) ->
        policy.policy_type_ref.policy_type_value

      true ->
        nil
    end
  end

  defp get_numbers_for_type(_policies, nil), do: []

  defp get_numbers_for_type(policies, type_name) do
    policies
    |> Enum.filter(fn p ->
      get_policy_type_name(p) == type_name
    end)
    |> Enum.map(& &1.policy_number)
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp get_selected_policy([], _type_name, _number), do: nil
  defp get_selected_policy(policies, nil, _number), do: List.first(policies)
  defp get_selected_policy(policies, _type_name, nil), do: List.first(policies)

  defp get_selected_policy(policies, type_name, number) do
    Enum.find(policies, fn p ->
      get_policy_type_name(p) == type_name and p.policy_number == number
    end) || List.first(policies)
  end

  defp blank_dash(nil), do: "-"
  defp blank_dash(""), do: "-"
  defp blank_dash(value), do: to_string(value)

  defp format_amount(nil), do: "0"

  defp format_amount(val) when is_float(val),
    do: :erlang.float_to_binary(val, [{:decimals, 2}, :compact])

  defp format_amount(val) when is_integer(val), do: Integer.to_string(val)
  defp format_amount(val), do: to_string(val)

  defp status_badge_class(status) when is_binary(status) do
    s = String.downcase(status)

    cond do
      String.contains?(s, "paid") or String.contains?(s, "settle") or
          String.contains?(s, "approve") ->
        "px-2 py-0.5 rounded text-2xs font-semibold bg-emerald-100 text-emerald-800"

      String.contains?(s, "process") or String.contains?(s, "pending") or
          String.contains?(s, "review") ->
        "px-2 py-0.5 rounded text-2xs font-semibold bg-amber-100 text-amber-800"

      String.contains?(s, "reject") or String.contains?(s, "close") ->
        "px-2 py-0.5 rounded text-2xs font-semibold bg-rose-100 text-rose-800"

      true ->
        "px-2 py-0.5 rounded text-2xs font-semibold bg-slate-100 text-slate-800"
    end
  end

  defp status_badge_class(_),
    do: "px-2 py-0.5 rounded text-2xs font-semibold bg-slate-100 text-slate-800"
end
