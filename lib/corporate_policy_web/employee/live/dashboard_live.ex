defmodule CorporatePolicyWeb.Employee.DashboardLive do
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
    members = EmployeePortal.list_members(current_user)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:policy, policy)
     |> assign(:policy_options, policy_options)
     |> assign(:members_count, length(members))
     |> assign(:active_path, "/employee/dashboard")
     |> assign(:page_title, "My Policy")}
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
        <div class="employee-grid employee-grid--policy">
          <.info_card title="Employee Name" value={@current_user.full_name} icon="hero-user" />
          <.info_card
            title="Policy Start Date"
            value={format_date(@policy && @policy.policy_start_date)}
            icon="hero-calendar-days"
          />
          <.info_card
            title="TPA Name"
            value={@policy && @policy.select_tpa}
            icon="hero-building-library"
          />
          <.info_card
            title="Policy Expiry Date"
            value={format_date(@policy && @policy.policy_end_date)}
            icon="hero-clock"
          />
          <.info_card
            title="Policy Number"
            value={@policy && @policy.policy_number}
            icon="hero-hashtag"
          />
          <.info_card
            title="Sum Insured"
            value={(@policy && @policy.sum_insured_type) || "As per policy"}
            icon="hero-banknotes"
          />
          <.info_card
            title="Insurance Company"
            value={@policy && @policy.select_insurer}
            icon="hero-shield-check"
          />
          <.info_card
            title="Members Covered"
            value={to_string(@members_count)}
            icon="hero-user-group"
          />
        </div>
      </.shell>
    </Layouts.app>
    """
  end

  defp format_date(nil), do: "-"
  defp format_date(%Date{} = date), do: Calendar.strftime(date, "%d-%m-%Y")
end
