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
      |> assign_mapped_features_page(mapped_features)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_form", _, socket) do
    {:noreply, assign(socket, :show_form, true)}
  end

  @impl true
  def handle_event("hide_form", _, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  @impl true
  def handle_event("save-features", params, socket) do
    policy = socket.assigns.policy
    template_fields = socket.assigns.template_fields
    template_id = socket.assigns.template_id

    Enum.each(template_fields, fn field ->
      value = params["field_#{field.id}"]
      role_id = params["visibility_role_#{field.id}"]

      if value && value != "" do
        Policies.create_mapped_feature(%{
          ref_policy_feature_template_field_name: field.name,
          policy_feature_template_field_value: value,
          ref_template_id: template_id,
          ref_coporate_id: policy.ref_corporate_id,
          ref_policy_id: policy.id,
          ref_policy_feature_template_field_id: field.id,
          ref_policy_feature_template_field_type_id: field.field_type_id,
          policy_feature_template_field_visibility_role_ids: role_id,
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
     |> assign(:form_data, %{})
     |> assign(:form, to_form(%{}, as: :feature))
     |> put_flash(:info, "Policy Features saved successfully")}
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
          <h3 class="text-lg font-semibold text-slate-800">Add Policy Feature</h3>
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
                <label class="corp-label">
                  {field.name}
                  <%= if field.is_mandatory do %>
                    <span class="corp-required">*</span>
                  <% end %>
                </label>

                <input
                  type="text"
                  name={"field_#{field.id}"}
                  value={@form_data["field_#{field.id}"] || ""}
                  class="corp-input"
                  placeholder={field.placeholder}
                />
                <select name={"visibility_role_#{field.id}"} class="corp-input mt-2">
                  <option value="">Select Visibility Role</option>

                  <%= for role <- @visibility_roles do %>
                    <option value={role.role_id}>{role.role}</option>
                  <% end %>
                </select>
              </div>
            <% end %>

            <div class="corp-field-group corp-field-group--full corp-form-actions">
              <button
                type="button"
                phx-click="hide_form"
                phx-target={@myself}
                class="btn btn-secondary"
              >
                Cancel
              </button>

              <button type="submit" class="btn btn-success">
                <.icon name="hero-check" class="w-4 h-4 mr-1" /> Save Features
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
                    <td class="corp-td p-4 border-b">
                      {mf.feature_identifier}
                    </td>

                    <td class="corp-td p-4 border-b text-right">
                      <div class="flex justify-end gap-2">
                        <button
                          type="button"
                          class="corp-action-btn-text corp-action-btn-text--edit"
                          title="Edit"
                        >
                          <.icon name="hero-pencil" class="w-4 h-4" />
                        </button>

                        <button
                          type="button"
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
