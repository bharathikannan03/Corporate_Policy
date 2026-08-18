defmodule CorporatePolicyWeb.Admin.Step5EscalationComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.EscalationMatrices
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Pagination

  @levels [
    {1, "Level 1 (First Contact)"},
    {2, "Level 2 (Supervisor)"},
    {3, "Level 3 (Management)"}
  ]

  @impl true
  def update(assigns, socket) do
    policy = assigns.policy

    # Always reload from DB — no in-memory accumulation
    matrices =
      if policy && policy.id,
        do: Policies.list_escalation_matrices_for_policy(policy.id),
        else: []

    available_users = EscalationMatrices.list_escalation_matrices()

    socket =
      socket
      |> assign(assigns)
      |> assign(:matrices, matrices)
      |> assign(:available_users, available_users)
      |> assign(:levels, @levels)
      |> assign(:form, to_form(%{"escalation_level_id" => "", "user_id" => ""}))
      |> assign_matrices_page(matrices)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add_matrix",
        %{"escalation_level_id" => level_id_str, "user_id" => user_id_str},
        socket
      ) do
    with {level_id, ""} <- Integer.parse(level_id_str),
         {user_id, ""} <- Integer.parse(user_id_str) do
      if Enum.any?(socket.assigns.matrices, &(&1.escalation_level_id == level_id)) do
        send(self(), {:put_flash, :error, "This escalation level has already been assigned."})
        {:noreply, socket}
      else
        user = Enum.find(socket.assigns.available_users, &(&1.id == user_id))
        {_, level_name} = Enum.find(socket.assigns.levels, &(elem(&1, 0) == level_id))

        current_user = socket.assigns[:current_user]
        actor_id = current_user && current_user.id
        policy = socket.assigns.policy

        attrs = %{
          escalation_level_id: level_id,
          level: level_name,
          user_id: user.id,
          user_fullname: user.fullname
        }

        case Policies.create_policy_escalation_matrix(policy.id, attrs, actor_id) do
          {:ok, _record} ->
            # Reload from DB so IDs are real DB ids (survives refresh)
            updated_list = Policies.list_escalation_matrices_for_policy(policy.id)

            {:noreply,
             socket
             |> assign(:matrices, updated_list)
             |> assign_matrices_page(updated_list)
             |> assign(:form, to_form(%{"escalation_level_id" => "", "user_id" => ""}))
             |> put_flash(:info, "Escalation contact assigned successfully.")}

          {:error, _changeset} ->
            {:noreply,
             socket |> put_flash(:error, "Failed to save escalation contact. Please try again.")}
        end
      end
    else
      _ ->
        {:noreply, socket |> put_flash(:error, "Please select a valid level and contact.")}
    end
  end

  @impl true
  def handle_event("remove_matrix", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    current_user = socket.assigns[:current_user]
    user_id = current_user && current_user.id

    case Policies.delete_policy_escalation_matrix(id, user_id) do
      {:ok, _} ->
        policy = socket.assigns.policy
        updated_list = Policies.list_escalation_matrices_for_policy(policy.id)

        {:noreply,
         socket
         |> assign(:matrices, updated_list)
         |> assign_matrices_page(updated_list)
         |> put_flash(:info, "Escalation contact removed.")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to remove escalation contact.")}
    end
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, assign_matrices_page(socket, socket.assigns.matrices, page)}
  end

  @impl true
  def handle_event("save_step5", _params, socket) do
    # All entries are already in DB — just validate at least one exists then navigate
    if Enum.empty?(socket.assigns.matrices) do
      # Send to parent LiveView so the flash appears in the layout
      send(
        self(),
        {:put_flash, :error, "Please configure at least one Escalation level before proceeding."}
      )

      {:noreply, socket}
    else
      policy = socket.assigns.policy
      send(self(), {:step_completed, :step5, policy})
      {:noreply, socket |> put_flash(:info, "Escalation matrix saved. Proceeding to next step.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <%!-- Add Escalation Form --%>
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
                {user.fullname} {if user.type, do: "(#{user.type})", else: ""}
              </option>
            <% end %>
          </select>
        </div>

        <div>
          <button type="submit" class="btn btn-outline btn-success">
            <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Assign & Save
          </button>
        </div>
      </.form>
      <%!-- Info banner: entries are saved immediately --%>
      <div class="mb-4 flex items-start gap-2 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
        <.icon name="hero-check-circle" class="mt-0.5 h-4 w-4 shrink-0 text-green-600" />
        <span>Each contact is saved to the database immediately when you click <strong>Assign & Save</strong>. You can safely refresh the page without losing data.</span>
      </div>
      <%!-- Configured Escalations Table --%>
      <div class="overflow-x-auto corp-table-card mb-8">
        <table class="corp-table">
          <thead>
            <tr>
              <th class="corp-th p-4 border-b text-left">LEVEL</th>

              <th class="corp-th p-4 border-b text-left">CONTACT PERSON</th>

              <th class="corp-th p-4 border-b text-left">TYPE</th>

              <th class="corp-th p-4 border-b text-right w-24">ACTION</th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@matrices) do %>
              <tr>
                <td colspan="4" class="p-8 text-center text-slate-500 bg-slate-50">
                  No escalation contacts configured yet.
                </td>
              </tr>
            <% else %>
              <%= for matrix <- @matrices_page.entries do %>
                <tr class="corp-tr hover:bg-slate-50 transition-colors">
                  <td class="corp-td p-4 border-b font-medium">{matrix.level}</td>

                  <td class="corp-td p-4 border-b">{matrix.user_fullname}</td>

                  <td class="corp-td p-4 border-b text-slate-500">{matrix[:user_type] || "—"}</td>

                  <td class="corp-td p-4 border-b text-right">
                    <button
                      type="button"
                      phx-click="remove_matrix"
                      phx-value-id={matrix.id}
                      phx-target={@myself}
                      class="corp-action-btn-text corp-action-btn-text--delete"
                      title="Remove"
                    >
                      <.icon name="hero-trash" class="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <.pagination
        page={@matrices_page.page}
        page_size={@matrices_page.page_size}
        total_entries={@matrices_page.total_entries}
        total_pages={@matrices_page.total_pages}
        event="paginate_table"
        target={@myself}
      />
      <div class="corp-form-actions border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>

        <button type="button" phx-click="save_step5" phx-target={@myself} class="btn btn-success">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
          <.icon name="hero-arrow-right" class="w-4 h-4 ml-1" />
        </button>
      </div>
    </div>
    """
  end

  defp assign_matrices_page(socket, matrices, page \\ nil) do
    current_page =
      page || if(socket.assigns[:matrices_page], do: socket.assigns.matrices_page.page, else: 1)

    assign(socket, :matrices_page, Pagination.paginate_list(matrices, current_page))
  end
end
