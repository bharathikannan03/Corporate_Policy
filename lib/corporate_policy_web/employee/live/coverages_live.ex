defmodule CorporatePolicyWeb.Employee.CoveragesLive do
  use CorporatePolicyWeb, :live_view

  import CorporatePolicyWeb.Employee.PortalComponents

  alias CorporatePolicy.EmployeePortal

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_user
    policy_options = EmployeePortal.list_policies_for_employee(current_user)

    policy =
      EmployeePortal.select_policy_for_employee(current_user, params["policy_id"], policy_options)

    current_user = EmployeePortal.scoped_employee_for_policy(current_user, policy)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:policy, policy)
     |> assign(:policy_options, policy_options)
     |> assign(
       :coverage_cards,
       EmployeePortal.list_policy_feature_cards(current_user.ref_policy_id)
     )
     |> assign(:active_path, "/employee/my-coverages")
     |> assign(:page_title, "My Coverages")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.shell
        current_user={@current_user}
        policy={@policy}
        policy_options={@policy_options}
        active_path={@active_path}
        page_title={@page_title}
      >
        <div class="employee-coverage-grid">
          <%= if @coverage_cards == [] do %>
            <.development_notice
              title="Coverage details are being prepared"
              message="No policy features are available for this policy yet."
            />
          <% else %>
            <%= for card <- @coverage_cards do %>
              <article class="employee-coverage-card">
                <div class="employee-coverage-header">
                  <h3>{card.identifier}</h3>
                  <.icon name="hero-chevron-right" class="w-4 h-4" />
                </div>

                <div class="employee-coverage-details">
                  <%= for detail <- Enum.take(card.details, 3) do %>
                    <p>
                      <span class="font-semibold">{detail.label}:</span> {detail.value}
                    </p>
                  <% end %>
                </div>
              </article>
            <% end %>
          <% end %>
        </div>
      </.shell>
    </Layouts.app>
    """
  end
end
