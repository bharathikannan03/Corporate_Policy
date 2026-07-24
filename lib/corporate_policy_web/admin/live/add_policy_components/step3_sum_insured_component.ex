defmodule CorporatePolicyWeb.Admin.Step3SumInsuredComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Pagination

  @impl true
  def update(assigns, socket) do
    policy = assigns[:policy]
    sum_insureds = assigns[:sum_insureds] || []

    policy_identifiers = Policies.list_policy_identifiers_for_policy(policy)

    socket =
      socket
      |> assign(assigns)
      |> assign(:sum_insureds, sum_insureds)
      |> assign(:policy_identifiers, policy_identifiers)
      |> assign(:form, to_form(%{"sum_insured" => "", "policy_feature_identifier" => ""}))
      |> assign_sum_insureds_page(sum_insureds)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add_sum_insured",
        %{"sum_insured" => si_amount, "policy_feature_identifier" => feature_id},
        socket
      ) do
    cond do
      String.trim(si_amount) == "" ->
        {:noreply, socket |> put_flash(:error, "Sum Insured amount cannot be blank.")}

      String.trim(feature_id) == "" ->
        {:noreply, socket |> put_flash(:error, "Please select a Policy Feature Identifier.")}

      true ->
        new_entry = %{
          id: System.unique_integer([:positive]),
          sum_insured: String.trim(si_amount),
          policy_feature_identifier: feature_id
        }

        updated_list = [new_entry | socket.assigns.sum_insureds]

        {:noreply,
         socket
         |> assign(:sum_insureds, updated_list)
         |> assign_sum_insureds_page(updated_list)
         |> assign(:form, to_form(%{"sum_insured" => "", "policy_feature_identifier" => ""}))}
    end
  end

  @impl true
  def handle_event("remove_sum_insured", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)
    updated_list = Enum.reject(socket.assigns.sum_insureds, &(&1.id == id))

    {:noreply,
     socket
     |> assign(:sum_insureds, updated_list)
     |> assign_sum_insureds_page(updated_list)}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, assign_sum_insureds_page(socket, socket.assigns.sum_insureds, page)}
  end

  @impl true
  def handle_event("save_step3", _params, socket) do
    if Enum.empty?(socket.assigns.sum_insureds) do
      {:noreply, socket |> put_flash(:error, "Please add at least one Sum Insured entry.")}
    else
      send(self(), {:step_completed, :step3, socket.assigns.policy})
      {:noreply, socket |> put_flash(:info, "Sum Insured saved successfully.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <%!-- Add Sum Insured Form --%>
      <.form
        for={@form}
        id="add-sum-insured-form"
        phx-submit="add_sum_insured"
        phx-target={@myself}
        class="flex gap-4 items-end mb-8 bg-gray-50 p-4 rounded-lg"
      >
        <%!-- Field 1: Policy Feature Identifier Dropdown --%>
        <div class="flex-1">
          <label class="corp-label">
            Policy Feature Identifier <span class="corp-required">*</span>
          </label>
          
          <select name="policy_feature_identifier" class="corp-input" required>
            <option value="" disabled selected={@form[:policy_feature_identifier].value == ""}>
              Select Feature
            </option>
            
            <%= for pi <- @policy_identifiers do %>
              <option
                value={pi.policy_identifier}
                selected={@form[:policy_feature_identifier].value == pi.policy_identifier}
              >
                {pi.policy_identifier}
              </option>
            <% end %>
          </select>
        </div>
         <%!-- Field 2: Sum Insured Text Box --%>
        <div class="flex-1">
          <label class="corp-label">
            Sum Insured <span class="corp-required">*</span>
          </label>
          
          <input
            type="text"
            name="sum_insured"
            value={@form[:sum_insured].value}
            class="corp-input"
            placeholder="e.g. 500000 or 5L–10L"
            required
          />
        </div>
        
        <div>
          <button type="submit" class="btn btn-outline btn-success">
            <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add
          </button>
        </div>
      </.form>
       <%!-- List of Added Sum Insureds --%>
      <div class="overflow-x-auto corp-table-card mb-8">
        <table class="corp-table">
          <thead>
            <tr>
              <th class="corp-th p-4 border-b text-left">POLICY FEATURE IDENTIFIER</th>
              
              <th class="corp-th p-4 border-b text-left">SUM INSURED AMOUNT</th>
              
              <th class="corp-th p-4 border-b text-right w-24">ACTION</th>
            </tr>
          </thead>
          
          <tbody>
            <%= if Enum.empty?(@sum_insureds) do %>
              <tr>
                <td colspan="3" class="p-8 text-center text-slate-500 bg-slate-50">
                  No sum insureds added yet.
                </td>
              </tr>
            <% else %>
              <%= for si <- @sum_insureds_page.entries do %>
                <tr class="corp-tr hover:bg-slate-50 transition-colors">
                  <td class="corp-td p-4 border-b font-medium">
                    {si.policy_feature_identifier}
                  </td>
                  
                  <td class="corp-td p-4 border-b">
                    {si.sum_insured}
                  </td>
                  
                  <td class="corp-td p-4 border-b text-right">
                    <button
                      type="button"
                      phx-click="remove_sum_insured"
                      phx-value-id={si.id}
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
        page={@sum_insureds_page.page}
        page_size={@sum_insureds_page.page_size}
        total_entries={@sum_insureds_page.total_entries}
        total_pages={@sum_insureds_page.total_pages}
        event="paginate_table"
        target={@myself}
      />
      <div class="corp-form-actions border-t pt-4">
        <button type="button" phx-click="cancel" class="btn btn-secondary">
          Cancel
        </button>
        
        <button type="button" phx-click="save_step3" phx-target={@myself} class="btn btn-success">
          {if @edit_mode, do: "Save Changes", else: "Save & Next"}
        </button>
      </div>
    </div>
    """
  end

  defp assign_sum_insureds_page(socket, sum_insureds, page \\ nil) do
    current_page =
      page ||
        if(socket.assigns[:sum_insureds_page], do: socket.assigns.sum_insureds_page.page, else: 1)

    assign(socket, :sum_insureds_page, Pagination.paginate_list(sum_insureds, current_page))
  end
end
