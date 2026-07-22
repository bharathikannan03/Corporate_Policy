defmodule CorporatePolicyWeb.Employee.ContactMatrixLive do
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
     |> assign(:contacts, EmployeePortal.list_contact_matrix(current_user.ref_policy_id))
     |> assign(:active_path, "/employee/contact-matrix")
     |> assign(:page_title, "Contact Matrix")}
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
        <div class="employee-contact-grid">
          <%= if @contacts == [] do %>
            <.development_notice
              title="No escalation contacts configured"
              message="Your policy does not have an escalation matrix assigned yet."
            />
          <% else %>
            <%= for contact <- @contacts do %>
              <article class="employee-contact-card">
                <div class="employee-contact-level">{contact.level}</div>
                
                <h3>{contact.name}</h3>
                
                <p>{contact.type || "Policy Support"}</p>
                
                <ul>
                  <li>Phone: {contact.mobile_number || contact.phone_number || "-"}</li>
                  
                  <li>Email: {contact.email_id || "-"}</li>
                  
                  <li>Alt Email: {contact.alt_email_id || "-"}</li>
                </ul>
              </article>
            <% end %>
          <% end %>
        </div>
      </.shell>
    </Layouts.app>
    """
  end
end
