defmodule CorporatePolicyWeb.AddPolicyLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Step1PolicyDetailsComponent
  alias CorporatePolicyWeb.Step2PolicyFeaturesComponent
  alias CorporatePolicyWeb.Step3SumInsuredComponent
  alias CorporatePolicyWeb.Step4DataUploadComponent
  alias CorporatePolicyWeb.Step5EscalationComponent
  alias CorporatePolicyWeb.Step6DocumentsComponent
  alias CorporatePolicyWeb.Step7CDStatementsComponent

  @steps [:step1, :step2, :step3, :step4, :step5, :step6, :step7]

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_user

    {policy, edit_mode, current_step} =
      case socket.assigns.live_action do
        :edit ->
          id = params["id"]
          policy = Policies.get_policy!(id)
          step = params["step"] |> then(&(if &1, do: String.to_existing_atom(&1), else: :step1))
          {policy, true, step}

        :new ->
          {nil, false, :step1}

        _ ->
          {nil, false, :step1}
      end

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:policy, policy)
      |> assign(:edit_mode, edit_mode)
      |> assign(:current_step, current_step)
      |> assign(:completed_steps, if(edit_mode, do: @steps, else: []))

    {:ok, socket}
  end

  @impl true
  def handle_info({:step_completed, :step1, policy}, socket) do
    socket =
      socket
      |> put_flash(:info, "Policy created successfully.")
      |> push_navigate(to: ~p"/admin/policy-details/#{policy.id}/edit?step=step2")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:step_completed, step, policy}, socket) do
    next_step_index = Enum.find_index(@steps, fn s -> s == step end) + 1
    next_step = Enum.at(@steps, next_step_index)

    socket =
      socket
      |> assign(:policy, policy)
      |> assign(:completed_steps, Enum.uniq([step | socket.assigns.completed_steps]))
      |> assign(:current_step, next_step)

    {:noreply, socket}
  end

  @impl true
  def handle_event("goto-step", %{"step" => step_str}, socket) do
    step = String.to_existing_atom(step_str)
    {:noreply, assign(socket, :current_step, step)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto p-4">
      <h1 class="text-2xl font-bold mb-6">
        {if @edit_mode, do: "Edit Policy", else: "Add Policy"}
      </h1>

      <!-- Custom Styled Wizard Navigation -->
      <div class="w-full mb-8 border rounded-lg bg-base-100 shadow-sm flex overflow-hidden">
        <%= for {step_id, step_num, step_name} <- [
          {:step1, 1, "Policy Details"},
          {:step2, 2, "Policy Features"},
          {:step3, 3, "Sum Insured"},
          {:step4, 4, "Data Upload"},
          {:step5, 5, "EM"},
          {:step6, 6, "Documents"},
          {:step7, 7, "CD Statements"}
        ] do %>
          <% is_active = @current_step == step_id %>
          <% is_completed = step_id in @completed_steps %>
          <% color_class =
            if is_active or is_completed,
              do: "bg-blue-500 text-white",
              else: "bg-gray-300 text-gray-600" %>
          <% text_color = if is_active, do: "text-blue-500 font-semibold", else: "text-gray-600" %>

          <div class={[
            "flex-1 flex items-center justify-center py-4 border-r last:border-r-0 cursor-pointer hover:bg-gray-50 transition-colors",
            if(is_active, do: "border-b-2 border-b-blue-500 bg-blue-50/30")
          ]}
          phx-click="goto-step"
          phx-value-step={step_id}
          >
            <div class={[
              "flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold mr-2",
              color_class
            ]}>
              <%= if is_completed and not is_active do %>
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M5 13l4 4L19 7"
                >
                </path></svg>
              <% else %>
                {step_num}
              <% end %>
            </div>
            <span class={["text-sm", text_color]}>{step_name}</span>
          </div>
        <% end %>
      </div>

      <!-- Main Content Area -->
      <div class="mt-4 bg-base-100 shadow-xl rounded-box p-6">
        <%= case @current_step do %>
          <% :step1 -> %>
            <.live_component
              module={Step1PolicyDetailsComponent}
              id="step1"
              current_user={@current_user}
              policy_data={if @policy, do: policy_to_map(@policy), else: nil}
              edit_mode={@edit_mode}
            />
          <% :step2 -> %>
            <.live_component
              module={Step2PolicyFeaturesComponent}
              id="step2"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% :step3 -> %>
            <.live_component
              module={Step3SumInsuredComponent}
              id="step3"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% :step4 -> %>
            <.live_component
              module={Step4DataUploadComponent}
              id="step4"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% :step5 -> %>
            <.live_component
              module={Step5EscalationComponent}
              id="step5"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% :step6 -> %>
            <.live_component
              module={Step6DocumentsComponent}
              id="step6"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% :step7 -> %>
            <.live_component
              module={Step7CDStatementsComponent}
              id="step7"
              policy={@policy}
              edit_mode={@edit_mode}
            />
          <% _ -> %>
            <div class="text-center p-10">
              <h2 class="text-xl font-semibold">{@current_step}</h2>
              <p class="text-gray-500 mt-2">Implementation pending...</p>
            </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp policy_to_map(policy) do
    policy
    |> Map.from_struct()
    |> Map.drop([:__meta__, :inserted_at, :updated_at])
    |> Enum.map(fn {k, v} -> {to_string(k), v} end)
    |> Enum.into(%{})
  end
end
