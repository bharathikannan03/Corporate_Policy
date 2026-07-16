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
            <.icon name="hero-plus-circle" class="w-5 h-5" /> <span>Add Policy</span>
          </.link>
        </div>
        
        <div class="policy-table-wrapper">
          <div class="overflow-x-auto">
            <table class="policy-table">
              <thead>
                <tr>
                  <th>Corporate</th>
                  
                  <th>Policy No.</th>
                  
                  <th>LOB</th>
                  
                  <th>Type</th>
                  
                  <th>Insurer</th>
                  
                  <th>Start Date</th>
                  
                  <th class="text-right">Actions</th>
                </tr>
              </thead>
              
              <tbody>
                <%= if @policies == [] do %>
                  <tr>
                    <td colspan="7" class="text-center py-12">
                      <.icon name="hero-document-text" class="w-12 h-12 text-gray-300 mx-auto mb-3" />
                      <p class="text-lg font-medium">No policies found</p>
                      
                      <p class="text-sm mt-1">Click "Add Policy" to create your first policy.</p>
                    </td>
                  </tr>
                <% else %>
                  <%= for policy <- @policies do %>
                    <tr>
                      <td>
                        <div class="font-medium">
                          {if policy.corporate, do: policy.corporate.corporate_name, else: "-"}
                        </div>
                      </td>
                      
                      <td>
                        <.link
                          navigate={~p"/admin/policy-details/#{policy.id}/edit"}
                          class="text-blue-600 hover:text-blue-800 hover:underline"
                        >
                          {policy.policy_number || "-"}
                        </.link>
                      </td>
                      
                      <td>
                        {if policy.line_of_business_ref,
                          do: policy.line_of_business_ref.line_of_business_value,
                          else: "-"}
                      </td>
                      
                      <td>
                        {if policy.policy_type_ref,
                          do: policy.policy_type_ref.policy_type_value,
                          else: "-"}
                      </td>
                      
                      <td>
                        {if policy.insurer_ref, do: policy.insurer_ref.name, else: "-"}
                      </td>
                      
                      <td class="whitespace-nowrap">
                        {if policy.policy_start_date,
                          do: Calendar.strftime(policy.policy_start_date, "%d %b %Y"),
                          else: "-"}
                      </td>
                      
                      <td class="text-right">
                        <.link
                          navigate={~p"/admin/policy-details/#{policy.id}/edit"}
                          class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-md text-sm font-medium transition-colors"
                        >
                          <.icon name="hero-pencil-square" class="w-4 h-4" /> Edit
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
