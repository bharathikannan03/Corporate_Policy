defmodule CorporatePolicyWeb.Employee.MembersLive do
  use CorporatePolicyWeb, :live_view

  import CorporatePolicyWeb.Employee.PortalComponents

  alias CorporatePolicy.EmployeePortal

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:policy, EmployeePortal.get_policy_details(current_user.ref_policy_id))
     |> assign(:members, EmployeePortal.list_members(current_user))
     |> assign(:active_path, "/employee/members-covered")
     |> assign(:page_title, "Members Covered")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.shell
        current_user={@current_user}
        policy={@policy}
        active_path={@active_path}
        page_title={@page_title}
      >
        <div class="employee-member-grid">
          <%= for member <- @members do %>
            <article class="employee-member-card">
              <div class="employee-member-card-header">
                <div>
                  <h3>{member.employee_name}</h3>
                  <p>{EmployeePortal.format_relationship(member.relationship)}</p>
                </div>
                <span class="employee-member-badge">{member.status}</span>
              </div>

              <div class="employee-member-meta">
                <p>DOB: {member.dob || "-"}</p>
                <p>Age: {member.age || "-"}</p>
                <p>Employee Code: {member.employee_code}</p>
              </div>
            </article>
          <% end %>
        </div>
      </.shell>
    </Layouts.app>
    """
  end
end
