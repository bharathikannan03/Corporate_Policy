defmodule CorporatePolicyWeb.Corporate.EnrollmentDetailsLive.ListView do
  use CorporatePolicyWeb, :html

  attr :selected_policy, :map, default: nil

  attr :list_counts, :map,
    default: %{active_count: 0, inception_count: 0, addition_count: 0, deletion_count: 0}

  attr :active_list_type, :string, default: "active"

  attr :list_view_page, :map,
    default: %{entries: [], page: 1, page_size: 10, total_entries: 0, total_pages: 1}

  attr :list_filter_params, :map,
    default: %{
      "employee_name" => "",
      "employee_code" => "",
      "sum_insured" => "",
      "mobile_number" => "",
      "email" => ""
    }

  def render_list_view(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- Summary Cards Row for List View --%>
      <div class="p-4 bg-[#2b6eb0]/90 rounded-lg shadow-xs">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3">
          <%!-- Active List Card --%>
          <button
            type="button"
            phx-click="select_list_type"
            phx-value-type="active"
            class={[
              "text-left bg-white rounded-lg p-3.5 flex items-center space-x-3 shadow-xs transition-all cursor-pointer border-2",
              @active_list_type == "active" && "border-blue-600 ring-2 ring-blue-500/30",
              @active_list_type != "active" && "border-transparent hover:border-gray-200"
            ]}
          >
            <div class="w-10 h-10 bg-[#3b82f6] rounded-lg flex items-center justify-center text-white shrink-0 shadow-2xs">
              <.icon name="hero-user" class="w-5 h-5 text-white" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-gray-800 truncate">Active list</p>
              <div class="text-[11px] text-gray-600 mt-1">
                <div class="flex items-center justify-between">
                  <span>Count -</span>
                  <span class="font-bold text-gray-800">{@list_counts.active_count}</span>
                </div>
              </div>
            </div>
          </button>

          <%!-- Inception List Card --%>
          <button
            type="button"
            phx-click="select_list_type"
            phx-value-type="inception"
            class={[
              "text-left bg-white rounded-lg p-3.5 flex items-center space-x-3 shadow-xs transition-all cursor-pointer border-2",
              @active_list_type == "inception" && "border-blue-600 ring-2 ring-blue-500/30",
              @active_list_type != "inception" && "border-transparent hover:border-gray-200"
            ]}
          >
            <div class="w-10 h-10 bg-[#3b82f6] rounded-lg flex items-center justify-center text-white shrink-0 shadow-2xs">
              <.icon name="hero-user" class="w-5 h-5 text-white" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-gray-800 truncate">Inception list</p>
              <div class="text-[11px] text-gray-600 mt-1">
                <div class="flex items-center justify-between">
                  <span>Count -</span>
                  <span class="font-bold text-gray-800">{@list_counts.inception_count}</span>
                </div>
              </div>
            </div>
          </button>

          <%!-- Addition List Card --%>
          <button
            type="button"
            phx-click="select_list_type"
            phx-value-type="addition"
            class={[
              "text-left bg-white rounded-lg p-3.5 flex items-center space-x-3 shadow-xs transition-all cursor-pointer border-2",
              @active_list_type == "addition" && "border-blue-600 ring-2 ring-blue-500/30",
              @active_list_type != "addition" && "border-transparent hover:border-gray-200"
            ]}
          >
            <div class="w-10 h-10 bg-[#3b82f6] rounded-lg flex items-center justify-center text-white shrink-0 shadow-2xs">
              <.icon name="hero-user" class="w-5 h-5 text-white" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-gray-800 truncate">Addition list</p>
              <div class="text-[11px] text-gray-600 mt-1">
                <div class="flex items-center justify-between">
                  <span>Count -</span>
                  <span class="font-bold text-gray-800">{@list_counts.addition_count}</span>
                </div>
              </div>
            </div>
          </button>

          <%!-- Deletion List Card --%>
          <button
            type="button"
            phx-click="select_list_type"
            phx-value-type="deletion"
            class={[
              "text-left bg-white rounded-lg p-3.5 flex items-center space-x-3 shadow-xs transition-all cursor-pointer border-2",
              @active_list_type == "deletion" && "border-blue-600 ring-2 ring-blue-500/30",
              @active_list_type != "deletion" && "border-transparent hover:border-gray-200"
            ]}
          >
            <div class="w-10 h-10 bg-[#3b82f6] rounded-lg flex items-center justify-center text-white shrink-0 shadow-2xs">
              <.icon name="hero-user" class="w-5 h-5 text-white" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-gray-800 truncate">Deletion list</p>
              <div class="text-[11px] text-gray-600 mt-1">
                <div class="flex items-center justify-between">
                  <span>Count -</span>
                  <span class="font-bold text-gray-800">{@list_counts.deletion_count}</span>
                </div>
              </div>
            </div>
          </button>
        </div>
      </div>

      <%!-- Data Table Section --%>
      <div class="bg-white rounded-lg border border-gray-200 shadow-xs p-4">
        <%!-- Title and Export Button Header --%>
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-base font-bold text-gray-800 capitalize">
            {active_list_title(@active_list_type)} Data
          </h3>

          <a
            href={
              ~p"/corporate/enrollment-details/export?policy_id=#{if @selected_policy, do: @selected_policy.id, else: ""}&list_type=#{@active_list_type}"
            }
            target="_blank"
            class="bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold px-4 py-2 rounded-md flex items-center space-x-1.5 shadow-xs transition-colors"
          >
            <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> <span>Export</span>
          </a>
        </div>

        <%!-- Filter Bar Form --%>
        <form phx-change="filter_list_view" id="list-view-table-filters" class="mb-3">
          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-2 text-xs">
            <input
              type="text"
              name="employee_name"
              value={@list_filter_params["employee_name"]}
              placeholder="Search Employee Name"
              class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
            />
            <input
              type="text"
              name="employee_code"
              value={@list_filter_params["employee_code"]}
              placeholder="Search Employee Code"
              class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
            />
            <input
              type="text"
              name="sum_insured"
              value={@list_filter_params["sum_insured"]}
              placeholder="Search Sum Insured"
              class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
            />
            <input
              type="text"
              name="mobile_number"
              value={@list_filter_params["mobile_number"]}
              placeholder="Search Mobile Number"
              class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
            />
            <input
              type="text"
              name="email"
              value={@list_filter_params["email"]}
              placeholder="Search Email"
              class="w-full px-2.5 py-1.5 border border-gray-300 rounded-md focus:ring-1 focus:ring-blue-500"
            />
          </div>
        </form>

        <%!-- Table Container --%>
        <div class="overflow-x-auto border border-gray-200 rounded-md">
          <table class="w-full text-left border-collapse text-xs whitespace-nowrap">
            <thead>
              <tr class="bg-gray-100 border-b border-gray-200 text-gray-700 font-semibold uppercase tracking-wider">
                <th class="p-3">SI NO</th>
                <th class="p-3">EMPLOYEE NAME</th>
                <th class="p-3">EMPLOYEE ID</th>
                <th class="p-3">MEMBER ID</th>
                <th class="p-3">AGE</th>
                <th class="p-3">DOB</th>
                <th class="p-3">GENDER</th>
                <th class="p-3">RELATION</th>
                <th class="p-3">DATE OF JOINING</th>
                <th class="p-3">ENDORSEMENT NO</th>
                <th class="p-3">ENDORSEMENT DATE</th>
                <th class="p-3">SUMINSURED</th>
                <th class="p-3">POLICY NUMBER</th>
                <th class="p-3">EMPLOYEE MOBILE</th>
                <th class="p-3">EMPLOYEE EMAIL</th>
              </tr>
            </thead>

            <tbody class="divide-y divide-gray-200 bg-white">
              <%= if @list_view_page.entries == [] do %>
                <tr>
                  <td colspan="15" class="p-6 text-center text-gray-500 font-medium">
                    No records found for this list view.
                  </td>
                </tr>
              <% else %>
                <%= for {rec, index} <- Enum.with_index(@list_view_page.entries, 1) do %>
                  <tr class="hover:bg-gray-50 transition-colors">
                    <td class="p-3 text-gray-600 font-medium">
                      {(@list_view_page.page - 1) * @list_view_page.page_size + index}
                    </td>
                    <td class="p-3 font-semibold text-gray-800">{rec.employee_name || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.employee_code || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.member_card_number || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.age || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.dob || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.gender || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.relationship || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.doj || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.endorsement_number || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.endorsement_date || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.sum_insured || "-"}</td>
                    <td class="p-3 text-gray-600">
                      {if @selected_policy, do: @selected_policy.policy_number, else: "-"}
                    </td>
                    <td class="p-3 text-gray-600">{rec.mobile_number || "-"}</td>
                    <td class="p-3 text-gray-600">{rec.email || "-"}</td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>

        <%!-- Pagination Footer (10 / page) --%>
        <div class="flex flex-col sm:flex-row items-center justify-between mt-4 text-xs text-gray-600 gap-3">
          <div>
            Showing {if @list_view_page.total_entries == 0,
              do: 0,
              else: (@list_view_page.page - 1) * @list_view_page.page_size + 1} to {min(
              @list_view_page.page * @list_view_page.page_size,
              @list_view_page.total_entries
            )} of {@list_view_page.total_entries} entries
          </div>

          <div class="flex items-center space-x-2">
            <button
              type="button"
              disabled={@list_view_page.page <= 1}
              phx-click="goto_list_view_page"
              phx-value-page={@list_view_page.page - 1}
              class="px-2.5 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50 cursor-pointer"
            >
              &lt;
            </button>

            <%= for p <- 1..max(@list_view_page.total_pages, 1) do %>
              <button
                type="button"
                phx-click="goto_list_view_page"
                phx-value-page={p}
                class={[
                  "px-3 py-1 border rounded-md text-xs font-medium transition-colors cursor-pointer",
                  p == @list_view_page.page && "bg-blue-600 text-white border-blue-600",
                  p != @list_view_page.page &&
                    "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
                ]}
              >
                {p}
              </button>
            <% end %>

            <button
              type="button"
              disabled={@list_view_page.page >= @list_view_page.total_pages}
              phx-click="goto_list_view_page"
              phx-value-page={@list_view_page.page + 1}
              class="px-2.5 py-1 border border-gray-300 rounded-md bg-white disabled:opacity-40 hover:bg-gray-50 cursor-pointer"
            >
              &gt;
            </button>

            <span class="ml-2 border border-gray-300 rounded-md px-2 py-1 bg-white font-medium text-gray-700">
              10/page
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp active_list_title("active"), do: "Active List"
  defp active_list_title("inception"), do: "Inception List"
  defp active_list_title("addition"), do: "Addition List"
  defp active_list_title("deletion"), do: "Deletion List"
  defp active_list_title(_), do: "List View"
end
