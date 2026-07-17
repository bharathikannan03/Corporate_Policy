defmodule CorporatePolicyWeb.Step2PolicyFeaturesComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField

  @impl true
  def update(assigns, socket) do
    template_fields = Repo.all(MasterPolicyFeatureTemplateField)

    form_data = assigns[:feature_data] || %{}

    socket =
      socket
      |> assign(assigns)
      |> assign(:template_fields, template_fields)
      |> assign(:form_data, form_data)
      |> assign(:form, to_form(form_data))

    {:ok, socket}
  end

  @impl true
  def handle_event("save-features", params, socket) do
    _final_params = Map.merge(socket.assigns.form_data, params)

    # In a real scenario, we would save these to the database linked to the policy_id
    # For now, we simulate success and move to the next step
    send(self(), {:step_completed, :step2, socket.assigns.policy})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
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
              {field.name} <span :if={field.is_mandatory} class="corp-required">*</span>
            </label>

            <%= if field.field_type_id == 4 do %>
              <!-- Radio/Checkbox Type -->
              <div class="flex gap-4 mt-2">
                <label class="inline-flex items-center gap-2">
                  <input
                    type="radio"
                    name={field.name}
                    value="yes"
                    checked={@form_data[field.name] == "yes"}
                    class="corp-radio"
                  /> Yes
                </label>

                <label class="inline-flex items-center gap-2">
                  <input
                    type="radio"
                    name={field.name}
                    value="no"
                    checked={@form_data[field.name] == "no"}
                    class="corp-radio"
                  /> No
                </label>
              </div>
            <% else %>
              <!-- Standard Text Input -->
              <input
                type="text"
                name={field.name}
                value={@form_data[field.name] || ""}
                class="corp-input"
                placeholder={field.placeholder}
                required={field.is_mandatory}
              />
            <% end %>

            <p :if={field.description != ""} class="text-xs text-gray-400 mt-1">
              {field.description}
            </p>
          </div>
        <% end %>

        <div class="corp-field-group corp-field-group--full flex justify-end gap-4 mt-4">
          <button type="button" phx-click="cancel" class="btn btn-secondary">
            Cancel
          </button>

          <button type="submit" class="btn btn-primary">
            {if @edit_mode, do: "Save Changes", else: "Save Features & Next"}
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
