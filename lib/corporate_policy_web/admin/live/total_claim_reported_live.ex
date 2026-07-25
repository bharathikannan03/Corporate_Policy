defmodule CorporatePolicyWeb.Admin.TotalClaimReportedLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Policies
  alias CorporatePolicy.StringUtils

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    {:ok,
     socket
     |> assign(:page_title, "Total Claim Reported")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/total-claim-reported")
     |> assign(:claim_statuses, Policies.total_claim_report_statuses())
     |> load_claims(%{})}
  end

  @impl true
  def handle_event("filter", params, socket) do
    {:noreply, load_claims(socket, Map.put(params, "page", 1))}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    params =
      socket.assigns.claims_page
      |> Map.take([:search, :status, :sort_by, :sort_dir])
      |> stringify()

    {:noreply, load_claims(socket, Map.put(params, "page", page))}
  end

  def handle_event("sort", %{"field" => field, "direction" => direction}, socket) do
    params =
      socket.assigns.claims_page
      |> Map.take([:search, :status])
      |> stringify()
      |> Map.merge(%{"sort_by" => field, "sort_dir" => direction, "page" => 1})

    {:noreply, load_claims(socket, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="total-claim-reported-page">
        <div class="corp-list-header" id="total-claim-reported-header">
          <div>
            <h1 class="corp-list-title">Total Claim Reported</h1>

            <p class="corp-list-subtitle">
              Displays all claim records uploaded from TPA/insurer claim report files.
            </p>
          </div>

          <div class="header-actions">
            <.link href={~p"/admin/total-claim-reported/export"} class="btn-primary">
              <.icon name="hero-arrow-down-tray" class="w-4 h-4 mr-1" /> Export
            </.link>
          </div>
        </div>

        <div class="corp-table-card">
          <div class="flex flex-col gap-4 p-4 border-b border-gray-200 md:flex-row md:items-end md:justify-between">
            <.form
              for={to_form(%{"search" => @claims_page.search, "status" => @claims_page.status})}
              id="total-claim-reported-filter-form"
              phx-change="filter"
              class="grid grid-cols-1 gap-4 md:grid-cols-3 md:w-full"
            >
              <div>
                <label class="corp-label">Search</label>
                <input
                  type="text"
                  name="search"
                  value={@claims_page.search}
                  placeholder="Employee code, name, TPA claim no, hospital..."
                  class="corp-input"
                />
              </div>

              <div>
                <label class="corp-label">Claim Status</label>
                <select name="status" class="corp-input">
                  <option value="">All Statuses</option>

                  <%= for status <- @claim_statuses do %>
                    <option value={status} selected={StringUtils.equal?(@claims_page.status, status)}>
                      {status}
                    </option>
                  <% end %>
                </select>
              </div>
            </.form>
          </div>

          <div class="overflow-x-auto">
            <table class="corp-table" id="total-claim-reported-table">
              <thead>
                <tr>
                  <th class="corp-th">SI NO</th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Employee Code", "employee_code")}
                  </th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Employee Name", "employee_name")}
                  </th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Patient Name", "patient_name")}
                  </th>

                  <th class="corp-th">Relation</th>

                  <th class="corp-th">Claim Type</th>

                  <th class="corp-th">
                    {sortable_link(assigns, "TPA Claim No", "tpa_claim_no")}
                  </th>

                  <th class="corp-th">Insurance Claim No</th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Claim Status", "claim_status")}
                  </th>

                  <th class="corp-th">Claim Sub Status</th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Hosp. Date", "date_of_hospitalization")}
                  </th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Discharge Date", "date_of_discharge")}
                  </th>

                  <th class="corp-th">Hospital Name</th>

                  <th class="corp-th">Hospital State</th>

                  <th class="corp-th">City</th>

                  <th class="corp-th">Network Status</th>

                  <th class="corp-th">Treatment Type</th>

                  <th class="corp-th">Level of Care</th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Amount Claimed", "amount_claimed")}
                  </th>

                  <th class="corp-th">
                    {sortable_link(assigns, "Amount Sanctioned", "amount_sanctioned")}
                  </th>

                  <th class="corp-th">Claim Paid Amount</th>

                  <th class="corp-th">Sum Insured</th>

                  <th class="corp-th">TDS Amount</th>

                  <th class="corp-th">Deduction Amount</th>

                  <th class="corp-th">Deduction Reason</th>

                  <th class="corp-th">Gender</th>

                  <th class="corp-th">Age</th>

                  <th class="corp-th">Cause</th>

                  <th class="corp-th">Disease Category</th>

                  <th class="corp-th">ICD Code</th>

                  <th class="corp-th">Intimation Method</th>

                  <th class="corp-th">Claim Registered Date</th>

                  <th class="corp-th">Claim File Submitted Date</th>

                  <th class="corp-th">Claim Settled Date</th>

                  <th class="corp-th">Deficiency Reason</th>

                  <th class="corp-th">Close Reasons</th>

                  <th class="corp-th">Policy</th>
                </tr>
              </thead>

              <tbody>
                <%= if @claims_page.entries == [] do %>
                  <tr class="corp-empty-row">
                    <td colspan="37" class="corp-empty-cell">
                      <div class="corp-empty-state">
                        <.icon name="hero-inbox" class="w-12 h-12 text-gray-300 mb-3" />
                        <p class="corp-empty-text">No claim reports found</p>
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for {claim, index} <- Enum.with_index(@claims_page.entries, 1) do %>
                    <tr class="corp-tr">
                      <td class="corp-td">
                        {(@claims_page.page - 1) * @claims_page.page_size + index}
                      </td>

                      <td class="corp-td">{blank_dash(claim.employee_code)}</td>

                      <td class="corp-td">{blank_dash(claim.employee_name)}</td>

                      <td class="corp-td">{blank_dash(claim.patient_name)}</td>

                      <td class="corp-td">{blank_dash(claim.relationship)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_type)}</td>

                      <td class="corp-td">{blank_dash(claim.tpa_claim_no)}</td>

                      <td class="corp-td">{blank_dash(claim.insurance_claim_no)}</td>

                      <td class="corp-td">
                        <span class={status_badge_class(claim.claim_status)}>
                          {blank_dash(claim.claim_status)}
                        </span>
                      </td>

                      <td class="corp-td">{blank_dash(claim.claim_sub_status)}</td>

                      <td class="corp-td">{blank_dash(claim.date_of_hospitalization)}</td>

                      <td class="corp-td">{blank_dash(claim.date_of_discharge)}</td>

                      <td class="corp-td">{blank_dash(claim.hospital_name)}</td>

                      <td class="corp-td">{blank_dash(claim.hospital_state)}</td>

                      <td class="corp-td">{blank_dash(claim.city)}</td>

                      <td class="corp-td">{blank_dash(claim.network_status)}</td>

                      <td class="corp-td">{blank_dash(claim.treatment_type)}</td>

                      <td class="corp-td">{blank_dash(claim.level_of_care)}</td>

                      <td class="corp-td">{format_amount(claim.amount_claimed)}</td>

                      <td class="corp-td">{format_amount(claim.amount_sanctioned)}</td>

                      <td class="corp-td">{format_amount(claim.claim_paid_amount)}</td>

                      <td class="corp-td">{format_amount(claim.sum_insured)}</td>

                      <td class="corp-td">{format_amount(claim.tds_amount)}</td>

                      <td class="corp-td">{format_amount(claim.deduction_amount)}</td>

                      <td class="corp-td">{blank_dash(claim.deduction_reason)}</td>

                      <td class="corp-td">{blank_dash(claim.patient_gender)}</td>

                      <td class="corp-td">{blank_dash(claim.age)}</td>

                      <td class="corp-td">{blank_dash(claim.cause)}</td>

                      <td class="corp-td">{blank_dash(claim.disease_category)}</td>

                      <td class="corp-td">{blank_dash(claim.icd_code)}</td>

                      <td class="corp-td">{blank_dash(claim.intimation_method)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_registered_date)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_file_submitted_dt)}</td>

                      <td class="corp-td">{blank_dash(claim.claim_settled_date)}</td>

                      <td class="corp-td">{blank_dash(claim.deficiency_reason)}</td>

                      <td class="corp-td">{blank_dash(claim.close_reasons)}</td>

                      <td class="corp-td">
                        {if claim.policy, do: claim.policy.policy_number, else: "-"}
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>

          <div class="flex items-center justify-between p-4 border-t border-gray-200">
            <div class="text-sm text-gray-500">
              Showing {if @claims_page.total_entries == 0,
                do: 0,
                else: (@claims_page.page - 1) * @claims_page.page_size + 1} to {min(
                @claims_page.page * @claims_page.page_size,
                @claims_page.total_entries
              )} of {@claims_page.total_entries} entries
            </div>

            <div class="flex items-center gap-2">
              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page - 1}
                class="btn btn-sm btn-secondary"
                disabled={@claims_page.page <= 1}
              >
                Previous
              </button>

              <span class="text-sm font-medium px-3 py-1 border rounded-md">
                {@claims_page.page} / {@claims_page.total_pages}
              </span>

              <button
                type="button"
                phx-click="paginate"
                phx-value-page={@claims_page.page + 1}
                class="btn btn-sm btn-primary"
                disabled={@claims_page.page >= @claims_page.total_pages}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  # ─── Private helpers ──────────────────────────────────────────────────────────

  defp load_claims(socket, params) do
    claims_page = Policies.list_total_claim_reports(params)
    assign(socket, :claims_page, claims_page)
  end

  defp stringify(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp sortable_link(assigns, label, field) do
    direction =
      if assigns.claims_page.sort_by == field and assigns.claims_page.sort_dir == "asc",
        do: "desc",
        else: "asc"

    assigns =
      assign(assigns,
        sortable_label: label,
        sortable_field: field,
        sortable_dir: direction
      )

    ~H"""
    <button
      type="button"
      phx-click="sort"
      phx-value-field={@sortable_field}
      phx-value-direction={@sortable_dir}
      class="corp-sort-button"
    >
      {@sortable_label} <.icon name="hero-arrows-up-down" class="w-4 h-4 text-gray-400" />
    </button>
    """
  end

  defp status_badge_class(nil), do: "badge badge-ghost"
  defp status_badge_class(""), do: "badge badge-ghost"

  defp status_badge_class(status) do
    normalized = status |> String.trim() |> String.downcase()

    cond do
      String.contains?(normalized, "paid") or String.contains?(normalized, "settle") ->
        "badge badge-success text-white"

      String.contains?(normalized, "reject") ->
        "badge badge-error text-white"

      String.contains?(normalized, "close") ->
        "badge badge-warning text-white"

      String.contains?(normalized, "process") or String.contains?(normalized, "pending") ->
        "badge badge-info text-white"

      true ->
        "badge badge-ghost"
    end
  end

  defp format_amount(nil), do: "-"
  defp format_amount(val) when is_float(val), do: "₹#{:erlang.float_to_binary(val, decimals: 2)}"
  defp format_amount(val), do: to_string(val)

  defp blank_dash(nil), do: "-"
  defp blank_dash(""), do: "-"
  defp blank_dash(value), do: value
end
