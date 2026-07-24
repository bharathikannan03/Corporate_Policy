defmodule CorporatePolicyWeb.Admin.DashboardLive do
  use CorporatePolicyWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    user_stats = build_user_stats()

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/dashboard")
      |> assign(:stats, build_stats(user_stats))
      |> assign(:claims_corner, build_claims_corner())
      |> assign(:bottom_stats, build_bottom_stats())
      |> assign(:chart_data, build_chart_data())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <%!-- Top stat cards row --%>
      <div class="dashboard-stats-grid">
        <%!-- Corporate --%>
        <.link navigate={~p"/admin/corporate"} class="stat-card" id="stat-corporate">
          <div class="stat-card-icon stat-card-icon--blue">
            <.icon name="hero-building-office-2" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Corporate</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Active</span>
                <span class="stat-value">{@stats.corporate.active}</span>
              </div>

              <div class="stat-row">
                <span class="stat-label text-gray-400">Inactive</span>
                <span class="stat-value">{@stats.corporate.inactive}</span>
              </div>
            </div>
          </div>
        </.link>
        <%!-- Policies --%>
        <.link navigate={~p"/admin/policy-details"} class="stat-card" id="stat-policies">
          <div class="stat-card-icon stat-card-icon--indigo">
            <.icon name="hero-document-text" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Policies</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Live</span>
                <span class="stat-value">{@stats.policies.live}</span>
              </div>

              <div class="stat-row">
                <span class="stat-label text-gray-400">Draft</span>
                <span class="stat-value">{@stats.policies.draft}</span>
              </div>
            </div>
          </div>
        </.link>
        <%!-- Expired Policies --%>
        <.link navigate={~p"/admin/policy-details"} class="stat-card" id="stat-expired-policies">
          <div class="stat-card-icon stat-card-icon--cyan">
            <.icon name="hero-clock" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Expired Policies</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-gray-400">Total</span>
                <span class="stat-value">{@stats.expired_policies}</span>
              </div>
            </div>
          </div>
        </.link>
        <%!-- Claims --%>
        <.link navigate={~p"/admin/total-claim-reported"} class="stat-card" id="stat-claims">
          <div class="stat-card-icon stat-card-icon--purple">
            <.icon name="hero-clipboard-document-check" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Claims</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Reported</span>
                <span class="stat-value">{@stats.claims_reported}</span>
              </div>
            </div>
          </div>
        </.link>
      </div>
      <%!-- Middle section: Chart + Users & Claims Corner --%>
      <div class="dashboard-middle">
        <%!-- Chart card --%>
        <div class="chart-card" id="chart-card">
          <h3 class="chart-title">Upcoming Policy Renewals</h3>

          <div class="chart-container-wrapper">
            <canvas
              id="renewals-chart"
              phx-hook="RenewalsChart"
              phx-update="ignore"
              data-labels={Jason.encode!(@chart_data.labels)}
              data-values={Jason.encode!(@chart_data.values)}
              class="chart-canvas"
            ></canvas>
          </div>
        </div>
        <%!-- Right panel: Users + Claims Corner --%>
        <div class="dashboard-right-panel">
          <%!-- Users card --%>
          <div class="stat-card" id="stat-users">
            <div class="stat-card-icon stat-card-icon--teal">
              <.icon name="hero-users" class="w-6 h-6" />
            </div>

            <div class="stat-card-body">
              <h3 class="stat-card-title">Users</h3>

              <div class="stat-card-rows">
                <div class="stat-row">
                  <span class="stat-label text-blue-500">Corporte Admins</span>
                  <span class="stat-value">{@stats.active_users}</span>
                </div>

                <div class="stat-row">
                  <span class="stat-label text-blue-500">Broker Users</span>
                  <span class="stat-value">2</span>
                </div>
              </div>
            </div>
          </div>
          <%!-- Claims Corner --%>
          <div class="claims-corner-card" id="claims-corner">
            <h3 class="claims-corner-title">CLAIMS CORNER</h3>

            <div class="claims-corner-header">
              <span>CLAIMS</span> <span>AMOUNT</span>
            </div>

            <div class="claims-corner-rows">
              <%= for item <- @claims_corner do %>
                <div
                  class="claims-row"
                  id={"claims-#{String.downcase(String.replace(item.label, " ", "-"))}"}
                >
                  <div class={"claims-dot claims-dot--#{item.color}"}></div>
                  <span class="claims-label">{item.label}</span>
                  <span class="claims-amount">{item.amount}</span>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
      <%!-- Bottom stat cards --%>
      <div class="dashboard-stats-grid" id="bottom-stats">
        <div class="stat-card" id="stat-corporate-users">
          <div class="stat-card-icon stat-card-icon--blue">
            <.icon name="hero-user-group" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Corporate Users</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Active</span>
                <span class="stat-value">{@stats.user_stats.active_employees}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="stat-card" id="stat-employee-activity">
          <div class="stat-card-icon stat-card-icon--indigo">
            <.icon name="hero-bolt" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Employee Activity</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Total</span> <span class="stat-value">0</span>
              </div>
            </div>
          </div>
        </div>

        <div class="stat-card" id="stat-online-claims">
          <div class="stat-card-icon stat-card-icon--cyan">
            <.icon name="hero-arrow-up-tray" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Online Claim Submission</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Total</span> <span class="stat-value">0</span>
              </div>
            </div>
          </div>
        </div>

        <div class="stat-card" id="stat-health-activity">
          <div class="stat-card-icon stat-card-icon--purple">
            <.icon name="hero-heart" class="w-6 h-6" />
          </div>

          <div class="stat-card-body">
            <h3 class="stat-card-title">Employee Health Activity</h3>

            <div class="stat-card-rows">
              <div class="stat-row">
                <span class="stat-label text-blue-500">Total</span> <span class="stat-value">0</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  # ─── Private helpers ──────────────────────────────────────────────────────────

  defp build_user_stats do
    alias CorporatePolicy.Policies

    active = Policies.count_live_employees_by_relationship_and_status("Employee", "active")
    inactive = Policies.count_live_employees_by_relationship_and_status("Employee", "inactive")

    %{
      active_employees: active,
      inactive_employees: inactive,
      total_employees: active + inactive
    }
  end

  defp build_stats(user_stats) do
    %{
      corporate: %{
        active: CorporatePolicy.Corporates.count_active_corporates(),
        inactive: CorporatePolicy.Corporates.count_inactive_corporates()
      },
      policies: %{
        live: CorporatePolicy.Policies.count_policies_by_status(1),
        draft: CorporatePolicy.Policies.count_policies_by_statuses([0, 2])
      },
      expired_policies: CorporatePolicy.Policies.count_policies_by_status(3),
      claims_reported: CorporatePolicy.Policies.count_total_claim_reports(),
      active_users: CorporatePolicy.Accounts.count_active_users(),
      user_stats: user_stats
    }
  end

  defp build_claims_corner do
    summary = CorporatePolicy.Policies.get_global_claims_corner_summary()

    [
      %{label: "Closed", amount: format_inr(summary.closed_amount), color: :yellow},
      %{label: "Paid", amount: format_inr(summary.paid_amount), color: :green},
      %{label: "Rejected", amount: format_inr(summary.rejected_amount), color: :red},
      %{label: "Under Process", amount: format_inr(summary.process_amount), color: :yellow}
    ]
  end

  defp build_bottom_stats do
    [
      %{label: "Corporate Users", value: 2410},
      %{label: "Employee Activity", value: 569},
      %{label: "Online Claim Submission", value: 0},
      %{label: "Employee Health Activity", value: 0}
    ]
  end

  defp build_chart_data do
    %{
      labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
      values: [2, 1, 2, 4, 1, 2, 3, 2, 3, 2, 2, 3]
    }
  end

  defp format_inr(nil), do: "₹0.00"

  defp format_inr(val) when is_float(val) do
    "₹" <> format_indian_number(val)
  end

  defp format_inr(val) when is_integer(val) do
    "₹" <> format_indian_number(val * 1.0)
  end

  defp format_inr(_), do: "₹0.00"

  defp format_indian_number(val) do
    # Convert to float and format with 2 decimals
    formatted = :erlang.float_to_binary(val, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")

    # Process integer part for Indian numbering system
    len = String.length(integer_part)

    if len <= 3 do
      integer_part <> "." <> decimal_part
    else
      last_three = String.slice(integer_part, -3..-1)
      rest = String.slice(integer_part, 0, len - 3)

      # Group preceding digits by 2
      grouped_rest =
        rest
        |> String.reverse()
        |> String.graphemes()
        |> Enum.chunk_every(2)
        |> Enum.map(&Enum.join/1)
        |> Enum.join(",")
        |> String.reverse()

      grouped_rest <> "," <> last_three <> "." <> decimal_part
    end
  end
end
