defmodule CorporatePolicyWeb.Admin.DashboardLive do
  use CorporatePolicyWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/dashboard")
      |> assign(:stats, build_stats())
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
        <div class="stat-card" id="stat-policies">
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
        </div>
        <%!-- Expired Policies --%>
        <div class="stat-card" id="stat-expired-policies">
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
        </div>
        <%!-- Claims --%>
        <div class="stat-card" id="stat-claims">
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
        </div>
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
                  <span class="stat-label text-blue-500">Corporate Users</span>
                  <span class="stat-value">35</span>
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
              <div class="claims-row" id="claims-closed">
                <div class="claims-dot claims-dot--yellow"></div>
                <span class="claims-label">Closed</span> <span class="claims-amount">₹0.00</span>
              </div>

              <div class="claims-row" id="claims-paid">
                <div class="claims-dot claims-dot--green"></div>
                <span class="claims-label">Paid</span>
                <span class="claims-amount">₹18,31,244.00</span>
              </div>

              <div class="claims-row" id="claims-rejected">
                <div class="claims-dot claims-dot--red"></div>
                <span class="claims-label">Rejected</span>
                <span class="claims-amount">₹1,66,552.00</span>
              </div>

              <div class="claims-row" id="claims-under-process">
                <div class="claims-dot claims-dot--yellow"></div>
                <span class="claims-label">Under Process</span>
                <span class="claims-amount">₹0.00</span>
              </div>
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
                <span class="stat-label text-blue-500">Total</span>
                <span class="stat-value">2410</span>
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
                <span class="stat-label text-blue-500">Total</span>
                <span class="stat-value">569</span>
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

  defp build_stats do
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
      claims_reported: CorporatePolicy.Claims.count_claims()
    }
  end

  defp build_claims_corner do
    [
      %{label: "Closed", amount: "₹0.00", color: :yellow},
      %{label: "Paid", amount: "₹18,31,244.00", color: :green},
      %{label: "Rejected", amount: "₹1,66,552.00", color: :red},
      %{label: "Under Process", amount: "₹0.00", color: :yellow}
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
end
