defmodule CorporatePolicyWeb.PolicyDetailsLive do
  use CorporatePolicyWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    policies = CorporatePolicy.Policies.list_policies()

    {:ok,
     socket
     |> assign(:page_title, "Policy Details")
     |> assign(:current_user, current_user)
     |> assign(:policies, policies)
     |> assign(:active_path, "/admin/policy-details")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="p-6">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-slate-900">Policy Details</h1>
            <p class="text-sm text-slate-600 mt-1">Manage and view all corporate policies</p>
          </div>
          <.link
            navigate={~p"/admin/policy-details/add"}
            class="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors shadow-sm"
          >
            <.icon name="hero-plus-circle" class="w-5 h-5" />
            <span>Add Policy</span>
          </.link>
        </div>

        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-gray-50 border-b border-gray-100">
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Corporate</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Policy No.</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">LOB</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Type</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Insurer</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Start Date</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100">
                <%= if @policies == [] do %>
                  <tr>
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                      <.icon name="hero-document-text" class="w-12 h-12 text-gray-300 mx-auto mb-3" />
                      <p class="text-lg font-medium">No policies found</p>
                      <p class="text-sm mt-1">Click "Add Policy" to create your first policy.</p>
                    </td>
                  </tr>
                <% else %>
                  <%= for policy <- @policies do %>
                    <tr class="hover:bg-gray-50 transition-colors">
                      <td class="px-6 py-4">
                        <div class="font-medium text-gray-900"><%= if policy.corporate, do: policy.corporate.corporate_name, else: "-" %></div>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-600">
                        <%= policy.policy_number || "-" %>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-600">
                        <%= if policy.line_of_business_ref, do: policy.line_of_business_ref.line_of_business_value, else: "-" %>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-600">
                        <%= if policy.policy_type_ref, do: policy.policy_type_ref.policy_type_value, else: "-" %>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-600">
                        <%= if policy.insurer_ref, do: policy.insurer_ref.name, else: "-" %>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-600 whitespace-nowrap">
                        <%= if policy.policy_start_date, do: Calendar.strftime(policy.policy_start_date, "%d %b %Y"), else: "-" %>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <.link
                          navigate={~p"/admin/policy-details/#{policy.id}/edit"}
                          class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-md text-sm font-medium transition-colors"
                        >
                          <.icon name="hero-pencil-square" class="w-4 h-4" />
                          Edit
                        </.link>
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
