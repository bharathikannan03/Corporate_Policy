defmodule CorporatePolicyWeb.Step5EscalationComponent do
  use CorporatePolicyWeb, :live_component

  @impl true
  def update(assigns, socket) do
    # Fetch existing matrices for this policy
    matrices = assigns[:matrices] || []

    # Mock list of internal users/employees that can be assigned
    available_users = [
      %{id: 1, fullname: "Alice Johnson", role: "Support Agent"},
      %{id: 2, fullname: "Bob Smith", role: "Team Lead"},
      %{id: 3, fullname: "Charlie Davis", role: "Manager"}
    ]

    # Escalation levels
    levels = [
      {1, "Level 1 (First Contact)"},
      {2, "Level 2 (Supervisor)"},
      {3, "Level 3 (Management)"}
    ]

    socket =
      socket
      |> assign(assigns)
      |> assign(:matrices, matrices)
      |> assign(:available_users, available_users)
      |> assign(:levels, levels)
      |> assign(:form, to_form(%{"escalation_level_id" => "", "user_id" => ""}))

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add_matrix",
        %{"escalation_level_id" => level_id_str, "user_id" => user_id_str},
        socket
      ) do
    level_id = String.to_integer(level_id_str)
    user_id = String.to_integer(user_id_str)

    # Check if level already exists
    if Enum.any?(socket.assigns.matrices, &(&1.escalation_level_id == level_id)) do
      {:noreply, socket |> put_flash(:error, "This escalation level has already been assigned.")}
    else
      user = Enum.find(socket.assigns.available_users, &(&1.id == user_id))
      {_, level_name} = Enum.find(socket.assigns.levels, &(elem(&1, 0) == level_id))

      new_entry = %{
        id: System.unique_integer([:positive]),
        escalation_level_id: level_id,
        level: level_name,
        user_id: user.id,
        user_fullname: user.fullname
      }

      updated_list = Enum.sort_by([new_entry | socket.assigns.matrices], & &1.escalation_level_id)

      {:noreply,
       socket
       |> assign(:matrices, updated_list)
       |> assign(:form, to_form(%{"escalation_level_id" => "", "user_id" => ""}))}
    end
  end

  @impl true
  def handle_event("remove_matrix", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    updated_list = Enum.reject(socket.assigns.matrices, &(&1.id == id))

    {:noreply, assign(socket, :matrices, updated_list)}
  end

  @impl true
  def handle_event("save_step5", _params, socket) do
    if Enum.empty?(socket.assigns.matrices) do
      {:noreply, socket |> put_flash(:error, "Please configure at least one Escalation level.")}
    else
      send(self(), {:step_completed, :step5, socket.assigns.policy})
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <!-- Add Escalation Form -->
      <.form
        for={@form}
        id="add-escalation-form"
        phx-submit="add_matrix"
        phx-target={@myself}
        class="flex gap-4 items-end mb-8 bg-gray-50 p-4 rounded-lg"
      >
        <div class="flex-1">
          <label class="corp-label">Escalation Level</label>
          <select name="escalation_level_id" class="corp-input" required>
            <option value="" disabled selected={@form[:escalation_level_id].value == ""}>
              Select Level
            </option>
            <%= for {id, name} <- @levels do %>
              <option value={id} selected={@form[:escalation_level_id].value == to_string(id)}>
                {name}
              </option>
            <% end %>
          </select>
        </div>

        <div class="flex-1">
          <label class="corp-label">Assign To</label>
          <select name="user_id" class="corp-input" required>
            <option value="" disabled selected={@form[:user_id].value == ""}>Select Contact</option>
            <%= for user <- @available_users do %>
              <option value={user.id} selected={@form[:user_id].value == to_string(user.id)}>
                {user.fullname} ({user.role})
              </option>
            <% end %>
          </select>
        </div>

        <div>
          <button type="submit" class="btn btn-outline btn-primary">
            + Assign
          </button>
        </div>
      </.form>

      <!-- Configured Escalations Table -->
      <div class="policy-table-wrapper mb-8">
        <table class="policy-table">
          <thead>
            <tr>
              <th>Level</th>
              <th>Contact Person</th>
              <th class="text-right">Action</th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@matrices) do %>
              <tr>
                <td colspan="3" class="text-center py-4">
                  No escalation contacts configured yet.
                </td>
              </tr>
            <% else %>
              <%= for matrix <- @matrices do %>
                <tr>
                  <td class="font-medium">{matrix.level}</td>
                  <td>{matrix.user_fullname}</td>
                  <td class="text-right">
                    <button
                      type="button"
                      phx-click="remove_matrix"
                      phx-value-id={matrix.id}
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
        <button type="button" phx-click="save_step5" phx-target={@myself} class="btn btn-primary">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end
end
