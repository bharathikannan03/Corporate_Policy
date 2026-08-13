defmodule CorporatePolicyWeb.Admin.RolesAddLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Repo
  alias CorporatePolicy.Corporates.MdVisibilityRoleFeature
  alias CorporatePolicyWeb.Layouts
  import Ecto.Query

  @modules_config [
    %{module_id: 1, name: "Dashboard", options: [{1, "View"}]},
    %{module_id: 2, name: "Enrollment", options: [{1, "View"}, {2, "Upload Enrollment"}]},
    %{
      module_id: 3,
      name: "Claims",
      options: [{1, "View"}, {3, "Intimate Claim"}, {4, "View Corporate Buffer List"}]
    },
    %{module_id: 4, name: "Cashless Hospitals", options: [{1, "View"}]},
    %{module_id: 5, name: "Escalation Matrix", options: [{1, "View"}]},
    %{module_id: 6, name: "Policy Features", options: [{1, "View"}]},
    %{module_id: 7, name: "Policy Documents", options: [{1, "View"}]},
    %{module_id: 8, name: "CD Statements", options: [{1, "View"}, {5, "Upload CD Statements"}]},
    %{module_id: 9, name: "Endorsements", options: [{1, "View"}]},
    %{module_id: 10, name: "Employee", options: [{6, "View Activity Logs"}]},
    %{
      module_id: 11,
      name: "Reports",
      options: [
        {7, "View Claims Report"},
        {8, "View Demography Report"},
        {9, "View Top Ten Claims"},
        {10, "View Endorsement Analysis"}
      ]
    },
    %{module_id: 12, name: "Summary", options: [{1, "View"}]},
    %{
      module_id: 13,
      name: "Endorsement Calculation",
      options: [
        {11, "Upload Rackrates"},
        {12, "View Rackrates list"},
        {13, "Upload Endorsement Calculation"},
        {14, "View Endorsement List"}
      ]
    }
  ]

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/roles-configuration/add")
      |> assign(:modules_config, @modules_config)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    action = socket.assigns.live_action

    socket =
      case {action, params} do
        {:edit, %{"id" => role_id_str}} ->
          role_id = String.to_integer(role_id_str)

          role =
            Repo.one!(
              from r in MdVisibilityRoleFeature,
                where: r.role_id == ^role_id and is_nil(r.deleted_at)
            )

          permissions = Corporates.get_role_permissions_map(role_id)

          socket
          |> assign(:page_title, "Edit Role")
          |> assign(:role_id, role_id)
          |> assign(:role_name, role.role)
          |> assign(:verified, true)
          |> assign(:permissions, permissions)

        _ ->
          socket
          |> assign(:page_title, "Add Role")
          |> assign(:role_id, nil)
          |> assign(:role_name, "")
          |> assign(:verified, false)
          |> assign(:permissions, %{})
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("verify_name", %{"role_name" => role_name}, socket) do
    role_name = String.trim(role_name) |> String.upcase()

    if Corporates.role_exists?(role_name) do
      {:noreply,
       socket
       |> assign(:role_name, role_name)
       |> assign(:verified, false)
       |> put_flash(:error, "Role name already exists in the database table.")}
    else
      {:noreply,
       socket
       |> assign(:role_name, role_name)
       |> assign(:verified, true)
       |> put_flash(:info, "Role name is available.")}
    end
  end

  @impl true
  def handle_event("change_name", %{"role_name" => role_name}, socket) do
    role_name = String.upcase(role_name)

    if role_name != socket.assigns.role_name do
      {:noreply,
       socket
       |> assign(:role_name, role_name)
       |> assign(:verified, false)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "toggle_permission",
        %{"module-id" => mod_id_str, "option-id" => opt_id_str},
        socket
      ) do
    permissions = socket.assigns.permissions

    updated_opts =
      case Map.get(permissions, mod_id_str) do
        nil ->
          [opt_id_str]

        opts ->
          if Enum.member?(opts, opt_id_str) do
            Enum.reject(opts, &(&1 == opt_id_str))
          else
            [opt_id_str | opts]
          end
      end

    permissions = Map.put(permissions, mod_id_str, updated_opts)
    {:noreply, assign(socket, permissions: permissions)}
  end

  @impl true
  def handle_event("save_role", _params, socket) do
    role_name = socket.assigns.role_name
    permissions = socket.assigns.permissions
    action = socket.assigns.live_action

    cond do
      String.trim(role_name) == "" ->
        {:noreply, put_flash(socket, :error, "Role Name is required.")}

      true ->
        result =
          if action == :edit do
            Corporates.update_role_with_access(socket.assigns.role_id, role_name, permissions)
          else
            Corporates.create_role_with_access(role_name, permissions)
          end

        case result do
          {:ok, _role} ->
            message =
              if action == :edit,
                do: "Role access details updated successfully.",
                else: "Role and its access details stored successfully."

            {:noreply,
             socket
             |> put_flash(:info, message)
             |> push_navigate(to: ~p"/admin/roles-configuration/list")}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Failed to save: #{inspect(reason)}")}
        end
    end
  end

  defp has_permission?(permissions, module_id, option_id) do
    opts = Map.get(permissions, to_string(module_id)) || []
    Enum.member?(opts, to_string(option_id))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-form-page" id="role-add-page">
        <div class="corp-form-header">
          <h1 class="corp-form-title">{@page_title}</h1>
        </div>
        
        <div class="corp-form-card mt-6" id="role-add-card">
          <!-- Name Verification Form -->
          <form
            phx-submit="verify_name"
            phx-change="change_name"
            id="role-name-form"
            class="flex flex-col md:flex-row gap-4 items-start md:items-end"
          >
            <div class="corp-field-group flex-1 w-full max-w-md">
              <label class="corp-label" for="role_name">
                Role Name <span class="corp-required">*</span>
              </label>
              
              <input
                type="text"
                name="role_name"
                value={@role_name}
                placeholder="ENTER ROLE NAME (UPPERCASE ONLY)"
                class="corp-input uppercase"
                id="role_name"
                required
                readonly={@verified && @page_title == "Edit Role"}
              />
            </div>
            
            <div class="flex items-center gap-4">
              <%= if @verified do %>
                <button type="button" class="btn btn-success disabled" disabled>
                  Verified ✓
                </button>
                
                <span class="text-green-600 font-semibold text-sm self-center">Role name is available</span>
              <% else %>
                <button type="submit" class="btn btn-primary" id="verify-role-btn">
                  Verify Name
                </button>
              <% end %>
            </div>
          </form>
          <!-- Permissions Form (Revealed when verified) -->
          <%= if @verified do %>
            <div class="mt-8 border-t pt-6" id="permissions-section">
              <h3 class="text-lg font-semibold text-slate-800 mb-6">
                Permissions Access Configurations
              </h3>
              
              <div class="space-y-4">
                <%= for module <- @modules_config do %>
                  <div class="flex flex-col md:flex-row md:items-center border-b pb-4 border-slate-100 gap-4 md:gap-8">
                    <div class="w-full md:w-64 font-semibold text-slate-800 text-sm">
                      {module.name}
                    </div>
                    
                    <div class="flex flex-wrap gap-6 items-center">
                      <%= for {opt_id, opt_name} <- module.options do %>
                        <label class="flex items-center gap-2 cursor-pointer text-sm text-slate-700 font-medium">
                          <input
                            type="checkbox"
                            checked={has_permission?(@permissions, module.module_id, opt_id)}
                            phx-click="toggle_permission"
                            phx-value-module-id={module.module_id}
                            phx-value-option-id={opt_id}
                            class="checkbox checkbox-primary checkbox-sm border-slate-300"
                          /> {opt_name}
                        </label>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
              
              <div class="mt-8 flex gap-4">
                <button
                  type="button"
                  phx-click="save_role"
                  class="btn btn-success"
                  id="save-role-btn"
                >
                  Save
                </button>
                
                <.link
                  navigate={~p"/admin/roles-configuration/list"}
                  class="btn btn-secondary"
                  id="cancel-role-btn"
                >
                  Cancel
                </.link>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
