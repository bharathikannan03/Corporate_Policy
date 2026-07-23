defmodule CorporatePolicyWeb.Employee.CoveragesLive do
  use CorporatePolicyWeb, :live_view

  import CorporatePolicyWeb.Employee.PortalComponents
  import Ecto.Query

  alias CorporatePolicy.EmployeePortal
  alias CorporatePolicy.Policies
  alias CorporatePolicy.Repo

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_user
    policy_options = EmployeePortal.list_policies_for_employee(current_user)

    policy =
      EmployeePortal.select_policy_for_employee(current_user, params["policy_id"], policy_options)

    current_user = EmployeePortal.scoped_employee_for_policy(current_user, policy)

    grouping_names = %{
      "0" => "Feature Identifier",
      "1" => "Domiciliary Hospitalization",
      "2" => "Maternity Cover",
      "3" => "Health Checkup",
      "4" => "Emergency Ambulance",
      "5" => "Hospitalization Limits",
      "6" => "Ayurveda / Homeopathy",
      "7" => "Eye cover",
      "8" => "Dental cover",
      "9" => "Critical Illness Benefit",
      "10" => "Worldwide Emergency Cover",
      "11" => "Congenital & Organ Donor",
      "12" => "Waiting Periods",
      "13" => "Pandemic Cover",
      "14" => "Restore Benefit",
      "15" => "Copay",
      "16" => "No Claim Bonus",
      "17" => "OPD Cover",
      "18" => "Remarks"
    }

    feature_plans =
      if policy do
        EmployeePortal.list_policy_feature_cards(policy.id)
      else
        []
      end

    db_employee =
      if policy do
        Repo.one(
          from e in Policies.TrnMappingLiveEmployee,
            where: e.id == ^current_user.id
        )
      end

    selected_feature_id =
      case feature_plans do
        [] ->
          nil

        plans ->
          matching_plan =
            Enum.find(plans, fn plan ->
              emp_sum_insured_str =
                if db_employee && db_employee.sum_insured,
                  do: to_string(trunc(db_employee.sum_insured)),
                  else: ""

              emp_sum_insured_str != "" and String.contains?(plan.identifier, emp_sum_insured_str)
            end)

          (matching_plan || List.first(plans)).id
      end

    template_id =
      if policy do
        Policies.get_template_id_for_policy(policy)
      else
        1
      end

    template_fields =
      if policy do
        Policies.list_policy_feature_template_fields(template_id)
      else
        []
      end

    mapped_rows =
      if policy && selected_feature_id do
        Policies.get_mapped_feature_details(policy.id, selected_feature_id)
      else
        []
      end

    mapped_values =
      Enum.into(mapped_rows, %{}, fn row ->
        {row.ref_policy_feature_template_field_id, row.policy_feature_template_field_value}
      end)

    {left_col, right_col} =
      prepare_grouped_features(template_fields, mapped_values, grouping_names)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:policy, policy)
     |> assign(:policy_options, policy_options)
     |> assign(:grouping_names, grouping_names)
     |> assign(:template_fields, template_fields)
     |> assign(:feature_plans, feature_plans)
     |> assign(:selected_feature_id, selected_feature_id)
     |> assign(:left_col, left_col)
     |> assign(:right_col, right_col)
     |> assign(:active_path, "/employee/my-coverages")
     |> assign(:page_title, "My Coverages")}
  end

  @impl true
  def handle_event("select_plan", %{"value" => plan_id_str}, socket) do
    plan_id = String.to_integer(plan_id_str)
    policy = socket.assigns.policy
    template_fields = socket.assigns.template_fields
    grouping_names = socket.assigns.grouping_names

    mapped_rows = Policies.get_mapped_feature_details(policy.id, plan_id)

    mapped_values =
      Enum.into(mapped_rows, %{}, fn row ->
        {row.ref_policy_feature_template_field_id, row.policy_feature_template_field_value}
      end)

    {left_col, right_col} =
      prepare_grouped_features(template_fields, mapped_values, grouping_names)

    {:noreply,
     socket
     |> assign(:selected_feature_id, plan_id)
     |> assign(:left_col, left_col)
     |> assign(:right_col, right_col)}
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
        <%= if @feature_plans == [] do %>
          <div class="mt-4">
            <.development_notice
              title="Coverage details are being prepared"
              message="No policy features are available for this policy yet."
            />
          </div>
        <% else %>
          <div class="employee-coverages-container max-w-6xl mx-auto px-4 py-6">
            <%= if length(@feature_plans) > 1 do %>
              <div class="flex items-center gap-3 mb-6 bg-white p-4 rounded-xl shadow-sm border border-slate-100">
                <label class="text-sm font-semibold text-slate-600">Coverage Plan:</label>
                <div class="relative">
                  <select
                    phx-change="select_plan"
                    class="select select-bordered select-sm bg-slate-50 border-slate-200 text-slate-800 focus:outline-none focus:border-blue-500 rounded-lg text-sm font-medium pr-10"
                  >
                    <%= for plan <- @feature_plans do %>
                      <option value={plan.id} selected={plan.id == @selected_feature_id}>
                        {plan.identifier}
                      </option>
                    <% end %>
                  </select>
                </div>
              </div>
            <% end %>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
              <%!-- Left Column --%>
              <div class="flex flex-col gap-4">
                <%= for group <- @left_col do %>
                  <.accordion_item group={group} />
                <% end %>
              </div>
               <%!-- Right Column --%>
              <div class="flex flex-col gap-4">
                <%= for group <- @right_col do %>
                  <.accordion_item group={group} />
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </.shell>
    </Layouts.app>
    """
  end

  defp accordion_item(assigns) do
    ~H"""
    <div class="collapse collapse-arrow bg-white border border-slate-100 rounded-xl shadow-sm relative overflow-hidden">
      <input type="checkbox" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10" />
      <div class="collapse-title p-4 pr-12 min-h-[auto]">
        <div class="flex items-center gap-3">
          <div class="flex items-center justify-center w-8 h-8 rounded-lg bg-blue-50 text-blue-600 shrink-0">
            <.icon name={get_icon_for_group(@group.group_id)} class="w-4 h-4" />
          </div>
          
          <div class="flex flex-col min-w-0">
            <span class="font-semibold text-slate-800 text-sm">{@group.group_name}</span>
            <%= if @group.fields_summary != "" do %>
              <span class="text-xs text-slate-400 font-normal mt-0.5 max-w-[90%] truncate">{@group.fields_summary}</span>
            <% end %>
          </div>
        </div>
      </div>
      
      <div class="collapse-content bg-slate-50/20 border-t border-slate-100/80 p-4">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <tbody>
              <%= for field <- @group.fields do %>
                <tr class="border-b border-slate-100/60 last:border-none hover:bg-slate-50/30 transition-colors">
                  <td class="py-2.5 pr-4 text-xs font-medium text-slate-500 whitespace-nowrap align-middle">
                    {field.name}
                  </td>
                  
                  <td class={"py-2.5 text-xs font-semibold text-right align-middle " <> get_value_class(field.value)}>
                    {if field.value == "", do: "Not Configured", else: field.value}
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp prepare_grouped_features(template_fields, mapped_values, grouping_names) do
    grouped_features =
      template_fields
      |> Enum.group_by(fn field ->
        cond do
          field.policy_feature_template_field_name in ["Feature Identifier", "Policy Identifier"] ->
            {:group, "0", field.policy_feature_template_field_name}

          field.ref_fieldgrouping_id in [nil, "", "0"] ->
            {:field, field.template_field_id, field.policy_feature_template_field_name}

          true ->
            {:group, field.ref_fieldgrouping_id,
             Map.get(
               grouping_names,
               field.ref_fieldgrouping_id,
               field.policy_feature_template_field_name
             )}
        end
      end)
      |> Enum.map(fn {key, fields} ->
        {group_id, group_name} =
          case key do
            {:field, fid, name} -> {to_string(fid), name}
            {:group, gid, name} -> {gid, name}
          end

        min_field_id = Enum.map(fields, & &1.template_field_id) |> Enum.min()
        sorted_fields = Enum.sort_by(fields, & &1.template_field_id)

        fields_with_values =
          Enum.map(sorted_fields, fn f ->
            raw_val = Map.get(mapped_values, f.template_field_id)
            val = if raw_val, do: String.trim(raw_val), else: ""

            %{
              id: f.template_field_id,
              name: f.policy_feature_template_field_name,
              value: val
            }
          end)

        fields_summary =
          if length(fields_with_values) == 1 and List.first(fields_with_values).name == group_name do
            ""
          else
            fields_with_values
            |> Enum.map(& &1.name)
            |> Enum.reject(&(&1 in ["Feature Identifier", "Policy Identifier"]))
            |> Enum.join(", ")
          end

        %{
          group_id: group_id,
          group_name: group_name,
          fields: fields_with_values,
          fields_summary: fields_summary,
          min_field_id: min_field_id
        }
      end)
      |> Enum.sort_by(fn g ->
        case Integer.parse(g.group_id) do
          {val, ""} -> val
          _ -> g.min_field_id + 1000
        end
      end)

    left_col =
      Enum.filter(grouped_features, fn g ->
        case Integer.parse(g.group_id) do
          {val, ""} -> rem(val, 2) == 0
          _ -> true
        end
      end)

    right_col =
      Enum.filter(grouped_features, fn g ->
        case Integer.parse(g.group_id) do
          {val, ""} -> rem(val, 2) == 1
          _ -> false
        end
      end)

    {left_col, right_col}
  end

  defp get_icon_for_group(group_id) do
    case group_id do
      "0" -> "hero-document-text"
      "1" -> "hero-home"
      "2" -> "hero-user"
      "3" -> "hero-heart"
      "4" -> "hero-truck"
      "5" -> "hero-building-office-2"
      "6" -> "hero-beaker"
      "7" -> "hero-eye"
      "8" -> "hero-sparkles"
      "9" -> "hero-bolt"
      "10" -> "hero-globe-alt"
      _ -> "hero-shield-check"
    end
  end

  defp get_value_class(value) do
    cond do
      value == "" ->
        "text-slate-400 font-normal italic"

      String.downcase(value) in [
        "yes",
        "waived off",
        "no room rent capping",
        "no room capping",
        "not applicable icu"
      ] ->
        "text-emerald-600"

      String.contains?(String.downcase(value), "covered up to") ->
        "text-emerald-600"

      true ->
        "text-slate-700"
    end
  end
end
