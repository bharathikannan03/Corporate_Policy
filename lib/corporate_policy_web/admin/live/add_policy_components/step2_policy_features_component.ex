defmodule CorporatePolicyWeb.Admin.Step2PolicyFeaturesComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Corporates
  alias CorporatePolicyWeb.Pagination

  @impl true
  def update(assigns, socket) do
    policy = assigns.policy

    mapped_features = Policies.list_mapped_features_by_policy(policy && policy.id)

    template_id =
      if policy do
        Policies.get_template_id_for_policy(policy)
      else
        1
      end

    template_fields = Policies.list_policy_feature_template_fields(template_id)

    visibility_roles = Corporates.list_visibility_roles()

    socket =
      socket
      |> assign(assigns)
      |> assign(:mapped_features, mapped_features)
      |> assign(:template_fields, template_fields)
      |> assign(:template_id, template_id)
      |> assign(:visibility_roles, visibility_roles)
      |> assign(:form_data, %{})
      |> assign(:form, to_form(%{}, as: :feature))
      |> assign(:show_form, false)
      |> assign(:editing_feature_id, nil)
      |> assign(:confirm_delete_id, nil)
      |> assign_mapped_features_page(mapped_features)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_feature_id, nil)
     |> assign(:form_data, %{})}
  end

  @impl true
  def handle_event("hide_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:editing_feature_id, nil)
     |> assign(:form_data, %{})}
  end

  @impl true
  def handle_event("edit_feature", %{"id" => id_str}, socket) do
    feature_id = String.to_integer(id_str)
    policy = socket.assigns.policy

    rows = Policies.get_mapped_feature_details(policy.id, feature_id)

    form_data =
      Enum.reduce(rows, %{}, fn row, acc ->
        acc
        |> Map.put(
          "field_#{row.ref_policy_feature_template_field_id}",
          row.policy_feature_template_field_value || ""
        )
        |> Map.put(
          "visibility_role_#{row.ref_policy_feature_template_field_id}",
          if(row.policy_feature_template_field_visibility_role_ids,
            do: to_string(row.policy_feature_template_field_visibility_role_ids),
            else: ""
          )
        )
      end)

    {:noreply,
     socket
     |> assign(:editing_feature_id, feature_id)
     |> assign(:form_data, form_data)
     |> assign(:show_form, true)}
  end

  @impl true
  def handle_event("save-features", params, socket) do
    policy = socket.assigns.policy
    template_fields = socket.assigns.template_fields
    template_id = socket.assigns.template_id
    editing_feature_id = socket.assigns[:editing_feature_id]

    corp_id = policy.ref_corporate_id || policy[:corporate_id] || 1

    if editing_feature_id do
      # Edit Mode: Update existing mapped rows
      existing_rows = Policies.get_mapped_feature_details(policy.id, editing_feature_id)

      existing_map =
        Enum.into(existing_rows, %{}, fn r -> {r.ref_policy_feature_template_field_id, r} end)

      Enum.each(template_fields, fn field ->
        val = params["field_#{field.template_field_id}"]
        role_id = params["visibility_role_#{field.template_field_id}"]
        value = if val, do: String.trim(val), else: ""

        existing_row = Map.get(existing_map, field.template_field_id)

        cond do
          existing_row && value != "" ->
            Policies.update_mapped_feature(existing_row, %{
              ref_policy_feature_template_field_name: field.policy_feature_template_field_name,
              policy_feature_template_field_value: value,
              policy_feature_template_field_visibility_role_ids:
                if(role_id != "", do: role_id, else: nil)
            })

          existing_row && value == "" ->
            Policies.update_mapped_feature(existing_row, %{
              policy_feature_template_field_value: "",
              policy_feature_template_field_visibility_role_ids:
                if(role_id != "", do: role_id, else: nil)
            })

          is_nil(existing_row) && value != "" ->
            Policies.create_mapped_feature(%{
              ref_policy_feature_template_field_name: field.policy_feature_template_field_name,
              policy_feature_template_field_value: value,
              ref_template_id: template_id,
              ref_coporate_id: corp_id,
              ref_policy_id: policy.id,
              ref_policy_feature_template_field_id: field.template_field_id,
              ref_policy_feature_template_field_type_id: field.ref_master_temp_field_Type,
              policy_feature_template_field_visibility_role_ids:
                if(role_id != "", do: role_id, else: nil),
              ref_policyidentifier_id: editing_feature_id,
              status: 1
            })

          true ->
            :ok
        end
      end)

      mapped_features = Policies.list_mapped_features_by_policy(policy.id)

      {:noreply,
       socket
       |> assign(:mapped_features, mapped_features)
       |> assign_mapped_features_page(mapped_features)
       |> assign(:show_form, false)
       |> assign(:editing_feature_id, nil)
       |> assign(:form_data, %{})
       |> assign(:form, to_form(%{}, as: :feature))
       |> put_flash(:info, "Policy Feature updated successfully")}
    else
      # Add Mode: Create new mapped feature rows
      field1 =
        Enum.find(template_fields, fn f ->
          f.template_field_id == 1 or
            f.policy_feature_template_field_name in ["Feature Identifier", "Policy Identifier"]
        end) || List.first(template_fields)

      field1_val = if field1, do: params["field_#{field1.template_field_id}"], else: nil

      field1_role =
        if field1, do: params["visibility_role_#{field1.template_field_id}"], else: nil

      root_id =
        if field1 && field1_val && String.trim(field1_val) != "" do
          case Policies.create_mapped_feature(%{
                 ref_policy_feature_template_field_name:
                   field1.policy_feature_template_field_name,
                 policy_feature_template_field_value: String.trim(field1_val),
                 ref_template_id: template_id,
                 ref_coporate_id: corp_id,
                 ref_policy_id: policy.id,
                 ref_policy_feature_template_field_id: field1.template_field_id,
                 ref_policy_feature_template_field_type_id: field1.ref_master_temp_field_Type,
                 policy_feature_template_field_visibility_role_ids:
                   if(field1_role != "", do: field1_role, else: nil),
                 status: 1
               }) do
            {:ok, inserted} ->
              Policies.update_mapped_feature(inserted, %{
                ref_policyidentifier_id: inserted.policy_feature_template_field_value_id
              })

              inserted.policy_feature_template_field_value_id

            _ ->
              nil
          end
        else
          nil
        end

      remaining_fields =
        Enum.reject(template_fields, fn f ->
          field1 && f.template_field_id == field1.template_field_id
        end)

      Enum.each(remaining_fields, fn field ->
        val = params["field_#{field.template_field_id}"]
        role_id = params["visibility_role_#{field.template_field_id}"]

        if val && String.trim(val) != "" do
          Policies.create_mapped_feature(%{
            ref_policy_feature_template_field_name: field.policy_feature_template_field_name,
            policy_feature_template_field_value: String.trim(val),
            ref_template_id: template_id,
            ref_coporate_id: corp_id,
            ref_policy_id: policy.id,
            ref_policy_feature_template_field_id: field.template_field_id,
            ref_policy_feature_template_field_type_id: field.ref_master_temp_field_Type,
            policy_feature_template_field_visibility_role_ids:
              if(role_id != "", do: role_id, else: nil),
            ref_policyidentifier_id: root_id,
            status: 1
          })
        end
      end)

      mapped_features = Policies.list_mapped_features_by_policy(policy.id)

      {:noreply,
       socket
       |> assign(:mapped_features, mapped_features)
       |> assign_mapped_features_page(mapped_features)
       |> assign(:show_form, false)
       |> assign(:editing_feature_id, nil)
       |> assign(:form_data, %{})
       |> assign(:form, to_form(%{}, as: :feature))
       |> put_flash(:info, "Policy Features saved successfully")}
    end
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id_str}, socket) do
    {:noreply, assign(socket, :confirm_delete_id, String.to_integer(id_str))}
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :confirm_delete_id, nil)}
  end

  @impl true
  def handle_event("delete_feature", %{"id" => id_str}, socket) do
    feature_id = String.to_integer(id_str)
    policy = socket.assigns.policy

    Policies.delete_mapped_feature(policy.id, feature_id)

    mapped_features = Policies.list_mapped_features_by_policy(policy.id)

    {:noreply,
     socket
     |> assign(:mapped_features, mapped_features)
     |> assign_mapped_features_page(mapped_features)
     |> assign(:confirm_delete_id, nil)
     |> put_flash(:info, "Policy Feature deleted successfully")}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, assign_mapped_features_page(socket, socket.assigns.mapped_features, page)}
  end

  @impl true
  def handle_event("next_step", _, socket) do
    send(self(), {:step_completed, :step2, socket.assigns.policy})
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <%= if @show_form do %>
        <%!-- Form View --%>
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-semibold text-slate-800">
            {if @editing_feature_id, do: "Edit Policy Feature", else: "Add Policy Feature"}
          </h3>
          <span class="text-sm text-slate-500">Template: POLICY_001</span>
        </div>

        <%= if @template_fields == [] do %>
          <div class="p-8 text-center text-slate-500 bg-slate-50 rounded-lg border">
            <.icon name="hero-exclamation-triangle" class="w-8 h-8 mx-auto mb-2 text-amber-400" />
            <p class="font-medium">No template fields found for this policy type.</p>

            <p class="text-sm mt-1">
              Please contact your administrator to configure template fields.
            </p>
          </div>
        <% else %>
          <.form
            for={@form}
            id="policy-features-form"
            phx-submit="save-features"
            phx-target={@myself}
            class="corp-form-grid"
          >
            <%= for field <- @template_fields do %>
              <div class="corp-field-group">
                <label class="corp-label flex items-center gap-1.5 mb-1">
                  <span>{field.policy_feature_template_field_name}</span>
                  <%= if field.is_mandatory == 1 do %>
                    <span class="corp-required text-red-500 font-bold">*</span>
                  <% end %>
                </label>

                <div class="grid grid-cols-2 gap-4 items-center">
                  <div>
                    <%= if field.ref_master_temp_field_Type == 4 do %>
                      <div class="flex items-center gap-6 py-1.5">
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                          <input
                            type="radio"
                            name={"field_#{field.template_field_id}"}
                            value="Yes"
                            checked={@form_data["field_#{field.template_field_id}"] == "Yes"}
                            class="radio radio-primary w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500"
                          /> <span class="text-sm font-medium text-slate-700">Yes</span>
                        </label>

                        <label class="inline-flex items-center gap-2 cursor-pointer">
                          <input
                            type="radio"
                            name={"field_#{field.template_field_id}"}
                            value="No"
                            checked={
                              @form_data["field_#{field.template_field_id}"] == "No" ||
                                (is_nil(@editing_feature_id) and
                                   is_nil(@form_data["field_#{field.template_field_id}"]))
                            }
                            class="radio radio-primary w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500"
                          /> <span class="text-sm font-medium text-slate-700">No</span>
                        </label>
                      </div>
                    <% else %>
                      <%= if field.ref_master_temp_field_Type == 5 do %>
                        <textarea
                          name={"field_#{field.template_field_id}"}
                          class="corp-input h-10 min-h-[40px] resize-y"
                          placeholder={field.policy_feature_template_field_placeholder}
                        >{@form_data["field_#{field.template_field_id}"] || ""}</textarea>
                      <% else %>
                        <input
                          type="text"
                          name={"field_#{field.template_field_id}"}
                          value={@form_data["field_#{field.template_field_id}"] || ""}
                          class="corp-input"
                          placeholder={field.policy_feature_template_field_placeholder}
                        />
                      <% end %>
                    <% end %>
                  </div>

                  <div>
                    <select name={"visibility_role_#{field.template_field_id}"} class="corp-input">
                      <option value="">Select Visibility Role</option>

                      <%= for role <- @visibility_roles do %>
                        <option
                          value={role.role_id}
                          selected={
                            to_string(@form_data["visibility_role_#{field.template_field_id}"]) ==
                              to_string(role.role_id)
                          }
                        >
                          {role.role}
                        </option>
                      <% end %>
                    </select>
                  </div>
                </div>
              </div>
            <% end %>

            <div class="corp-field-group corp-field-group--full corp-form-actions justify-end">
              <button
                type="button"
                phx-click="hide_form"
                phx-target={@myself}
                class="btn btn-secondary"
              >
                Cancel
              </button>

              <button type="submit" class="btn btn-success">
                <.icon name="hero-check" class="w-4 h-4 mr-1" /> {if @editing_feature_id,
                  do: "Update Feature",
                  else: "Save Features"}
              </button>
            </div>
          </.form>
        <% end %>
      <% else %>
        <%!-- Table View --%>
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-medium text-slate-800">Policy Features</h3>

          <button type="button" phx-click="show_form" phx-target={@myself} class="btn btn-primary">
            <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add New
          </button>
        </div>

        <div class="overflow-x-auto">
          <div class="corp-table-card">
            <table class="corp-table">
              <thead>
                <tr>
                  <th class="corp-th text-left p-4 border-b">POLICY BENEFIT IDENTIFIER</th>

                  <th class="corp-th text-right p-4 border-b w-32">ACTIONS</th>
                </tr>
              </thead>

              <tbody>
                <%= for mf <- @mapped_features_page.entries do %>
                  <tr class="corp-tr hover:bg-slate-50 transition-colors">
                    <td class="corp-td p-4 border-b font-medium text-slate-900">
                      {mf.feature_identifier}
                    </td>

                    <td class="corp-td p-4 border-b text-right">
                      <div class="flex justify-end gap-2">
                        <button
                          type="button"
                          phx-click="edit_feature"
                          phx-value-id={mf.id}
                          phx-target={@myself}
                          class="corp-action-btn-text corp-action-btn-text--edit"
                          title="Edit"
                        >
                          <.icon name="hero-pencil" class="w-4 h-4" />
                        </button>

                        <button
                          type="button"
                          phx-click="confirm_delete"
                          phx-value-id={mf.id}
                          phx-target={@myself}
                          class="corp-action-btn-text corp-action-btn-text--delete"
                          title="Delete"
                        >
                          <.icon name="hero-trash" class="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                <% end %>

                <%= if Enum.empty?(@mapped_features) do %>
                  <tr>
                    <td colspan="2" class="p-8 text-center text-slate-500 bg-slate-50">
                      No policy features have been added yet. Click "Add New" to begin.
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

        <.pagination
          page={@mapped_features_page.page}
          page_size={@mapped_features_page.page_size}
          total_entries={@mapped_features_page.total_entries}
          total_pages={@mapped_features_page.total_pages}
          event="paginate_table"
          target={@myself}
        />
        <div class="flex justify-end gap-4 mt-6">
          <button
            type="button"
            phx-click="next_step"
            phx-target={@myself}
            class="btn btn-success"
          >
            Next <.icon name="hero-arrow-right" class="w-4 h-4 ml-1" />
          </button>
        </div>
      <% end %>
      <%!-- Delete Confirmation Modal --%>
      <%= if @confirm_delete_id do %>
        <div class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 border border-slate-200">
            <div class="flex items-center gap-3 text-red-600 mb-4">
              <.icon name="hero-exclamation-triangle" class="w-6 h-6" />
              <h3 class="text-lg font-semibold text-slate-900">Delete Policy Feature</h3>
            </div>

            <p class="text-slate-600 text-sm mb-6">
              Are you sure you want to delete this policy feature? This action cannot be undone.
            </p>

            <div class="flex justify-end gap-3">
              <button
                type="button"
                phx-click="cancel_delete"
                phx-target={@myself}
                class="btn btn-secondary"
              >
                Cancel
              </button>

              <button
                type="button"
                phx-click="delete_feature"
                phx-value-id={@confirm_delete_id}
                phx-target={@myself}
                class="btn btn-error text-white"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp assign_mapped_features_page(socket, mapped_features, page \\ nil) do
    current_page =
      page ||
        if(socket.assigns[:mapped_features_page],
          do: socket.assigns.mapped_features_page.page,
          else: 1
        )

    assign(socket, :mapped_features_page, Pagination.paginate_list(mapped_features, current_page))
  end
end
