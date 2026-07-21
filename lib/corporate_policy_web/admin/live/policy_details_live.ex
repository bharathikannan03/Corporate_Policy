defmodule CorporatePolicyWeb.Admin.PolicyDetailsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Policies

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    {:ok,
     socket
     |> assign(:page_title, "Policy Details")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/policy-details")
     |> load_policies(%{})}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, load_policies(socket, %{"page" => page})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" id="policy-list-page">
        <%!-- Page header --%>
        <div class="corp-list-header" id="policy-list-header">
          <div>
            <h1 class="corp-list-title">Policy Details</h1>

            <p class="corp-list-subtitle">Manage and view all corporate policies</p>
          </div>

          <div class="header-actions">
            <.link
              navigate={~p"/admin/policy-details/add"}
              id="add-policy-btn"
              class="btn-primary"
            >
              <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add Policy
            </.link>
          </div>
        </div>
        <%!-- Table card --%>
        <div class="corp-table-card" id="policy-table-card">
          <div class="overflow-x-auto">
            <table class="corp-table" id="policies-table">
              <thead>
                <tr>
                  <th class="corp-th">Corporate</th>

                  <th class="corp-th">Policy No.</th>

                  <th class="corp-th">LOB</th>

                  <th class="corp-th">Type</th>

                  <th class="corp-th">Insurer</th>

                  <th class="corp-th">Start Date</th>

                  <th class="corp-th text-right">Actions</th>
                </tr>
              </thead>

              <tbody id="policies-tbody">
                <%= if @policies_page.entries == [] do %>
                  <tr class="corp-empty-row" id="policies-empty-row">
                    <td colspan="7" class="corp-empty-cell">
                      <div class="corp-empty-state" id="corp-empty-state">
                        <.icon name="hero-document-text" class="w-12 h-12 text-gray-300 mb-3" />
                        <p class="corp-empty-text">No policies yet</p>

                        <.link
                          navigate={~p"/admin/policy-details/add"}
                          class="btn-primary mt-4"
                          id="add-first-policy-btn"
                        >
                          <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add your first policy
                        </.link>
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for policy <- @policies_page.entries do %>
                    <tr class="corp-tr" id={"policy-#{policy.id}"}>
                      <td class="corp-td corp-td--name">
                        {if policy.corporate, do: policy.corporate.corporate_name, else: "-"}
                      </td>

                      <td class="corp-td">
                        <%= if policy.policy_number do %>
                          <.link
                            navigate={~p"/admin/policy-details/#{policy.id}/edit"}
                            class="corp-code-badge hover:bg-blue-100 hover:text-blue-700 transition-colors"
                          >
                            {policy.policy_number}
                          </.link>
                        <% else %>
                          -
                        <% end %>
                      </td>

                      <td class="corp-td">
                        {if policy.line_of_business_ref,
                          do: policy.line_of_business_ref.line_of_business_value,
                          else: "-"}
                      </td>

                      <td class="corp-td">
                        {if policy.policy_type_ref,
                          do: policy.policy_type_ref.policy_type_value,
                          else: "-"}
                      </td>

                      <td class="corp-td">
                        {if policy.insurer_ref, do: policy.insurer_ref.name, else: "-"}
                      </td>

                      <td class="corp-td whitespace-nowrap">
                        {if policy.policy_start_date,
                          do: Calendar.strftime(policy.policy_start_date, "%d %b %Y"),
                          else: "-"}
                      </td>

                      <td class="corp-td">
                        <div class="corp-actions justify-end">
                          <.link
                            navigate={~p"/admin/policy-details/#{policy.id}/edit"}
                            class="corp-action-btn-text corp-action-btn-text--edit"
                            title="Edit Policy"
                            id={"edit-policy-#{policy.id}"}
                          >
                            <.icon name="hero-pencil" class="w-4 h-4 mr-1" /> Edit
                          </.link>
                        </div>
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>

          <.pagination
            page={@policies_page.page}
            page_size={@policies_page.page_size}
            total_entries={@policies_page.total_entries}
            total_pages={@policies_page.total_pages}
            event="paginate"
          />
        </div>
      </div>
    </Layouts.admin>
    """
  end

  defp load_policies(socket, params) do
    page = Map.get(params, "page", 1)
    assign(socket, :policies_page, Policies.list_policies_paginated(page: page))
  end
end
