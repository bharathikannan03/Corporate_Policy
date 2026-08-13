defmodule CorporatePolicyWeb.Corporate.PolicyDetailsComponent do
  use Phoenix.Component
  import CorporatePolicyWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders the Policy Details section along with summary cards for Employees, Dependents, and Lives count.
  Defaults all counts to 0 if no employees exist for the policy.
  """
  attr :selected_policy, :map, default: nil
  attr :member_counts, :map, default: %{employees_count: 0, dependents_count: 0, lives_count: 0}
  attr :show_details, :boolean, default: true
  attr :show_member_cards, :boolean, default: true

  def policy_details(assigns) do
    ~H"""
    <div class="space-y-4 my-4">
      <%!-- Policy Details Banner --%>
      <div class="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-xs">
        <button
          type="button"
          phx-click="toggle_policy_details"
          class="w-full bg-[#2d78be] text-white px-4 py-2.5 flex items-center space-x-2 text-sm font-semibold hover:bg-[#2566a3] transition-colors"
        >
          <.icon
            name={if @show_details, do: "hero-chevron-down", else: "hero-chevron-right"}
            class="w-4 h-4"
          /> <span>Policy Details</span>
        </button>

        <%= if @show_details do %>
          <div class="p-5 grid grid-cols-1 md:grid-cols-3 gap-y-4 gap-x-6 text-xs text-gray-700 bg-white">
            <div>
              <span class="font-bold text-gray-900">Policy Number:</span>
              <span class="ml-1 text-gray-600">
                {if @selected_policy, do: @selected_policy.policy_number, else: "N/A"}
              </span>
            </div>

            <div>
              <span class="font-bold text-gray-900">Policy Start Date:</span>
              <span class="ml-1 text-gray-600">{format_date(start_date(@selected_policy))}</span>
            </div>

            <div>
              <span class="font-bold text-gray-900">Policy End Date:</span>
              <span class="ml-1 text-gray-600">{format_date(end_date(@selected_policy))}</span>
            </div>

            <div>
              <span class="font-bold text-gray-900">Insurer:</span>
              <span class="ml-1 text-gray-600">{insurer_name(@selected_policy)}</span>
            </div>

            <div>
              <span class="font-bold text-gray-900">TPA:</span>
              <span class="ml-1 text-gray-600">{tpa_name(@selected_policy)}</span>
            </div>
          </div>
        <% end %>
      </div>
      <%!-- 3 Summary Cards Row --%>
      <%= if @show_member_cards do %>
        <div class="p-4 bg-[#2b6eb0]/90 rounded-lg shadow-xs">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <%!-- Employees Card --%>
            <div class="bg-white rounded-lg p-4 flex items-center space-x-4 shadow-xs">
              <div class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center text-white shrink-0">
                <.icon name="hero-user" class="w-6 h-6" />
              </div>

              <div>
                <p class="text-xs font-medium text-gray-500">Employees</p>

                <p class="text-sm font-semibold text-gray-700">
                  Total -
                  <span class="font-bold text-gray-900">{@member_counts.employees_count}</span>
                </p>
              </div>
            </div>
            <%!-- Dependents Card --%>
            <div class="bg-white rounded-lg p-4 flex items-center space-x-4 shadow-xs">
              <div class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center text-white shrink-0">
                <.icon name="hero-user-group" class="w-6 h-6" />
              </div>

              <div>
                <p class="text-xs font-medium text-gray-500">Dependents</p>

                <p class="text-sm font-semibold text-gray-700">
                  Total -
                  <span class="font-bold text-gray-900">{@member_counts.dependents_count}</span>
                </p>
              </div>
            </div>
            <%!-- Lives Card --%>
            <div class="bg-white rounded-lg p-4 flex items-center space-x-4 shadow-xs">
              <div class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center text-white shrink-0">
                <.icon name="hero-users" class="w-6 h-6" />
              </div>

              <div>
                <p class="text-xs font-medium text-gray-500">Lives</p>

                <p class="text-sm font-semibold text-gray-700">
                  Total - <span class="font-bold text-gray-900">{@member_counts.lives_count}</span>
                </p>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp start_date(%{policy_start_date: s}) when not is_nil(s), do: s
  defp start_date(_), do: "06-11-2025"

  defp end_date(%{policy_end_date: e}) when not is_nil(e), do: e
  defp end_date(_), do: "05-11-2026"

  defp insurer_name(%{select_insurer: i}) when is_binary(i) and i != "", do: i
  defp insurer_name(%{insurer_ref: %{name: name}}), do: name
  defp insurer_name(_), do: "Galaxy Health Insurance Company Limited"

  defp tpa_name(%{select_tpa: t}) when is_binary(t) and t != "", do: t
  defp tpa_name(%{tpa_ref: %{name: name}}), do: name
  defp tpa_name(_), do: "Internal TPA"

  defp format_date(%Date{} = d), do: Calendar.strftime(d, "%d-%m-%Y")
  defp format_date(d) when is_binary(d), do: d
  defp format_date(_), do: ""
end
