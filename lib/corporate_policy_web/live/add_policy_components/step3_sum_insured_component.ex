defmodule CorporatePolicyWeb.Step3SumInsuredComponent do
  use CorporatePolicyWeb, :live_component

  @impl true
  def update(assigns, socket) do
    # In a real scenario, this would be fetched from the database based on the policy ID
    # and the policy features created in step 2.
    sum_insureds = assigns[:sum_insureds] || []

    # Mocked feature list based on Step 2 (Normally fetched from DB)
    available_features = [
      {"Base Cover", "base_cover"},
      {"Top-up Cover", "top_up_cover"},
      {"Maternity Add-on", "maternity_add_on"}
    ]

    socket =
      socket
      |> assign(assigns)
      |> assign(:sum_insureds, sum_insureds)
      |> assign(:available_features, available_features)
      |> assign(:form, to_form(%{"sum_insured" => "", "policy_feature_identifier" => ""}))

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add_sum_insured",
        %{"sum_insured" => si_amount, "policy_feature_identifier" => feature_id},
        socket
      ) do
    # Validate the input is a number
    case Integer.parse(si_amount) do
      {amount, ""} when amount > 0 ->
        new_entry = %{
          # Mock ID
          id: System.unique_integer([:positive]),
          sum_insured: amount,
          policy_feature_identifier: feature_id
        }

        updated_list = [new_entry | socket.assigns.sum_insureds]

        {:noreply,
         socket
         |> assign(:sum_insureds, updated_list)
         |> assign(:form, to_form(%{"sum_insured" => "", "policy_feature_identifier" => ""}))}

      _ ->
        {:noreply, socket |> put_flash(:error, "Sum Insured must be a valid positive number.")}
    end
  end

  @impl true
  def handle_event("remove_sum_insured", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    updated_list = Enum.reject(socket.assigns.sum_insureds, &(&1.id == id))

    {:noreply, assign(socket, :sum_insureds, updated_list)}
  end

  @impl true
  def handle_event("save_step3", _params, socket) do
    if Enum.empty?(socket.assigns.sum_insureds) do
      {:noreply, socket |> put_flash(:error, "Please add at least one Sum Insured.")}
    else
      # In a real scenario, save to DB
      send(self(), {:step_completed, :step3, socket.assigns.policy})
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <!-- Add New Sum Insured Form -->
      <.form
        for={@form}
        id="add-sum-insured-form"
        phx-submit="add_sum_insured"
        phx-target={@myself}
        class="flex gap-4 items-end mb-8 bg-gray-50 p-4 rounded-lg"
      >
        <div class="flex-1">
          <label class="corp-label">Policy Feature</label>
          <select name="policy_feature_identifier" class="corp-input" required>
            <option value="" disabled selected={@form[:policy_feature_identifier].value == ""}>
              Select Feature
            </option>

            <%= for {label, val} <- @available_features do %>
              <option value={val} selected={@form[:policy_feature_identifier].value == val}>
                {label}
              </option>
            <% end %>
          </select>
        </div>

        <div class="flex-1">
          <label class="corp-label">Sum Insured Amount (₹)</label>
          <input
            type="number"
            name="sum_insured"
            value={@form[:sum_insured].value}
            class="corp-input"
            placeholder="e.g. 500000"
            required
            min="1"
          />
        </div>

        <div>
          <button type="submit" class="btn btn-outline btn-primary">
            + Add
          </button>
        </div>
      </.form>
      <!-- List of Added Sum Insureds -->
      <div class="policy-table-wrapper mb-8">
        <table class="policy-table">
          <thead>
            <tr>
              <th>Policy Feature</th>

              <th>Sum Insured Amount</th>

              <th class="text-right">Action</th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@sum_insureds) do %>
              <tr>
                <td colspan="3" class="text-center py-4">No sum insureds added yet.</td>
              </tr>
            <% else %>
              <%= for si <- @sum_insureds do %>
                <tr>
                  <td class="font-medium">
                    {si.policy_feature_identifier |> String.replace("_", " ") |> String.capitalize()}
                  </td>

                  <td>₹ {si.sum_insured}</td>

                  <td class="text-right">
                    <button
                      type="button"
                      phx-click="remove_sum_insured"
                      phx-value-id={si.id}
                      phx-target={@myself}
                      class="text-red-500 hover:text-red-700"
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <div class="flex justify-end gap-4 mt-4 border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>

        <button type="button" phx-click="save_step3" phx-target={@myself} class="btn btn-primary">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end
end
