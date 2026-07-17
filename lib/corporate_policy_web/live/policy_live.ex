defmodule CorporatePolicyWeb.PolicyLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Accounts.User
  alias CorporatePolicy.Repo

  @impl true
  def mount(params, session, socket) do
    current_user = assign_current_user(session)
    fy_id = parse_fy_id(params["fy_id"])
    filter = params["filter"] || "all"
    page = String.to_integer(params["page"] || "1")

    socket =
      socket
      |> assign(:page_title, "Policy Details")
      |> assign(:active_path, "/admin/policy-details")
      |> assign(:current_user, current_user)
      |> assign(:filter, filter)
      |> assign(:fy_id, fy_id)
      |> assign(:page, page)
      |> assign(:financial_years, Policies.list_financial_years())
      |> assign(:line_of_businesses, Policies.list_line_of_businesses())
      |> assign(:policy_types, Policies.list_policy_types())
      |> assign(:family_definitions, Policies.list_family_definitions())
      |> assign(:claim_visibilities, Policies.list_claim_visibilities())
      |> assign(:tpas, Policies.list_tpas())
      |> assign(:insurers, Policies.list_insurers())
      |> assign(:corporates, Policies.list_corporates())
      |> assign(:stats, Policies.get_policy_stats(fy_id))
      |> assign(:show_modal, false)
      |> put_flash(:info, "Welcome to Policy Management")

    {:ok, apply_filters(socket, fy_id, filter)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    fy_id = parse_fy_id(params["fy_id"])
    filter = params["filter"] || "all"
    page = String.to_integer(params["page"] || "1")

    socket =
      socket
      |> assign(:fy_id, fy_id)
      |> assign(:filter, filter)
      |> assign(:page, page)

    {:noreply, apply_filters(socket, fy_id, filter)}
  end

  @impl true
  def handle_event("new-policy", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/policy-details/add")}
  end

  @impl true
  def handle_event("edit-policy", %{"id" => id}, socket) do
    policy = Policies.get_policy!(id)
    {:noreply, open_modal(socket, :edit, policy)}
  end

  @impl true
  def handle_event("save-policy", %{"policy" => params}, socket) do
    user_id = socket.assigns.current_user.id
    policy_params = Map.put(params, "user_id", user_id)

    case Policies.create_or_update_policy(policy_params) do
      {:ok, _policy} ->
        {:noreply,
         socket
         |> close_modal()
         |> put_flash(:info, "Policy saved successfully")
         |> assign(:stats, Policies.get_policy_stats(socket.assigns.fy_id))
         |> apply_filters(socket.assigns.fy_id, socket.assigns.filter)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "Failed to save policy")}
    end
  end

  @impl true
  def handle_event("update-status", %{"id" => id, "status" => status}, socket) do
    user_id = socket.assigns.current_user.id

    case Policies.update_policy_status(id, String.to_integer(status), user_id) do
      {:ok, _policy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Policy status updated")
         |> apply_filters(socket.assigns.fy_id, socket.assigns.filter)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  @impl true
  def handle_event("delete-policy", %{"id" => _id}, socket) do
    # Soft delete by setting status to 0 or similar
    # For now, just show confirmation
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate-field", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("close-modal", _params, socket) do
    {:noreply, close_modal(socket)}
  end

  @impl true
  def handle_event("filter-change", %{"filter" => filter}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/admin/policy-details?filter=#{filter}&fy_id=#{socket.assigns.fy_id}")}
  end

  @impl true
  def handle_event("fy-change", %{"fy_id" => fy_id}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/admin/policy-details?filter=#{socket.assigns.filter}&fy_id=#{fy_id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <.header>
        <:subtitle>Manage insurance policies for corporates</:subtitle>
        
        <:actions>
          <div class="flex gap-2">
            <.button
              phx-click="new-policy"
              class="btn-primary"
            >
              <.icon name="hero-plus" class="mr-2" /> Add Policy
            </.button>
            
            <div class="dropdown dropdown-end">
              <label tabindex="0" class="btn btn-ghost btn-sm">
                <.icon name="hero-ellipsis-vertical" class="w-5 h-5" />
              </label>
              
              <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box shadow w-52 p-2">
                <li>
                  <.link
                    navigate={~p"/admin/policy-details"}
                    class="flex items-center gap-2"
                  >
                    <.icon name="hero-list-bullet" class="w-5 h-5" /> All Policies
                  </.link>
                </li>
                
                <li>
                  <.link
                    navigate={~p"/admin/policy-details/add"}
                    class="flex items-center gap-2"
                  >
                    <.icon name="hero-plus" class="w-5 h-5" /> Add Policy
                  </.link>
                </li>
              </ul>
            </div>
          </div>
        </:actions>
      </.header>
      <!-- Filter Bar -->
      <div class="card mb-6">
        <div class="card-body flex flex-wrap gap-4 items-center">
          <div class="flex items-center gap-2">
            <label class="label">Financial Year</label>
            <.input
              type="select"
              name="fy_id"
              value={@fy_id}
              phx-change="fy-change"
              options={for fy <- @financial_years, do: {fy.year_name, fy.id}}
              prompt="All Years"
              class="w-48"
            />
          </div>
          
          <div class="flex items-center gap-2">
            <label class="label">Filter</label>
            <.input
              type="select"
              name="filter"
              value={@filter}
              phx-change="filter-change"
              options={[
                {"All", "all"},
                {"Active", "active"},
                {"Inactive", "inactive"},
                {"Expired", "expired"}
              ]}
              class="w-40"
            />
          </div>
          
          <div class="flex items-center gap-2 ml-auto">
            <span class="badge badge-outline">Total: {@stats.total}</span>
            <span class="badge badge-success">Active: {@stats.active}</span>
            <span class="badge badge-warning">Draft: {@stats.draft}</span>
            <span class="badge badge-error">Expired: {@stats.expired}</span>
          </div>
        </div>
      </div>
      <!-- Policies Table -->
      <div class="card">
        <div class="overflow-x-auto">
          <.table id="policies-table" rows={@policies} row_click={&policy_click/1}>
            <:col :let={policy} label="Policy Name">
              <div>
                <p class="font-medium">{policy.corporate_name}</p>
                
                <p class="text-sm text-base-content/60">
                  {policy.line_of_business} - {policy.policy_type}
                </p>
              </div>
            </:col>
            
            <:col :let={policy} label="Insurer">
              {policy.select_insurer}
            </:col>
            
            <:col :let={policy} label="Policy Number">
              {if policy.have_policy_number == 1, do: policy.policy_number, else: "N/A"}
            </:col>
            
            <:col :let={policy} label="Period">
              <div class="text-sm">
                <p>{format_date(policy.policy_start_date)}</p>
                
                <p class="text-base-content/60">{format_date(policy.policy_end_date)}</p>
              </div>
            </:col>
            
            <:col :let={policy} label="Financial Year">
              {if(policy.financial_year_ref, do: policy.financial_year_ref.year_name, else: "—")}
            </:col>
            
            <:col :let={policy} label="Status">
              <span class={Policy.status_class(policy.status)}>
                {Policy.status_label(policy.status)}
              </span>
            </:col>
            
            <:action :let={policy}>
              <div class="flex gap-2">
                <button
                  phx-click="edit-policy"
                  phx-value-id={policy.id}
                  class="btn btn-sm btn-ghost"
                >
                  <.icon name="hero-pencil" class="w-4 h-4" />
                </button>
                
                <button
                  phx-click="update-status"
                  phx-value-id={policy.id}
                  phx-value-status={next_status(policy.status)}
                  class="btn btn-sm btn-ghost"
                >
                  <.icon name={status_icon(policy.status)} class="w-4 h-4" />
                </button>
              </div>
            </:action>
          </.table>
        </div>
      </div>
      <!-- Empty State -->
      <div :if={@policies == []} class="text-center py-12">
        <.icon name="hero-document-text" class="mx-auto text-base-content/30 size-16" />
        <p class="mt-4 text-base-content/60">No policies found</p>
        
        <.button phx-click="new-policy" class="mt-4" variant="primary">
          Create your first policy
        </.button>
      </div>
      <!-- New/Edit Policy Modal -->
      <div
        :if={@show_modal}
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
        phx-click="close-modal"
      >
        <div
          class="bg-base-100 rounded-box shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto m-4"
          phx-click="--close-modal-stop"
          phx-window-keydown="close-modal"
          phx-key="Escape"
        >
          <div class="p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="font-bold text-lg">
                {if(@modal_action == :new, do: "Create New Policy", else: "Edit Policy")}
              </h3>
              
              <button phx-click="close-modal" class="btn btn-sm btn-ghost btn-square">
                <.icon name="hero-x-mark" class="w-5 h-5" />
              </button>
            </div>
            
            <.form for={@form} id="policy-form" phx-submit="save-policy" phx-change="validate-field">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <.input field={@form[:corporate_name]} type="text" label="Corporate Name" required />
                <.input
                  field={@form[:ref_corporate_id]}
                  type="select"
                  label="Corporate"
                  required
                  options={for c <- @corporates, do: {c.corporate_name, c.corporate_id}}
                  prompt="Select Corporate"
                />
                <.input
                  field={@form[:ref_md_line_of_businesses_id]}
                  type="select"
                  label="Line of Business"
                  required
                  options={for lob <- @line_of_businesses, do: {lob.line_of_business_value, lob.id}}
                  prompt="Select"
                />
                <.input
                  field={@form[:ref_md_policy_types_id]}
                  type="select"
                  label="Policy Type"
                  required
                  options={for pt <- @policy_types, do: {pt.policy_type_value, pt.id}}
                  prompt="Select"
                />
                <.input
                  field={@form[:ref_select_insurer_id]}
                  type="select"
                  label="Insurer"
                  required
                  options={for ins <- @insurers, do: {ins.name, ins.id}}
                  prompt="Select Insurer"
                />
                <.input
                  field={@form[:ref_tpa_id]}
                  type="select"
                  label="TPA"
                  options={for tpa <- @tpas, do: {tpa.name, tpa.id}}
                  prompt="Select TPA"
                />
                <.input
                  field={@form[:have_policy_number]}
                  type="checkbox"
                  label="Has Policy Number"
                /> <.input field={@form[:policy_number]} type="text" label="Policy Number" />
                <.input
                  field={@form[:policy_start_date]}
                  type="date"
                  label="Policy Start Date"
                  required
                />
                <.input
                  field={@form[:policy_end_date]}
                  type="date"
                  label="Policy End Date"
                  required
                />
                <.input
                  field={@form[:ref_fy_year_id]}
                  type="select"
                  label="Financial Year"
                  required
                  options={for fy <- @financial_years, do: {fy.year_name, fy.id}}
                  prompt="Select"
                />
                <.input
                  field={@form[:ref_md_family_definitions_id]}
                  type="select"
                  label="Family Definition"
                  options={for fd <- @family_definitions, do: {fd.name, fd.id}}
                  prompt="Select"
                />
                <.input
                  field={@form[:ref_intimate_claim_visibilities_id]}
                  type="select"
                  label="Claim Intimation Visibility"
                  options={for cv <- @claim_visibilities, do: {cv.name, cv.id}}
                  prompt="Select"
                />
                <.input
                  field={@form[:claim_submission_additional_email]}
                  type="email"
                  label="Additional Email for Claims"
                />
              </div>
              
              <div class="flex justify-end gap-4 mt-6 pt-4 border-t">
                <button type="button" phx-click="close-modal" class="btn btn-primary btn-soft">
                  Cancel
                </button>
                
                <.button variant="primary">
                  {if(@modal_action == :new, do: "Create Policy", else: "Update Policy")}
                </.button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  # ─── Private helpers ────────────────────────────────────────────────

  defp parse_fy_id(nil), do: 0
  defp parse_fy_id("0"), do: 0
  defp parse_fy_id(id) when is_binary(id), do: String.to_integer(id)
  defp parse_fy_id(id) when is_integer(id), do: id

  defp assign_current_user(session) do
    case session["current_user_id"] do
      nil -> nil
      id -> Repo.get(User, id)
    end
  end

  defp apply_filters(socket, fy_id, filter) do
    policies =
      cond do
        filter == "active" ->
          Policies.list_active_policies()

        filter == "inactive" ->
          Policies.list_inactive_policies()

        filter == "expired" ->
          Policies.list_expired_policies()

        true ->
          Policies.list_policies_by_fy(fy_id)
      end

    # Apply corporate filtering for broker users
    policies = filter_policies_for_user(policies, socket.assigns.current_user)

    assign(socket, :policies, policies)
  end

  defp filter_policies_for_user(policies, _user), do: policies

  defp open_modal(socket, :edit, policy) do
    changeset = Policy.update_changeset(policy, %{})
    do_open_modal(socket, :edit, changeset, policy)
  end

  defp do_open_modal(socket, action, changeset, policy) do
    socket
    |> assign(:show_modal, true)
    |> assign(:modal_action, action)
    |> assign(:form, to_form(changeset))
    |> assign(:editing_policy, policy)
  end

  defp close_modal(socket) do
    socket
    |> assign(:show_modal, false)
    |> assign(:modal_action, nil)
    |> assign(:form, nil)
    |> assign(:editing_policy, nil)
  end

  defp policy_click(_policy) do
    # Navigate to policy detail or edit
    # push_patch(socket, to: ~p"/admin/policy-details/#{policy.id}")
  end

  defp format_date(nil), do: "—"
  defp format_date(date) when is_binary(date), do: date
  defp format_date(%Date{} = date), do: Date.to_string(date)

  # Draft -> Active
  defp next_status(0), do: 1
  # Active -> Inactive
  defp next_status(1), do: 2
  # Inactive -> Active
  defp next_status(2), do: 1
  # Expired stays expired
  defp next_status(3), do: 3

  defp status_icon(0), do: "hero-play-circle"
  defp status_icon(1), do: "hero-pause-circle"
  defp status_icon(2), do: "hero-play-circle"
  defp status_icon(3), do: "hero-clock"
end
