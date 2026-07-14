defmodule CorporatePolicyWeb.AddPolicyLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Policies
  alias CorporatePolicy.Policies.Corporate
  alias CorporatePolicy.Accounts.User
  alias CorporatePolicy.Repo

  @steps [
    {:corporate, "Corporate", 1},
    {:line_of_business, "Line of Business", 2},
    {:policy_type, "Policy Type", 3},
    {:insurer, "Insurer", 4},
    {:sum_insured, "Sum Insured", 5},
    {:policy_dates, "Policy Dates", 6},
    {:additional_details, "Additional Details", 7}
  ]

  # Health, Life
  @lob_with_family_definition [1, 2]

  @impl true
  def mount(params, session, socket) do
    current_user = assign_current_user(session)
    corporate_id = params["corporate_id"]

    socket =
      socket
      |> assign(:page_title, "Add Policy")
      |> assign(:active_path, "/admin/policy-details")
      |> assign(:current_user, current_user)
      |> assign(:current_step, 1)
      |> assign(:steps, @steps)
      |> assign(:form_data, %{})
      |> assign(:corporates, Policies.list_corporates())
      |> assign(:line_of_businesses, Policies.list_line_of_businesses())
      |> assign(:sum_insured_types, Policies.list_sum_insured_types())
      |> assign(:family_definitions, Policies.list_family_definitions())
      |> assign(:claim_visibilities, Policies.list_claim_visibilities())
      |> assign(:tpas, Policies.list_tpas())
      |> assign(:policy_types, [])
      |> assign(:insurers, [])
      |> assign(:show_family_definition, false)
      |> assign(:show_policy_number, false)

    # If corporate_id is provided in params, pre-select it
    if corporate_id do
      Repo.get(Corporate, corporate_id)

      socket =
        socket
        |> update_form_data(%{"ref_corporate_id" => corporate_id})
        |> assign(:current_step, 2)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("go-to-step", %{"step" => step}, socket) do
    target_step = String.to_integer(step)

    # Validate we can go to this step (can't skip)
    if target_step <= socket.assigns.current_step + 1 do
      {:noreply, assign(socket, :current_step, target_step)}
    else
      {:noreply, put_flash(socket, :error, "Please complete previous steps first")}
    end
  end

  @impl true
  def handle_event("validate-step", %{"step" => step, "form" => form_params}, socket) do
    step = String.to_integer(step)

    case validate_step(socket, step, form_params) do
      {:ok, updated_params} ->
        socket =
          socket
          |> update_form_data(updated_params)
          |> assign(:current_step, step + 1)
          |> load_step_data(step + 1)
          |> put_flash(:info, "Step #{step} completed")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event(
        "line-of-business-changed",
        %{"ref_md_line_of_businesses_id" => lob_id},
        socket
      ) do
    lob_id = String.to_integer(lob_id)

    policy_types = Policies.list_policy_types_by_lob(lob_id)
    insurers = Policies.get_insurer_lists(lob_id)
    show_family_definition = lob_id in @lob_with_family_definition

    socket =
      socket
      |> assign(:policy_types, policy_types)
      |> assign(:insurers, insurers)
      |> assign(:show_family_definition, show_family_definition)
      |> update_form_data(%{
        "ref_md_line_of_businesses_id" => lob_id,
        "line_of_business" =>
          Enum.find(socket.assigns.line_of_businesses, fn lob -> lob.id == lob_id end)
          |> Map.get(:line_of_business_value)
      })
      |> clear_dependent_fields([
        :ref_md_policy_types_id,
        :policy_type,
        :ref_select_insurer_id,
        :select_insurer,
        :ref_md_family_definitions_id
      ])

    {:noreply, socket}
  end

  @impl true
  def handle_event("policy-type-changed", %{"ref_md_policy_types_id" => pt_id}, socket) do
    pt_id = String.to_integer(pt_id)

    policy_type = Enum.find(socket.assigns.policy_types, fn pt -> pt.id == pt_id end)

    socket =
      socket
      |> update_form_data(%{
        "ref_md_policy_types_id" => pt_id,
        "policy_type" => policy_type && policy_type.policy_type_value
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("insurer-changed", %{"ref_select_insurer_id" => insurer_id}, socket) do
    insurer_id = String.to_integer(insurer_id)

    insurer = Enum.find(socket.assigns.insurers, fn ins -> ins.id == insurer_id end)

    socket =
      socket
      |> update_form_data(%{
        "ref_select_insurer_id" => insurer_id,
        "select_insurer" => insurer && insurer.name
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("policy-number-toggle", %{"have_policy_number" => have_number}, socket) do
    have_number = String.to_integer(have_number)

    socket =
      socket
      |> assign(:show_policy_number, have_number == 1)
      |> update_form_data(%{"have_policy_number" => have_number})

    if have_number == 0 do
      update_form_data(socket, %{"policy_number" => nil})
    else
      socket
    end
  end

  @impl true
  def handle_event("policy-start-date-changed", %{"policy_start_date" => start_date}, socket) do
    end_date = calculate_end_date(start_date)

    socket =
      socket
      |> update_form_data(%{
        "policy_start_date" => start_date,
        "policy_end_date" => end_date
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("save-policy", %{"policy" => params}, socket) do
    user_id = socket.assigns.current_user.id
    final_params = Map.merge(socket.assigns.form_data, params)

    case Policies.create_or_update_policy(final_params, user_id) do
      {:ok, _policy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Policy created successfully")
         |> push_patch(to: ~p"/admin/policy-details")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "Failed to save policy")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/policy-details")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <.header>
        <:subtitle>Create new insurance policy</:subtitle>
      </.header>

      <!-- Step Indicator -->
      <div class="mb-6">
        <div class="steps steps-horizontal w-full">
          <%= for {key, label, step_num} <- @steps do %>
            <div class={step_class(step_num, @current_step)}>
              <span class="step">
                <span>{step_num}</span>
              </span>
              <span class="step-label">{label}</span>
            </div>
          <% end %>
        </div>
      </div>

      <div class="card">
        <div class="card-body p-6">
          {render_step(@current_step, assigns)}

          <!-- Navigation Buttons -->
          <div class="flex justify-between mt-6 pt-4 border-t">
            <button
              :if={@current_step > 1}
              type="button"
              phx-click="go-to-step"
              phx-value-step={@current_step - 1}
              class="btn btn-ghost"
            >
              Previous
            </button>

            <div class="flex gap-2 ml-auto">
              <button
                :if={@current_step < length(@steps)}
                type="button"
                phx-click="validate-step"
                phx-value-step={@current_step}
                class="btn btn-primary"
              >
                Next
              </button>

              <.button
                :if={@current_step == length(@steps)}
                phx-click="save-policy"
                variant="primary"
              >
                Create Policy
              </.button>

              <button
                type="button"
                phx-click="cancel"
                class="btn btn-ghost"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  defp render_step(1, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-1-form"
      phx-change="validate-step"
      phx-value-step="1"
    >
      <h3 class="text-lg font-semibold mb-4">Step 1: Select Corporate</h3>
      <.input
        field={@form[:ref_corporate_id]}
        type="select"
        label="Corporate Name"
        required
        options={for c <- assigns.corporates, do: {c.corporate_name, c.corporate_id}}
        prompt="Select Corporate"
        phx-change="validate-step"
        phx-value-step="1"
      />
    </.form>
    """
  end

  defp render_step(2, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-2-form"
      phx-change="validate-step"
      phx-value-step="2"
    >
      <h3 class="text-lg font-semibold mb-4">Step 2: Line of Business</h3>
      <.input
        field={@form[:ref_md_line_of_businesses_id]}
        type="select"
        label="Line of Business"
        required
        options={for lob <- assigns.line_of_businesses, do: {lob.line_of_business_value, lob.id}}
        prompt="Select Line of Business"
        phx-change="line-of-business-changed"
      />
    </.form>
    """
  end

  defp render_step(3, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-3-form"
      phx-change="validate-step"
      phx-value-step="3"
    >
      <h3 class="text-lg font-semibold mb-4">Step 3: Policy Type</h3>
      <.input
        field={@form[:ref_md_policy_types_id]}
        type="select"
        label="Policy Type"
        required
        options={for pt <- assigns.policy_types, do: {pt.policy_type_value, pt.id}}
        prompt="Select Policy Type"
        phx-change="policy-type-changed"
        disabled={length(assigns.policy_types) == 0}
      />
      <%= if length(assigns.policy_types) == 0 do %>
        <p class="text-sm text-base-content/60 mt-2">Select a Line of Business first</p>
      <% end %>
    </.form>
    """
  end

  defp render_step(4, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-4-form"
      phx-change="validate-step"
      phx-value-step="4"
    >
      <h3 class="text-lg font-semibold mb-4">Step 4: Insurer</h3>
      <.input
        field={@form[:ref_select_insurer_id]}
        type="select"
        label="Insurer"
        required
        options={for ins <- assigns.insurers, do: {ins.name, ins.id}}
        prompt="Select Insurer"
        phx-change="insurer-changed"
        disabled={length(assigns.insurers) == 0}
      />
      <%= if length(assigns.insurers) == 0 do %>
        <p class="text-sm text-base-content/60 mt-2">Select a Line of Business first</p>
      <% end %>
    </.form>
    """
  end

  defp render_step(5, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-5-form"
      phx-change="validate-step"
      phx-value-step="5"
    >
      <h3 class="text-lg font-semibold mb-4">Step 5: Sum Insured Type</h3>
      <.input
        field={@form[:ref_md_sum_insured_types_id]}
        type="select"
        label="Sum Insured Type"
        options={for sit <- assigns.sum_insured_types, do: {sit.name, sit.id}}
        prompt="Select Sum Insured Type"
      />
    </.form>
    """
  end

  defp render_step(6, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-6-form"
      phx-change="validate-step"
      phx-value-step="6"
    >
      <h3 class="text-lg font-semibold mb-4">Step 6: Policy Dates</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input
          field={@form[:policy_start_date]}
          type="date"
          label="Policy Start Date"
          required
          phx-change="policy-start-date-changed"
        />
        <.input
          field={@form[:policy_end_date]}
          type="date"
          label="Policy End Date"
          required
          readonly
        />
      </div>
      <p class="text-sm text-base-content/60 mt-2">
        End date is automatically calculated as Start Date + 1 Year - 1 Day
      </p>
    </.form>
    """
  end

  defp render_step(7, assigns) do
    ~H"""
    <.form
      for={to_form(assigns.form_data)}
      id="step-7-form"
      phx-change="validate-step"
      phx-value-step="7"
    >
      <h3 class="text-lg font-semibold mb-4">Step 7: Additional Details</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input
          field={@form[:have_policy_number]}
          type="checkbox"
          label="Has Policy Number"
          phx-change="policy-number-toggle"
        />
      </div>

      <div :if={assigns.show_policy_number} class="mt-4">
        <.input
          field={@form[:policy_number]}
          type="text"
          label="Policy Number"
          required
        />
      </div>

      <div :if={assigns.show_family_definition} class="mt-4">
        <.input
          field={@form[:ref_md_family_definitions_id]}
          type="select"
          label="Family Definition"
          options={for fd <- assigns.family_definitions, do: {fd.name, fd.id}}
          prompt="Select Family Definition"
        />
      </div>

      <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
        <.input
          field={@form[:ref_tpa_id]}
          type="select"
          label="TPA"
          options={for tpa <- assigns.tpas, do: {tpa.name, tpa.id}}
          prompt="Select TPA"
        />

        <.input
          field={@form[:ref_intimate_claim_visibilities_id]}
          type="select"
          label="Claim Intimation Visibility"
          options={for cv <- assigns.claim_visibilities, do: {cv.name, cv.id}}
          prompt="Select"
        />
      </div>

      <.input
        field={@form[:claim_submission_additional_email]}
        type="email"
        label="Additional Email for Claims"
        class="mt-4"
      />
    </.form>
    """
  end

  # Helper functions

  defp validate_step(_socket, 1, params) do
    corporate_id = params["ref_corporate_id"]

    if corporate_id && corporate_id != "",
      do: {:ok, %{"ref_corporate_id" => corporate_id}},
      else: {:error, "Corporate is required"}
  end

  defp validate_step(_socket, 2, params) do
    lob_id = params["ref_md_line_of_businesses_id"]

    if lob_id && lob_id != "",
      do: {:ok, %{"ref_md_line_of_businesses_id" => lob_id}},
      else: {:error, "Line of Business is required"}
  end

  defp validate_step(_socket, 3, params) do
    pt_id = params["ref_md_policy_types_id"]

    if pt_id && pt_id != "",
      do: {:ok, %{"ref_md_policy_types_id" => pt_id}},
      else: {:error, "Policy Type is required"}
  end

  defp validate_step(_socket, 4, params) do
    insurer_id = params["ref_select_insurer_id"]

    if insurer_id && insurer_id != "",
      do: {:ok, %{"ref_select_insurer_id" => insurer_id}},
      else: {:error, "Insurer is required"}
  end

  defp validate_step(_socket, 5, _params), do: {:ok, %{}}

  defp validate_step(_socket, 6, params) do
    start_date = params["policy_start_date"]
    end_date = params["policy_end_date"]

    if start_date && start_date != "" && end_date && end_date != "" do
      {:ok, %{"policy_start_date" => start_date, "policy_end_date" => end_date}}
    else
      {:error, "Policy dates are required"}
    end
  end

  defp validate_step(_socket, 7, _params), do: {:ok, %{}}

  defp update_form_data(socket, new_data) do
    assign(socket, :form_data, Map.merge(socket.assigns.form_data, new_data))
  end

  defp clear_dependent_fields(socket, fields) do
    form_data = socket.assigns.form_data

    Enum.reduce(fields, socket, fn field, acc ->
      Map.delete(acc, field)
    end)
    |> assign(:form_data, form_data)
  end

  defp load_step_data(socket, step) do
    case step do
      3 ->
        lob_id = socket.assigns.form_data["ref_md_line_of_businesses_id"]

        if lob_id do
          socket
          |> assign(:policy_types, Policies.list_policy_types_by_lob(lob_id))
        else
          socket
        end

      4 ->
        lob_id = socket.assigns.form_data["ref_md_line_of_businesses_id"]

        if lob_id do
          socket
          |> assign(:insurers, Policies.get_insurer_lists(lob_id))
          |> assign(:show_family_definition, lob_id in @lob_with_family_definition)
        else
          socket
        end

      _ ->
        socket
    end
  end

  defp calculate_end_date(start_date_str) do
    start_date = Date.from_iso8601!(start_date_str)
    end_date = Date.add(start_date, 365) |> Date.add(-1)
    Date.to_iso8601(end_date)
  end

  defp assign_current_user(session) do
    case session["current_user_id"] do
      nil -> nil
      id -> Repo.get(User, id)
    end
  end

  defp step_class(step_num, current_step) do
    cond do
      step_num < current_step -> "step step-primary"
      step_num == current_step -> "step step-primary"
      true -> "step"
    end
  end
end
