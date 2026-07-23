defmodule CorporatePolicyWeb.Admin.Step1PolicyDetailsComponent do
  use CorporatePolicyWeb, :live_component

  alias CorporatePolicy.Policies
  alias CorporatePolicy.StringUtils

  @health_gmc_pt_values [
    "GMC",
    "Parent Policy",
    "Top Up Policy"
  ]

  @line_of_business_values [
    "Health",
    "Life",
    "Others"
  ]

  @intimate_claim_visibility_values [
    "Both",
    "IPD only",
    "OPD only"
  ]

  @impl true
  def update(assigns, socket) do
    # Only load master data once
    socket =
      if not Map.has_key?(socket.assigns, :corporates) do
        line_of_businesses =
          Policies.list_line_of_businesses()
          |> Enum.filter(&StringUtils.in?(&1.line_of_business_value, @line_of_business_values))

        claim_visibilities =
          Policies.list_claim_visibilities()
          |> Enum.filter(&StringUtils.in?(&1.name, @intimate_claim_visibility_values))

        socket
        |> assign(:corporates, Policies.list_corporates())
        |> assign(:line_of_businesses, line_of_businesses)
        |> assign(:family_definitions, Policies.list_family_definitions())
        |> assign(:claim_visibilities, claim_visibilities)
        |> assign(:tpas, Policies.list_tpas())
        |> assign(:sum_insured_types, Policies.list_sum_insured_types())
        |> assign(:policy_types, [])
        |> assign(:insurers, [])
      else
        socket
      end

    form_data =
      assigns[:policy_data] || %{"claim_submission_visibility" => 0, "have_policy_number" => 1}

    # Pre-load dependent dropdowns if editing or previously selected
    lob_id = form_data["ref_md_line_of_businesses_id"]

    socket =
      if lob_id && Map.has_key?(socket.assigns, :line_of_businesses) do
        pt_id = if is_binary(lob_id), do: String.to_integer(lob_id), else: lob_id

        socket
        |> assign(:policy_types, Policies.list_policy_types_by_lob(pt_id))
        |> assign(:insurers, Policies.get_insurer_lists(pt_id))
      else
        socket
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:form_data, form_data)
      |> assign_derived_state(form_data)
      |> assign(:form, to_form(form_data))

    {:ok, socket}
  end

  defp assign_derived_state(socket, form_data) do
    have_policy_number = to_string(form_data["have_policy_number"]) == "1"
    show_claim_submission_email = to_string(form_data["claim_submission_visibility"]) == "1"

    lob_id = form_data["ref_md_line_of_businesses_id"]
    pt_id = form_data["ref_md_policy_types_id"]

    lob =
      if lob_id && Map.has_key?(socket.assigns, :line_of_businesses) do
        Enum.find(socket.assigns.line_of_businesses || [], fn l ->
          to_string(l.id) == to_string(lob_id)
        end)
      end

    pt =
      if pt_id && Map.has_key?(socket.assigns, :policy_types) do
        Enum.find(socket.assigns.policy_types || [], fn p ->
          to_string(p.id) == to_string(pt_id)
        end)
      end

    lob_name = if lob, do: lob.line_of_business_value, else: ""
    pt_name = if pt, do: pt.policy_type_value, else: ""

    show_tpa_family =
      StringUtils.equal?(lob_name, "Health") and StringUtils.in?(pt_name, @health_gmc_pt_values)

    show_sum_insured_type =
      StringUtils.equal?(lob_name, "Health") and StringUtils.equal?(pt_name, "GPA")

    socket
    |> assign(:show_policy_number, have_policy_number)
    |> assign(:show_claim_submission_email, show_claim_submission_email)
    |> assign(:show_tpa_family, show_tpa_family)
    |> assign(:show_sum_insured_type, show_sum_insured_type)
  end

  @impl true
  def handle_event("validate", params, socket) do
    new_form_data = Map.merge(socket.assigns.form_data || %{}, params)

    old_lob = to_string(socket.assigns.form_data["ref_md_line_of_businesses_id"])
    new_lob = to_string(new_form_data["ref_md_line_of_businesses_id"])

    socket =
      if old_lob != new_lob and new_lob != "" do
        case Integer.parse(new_lob) do
          {lob_id_int, _} ->
            policy_types = Policies.list_policy_types_by_lob(lob_id_int)
            insurers = Policies.get_insurer_lists(lob_id_int)

            socket
            |> assign(:policy_types, policy_types)
            |> assign(:insurers, insurers)

          :error ->
            socket
        end
      else
        socket
      end

    new_form_data =
      if old_lob != new_lob do
        Map.drop(new_form_data, [
          "ref_md_policy_types_id",
          "ref_select_insurer_id",
          "ref_tpa_id",
          "ref_md_family_definitions_id",
          "ref_md_sum_insured_types_id"
        ])
      else
        new_form_data
      end

    old_pt = to_string(socket.assigns.form_data["ref_md_policy_types_id"])
    new_pt = to_string(new_form_data["ref_md_policy_types_id"])

    new_form_data =
      if old_pt != new_pt do
        Map.drop(new_form_data, [
          "ref_tpa_id",
          "ref_md_family_definitions_id",
          "ref_md_sum_insured_types_id"
        ])
      else
        new_form_data
      end

    old_start_date = socket.assigns.form_data["policy_start_date"]
    new_start_date = new_form_data["policy_start_date"]

    new_form_data =
      if old_start_date != new_start_date and new_start_date != "" do
        end_date = calculate_end_date(new_start_date)
        Map.put(new_form_data, "policy_end_date", end_date)
      else
        new_form_data
      end

    visibility_int = to_string(new_form_data["claim_submission_visibility"])

    new_form_data =
      if visibility_int == "1" do
        Map.drop(new_form_data, ["ref_intimate_claim_visibilities_id"])
      else
        Map.drop(new_form_data, ["claim_submission_additional_email"])
      end

    have_number_int = to_string(new_form_data["have_policy_number"])

    new_form_data =
      if have_number_int == "0" do
        Map.drop(new_form_data, ["policy_number", "policy_number_identifier"])
      else
        new_form_data
      end

    socket =
      socket
      |> assign(:form_data, new_form_data)
      |> assign_derived_state(new_form_data)
      |> assign(:form, to_form(new_form_data))

    {:noreply, socket}
  end

  @impl true
  def handle_event("save-policy", params, socket) do
    final_params = Map.merge(socket.assigns.form_data || %{}, params)

    case Policies.create_or_update_policy(final_params, socket.assigns.current_user.id) do
      {:ok, policy} ->
        send(self(), {:step_completed, :step1, policy})
        {:noreply, socket |> put_flash(:info, "Policy details saved successfully.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to save policy. Please check the errors below.")
         |> assign(:form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="corp-form-card">
      <.form
        for={@form}
        id="add-policy-form"
        phx-change="validate"
        phx-submit="save-policy"
        phx-target={@myself}
        class="corp-form-grid"
      >
        <%= if @form.errors != [] do %>
          <div class="col-span-full mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-md">
            <p class="font-bold mb-2">Oops, something went wrong! Please check the errors below.</p>
            
            <ul class="list-disc pl-5">
              <%= for {field, {msg, _}} <- @form.errors do %>
                <li><strong>{Phoenix.Naming.humanize(field)}:</strong> {msg}</li>
              <% end %>
            </ul>
          </div>
        <% end %>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Corporate Name <span class="corp-required">*</span>
          </label>
          
          <%= if @edit_mode do %>
            <input
              type="text"
              value={
                Enum.find_value(@corporates, "", fn c ->
                  to_string(c.corporate_id) == to_string(@form_data["ref_corporate_id"] || "") &&
                    c.corporate_name
                end)
              }
              class="corp-input corp-input--readonly"
              readonly
            />
            <input type="hidden" name="ref_corporate_id" value={@form_data["ref_corporate_id"] || ""} />
          <% else %>
            <select
              name="ref_corporate_id"
              class="corp-input"
              required
            >
              <option value="">Select Corporate</option>
              
              <%= for c <- @corporates do %>
                <option
                  value={c.corporate_id}
                  selected={
                    to_string(@form_data["ref_corporate_id"] || "") ==
                      to_string(c.corporate_id)
                  }
                >
                  {c.corporate_name}
                </option>
              <% end %>
            </select>
          <% end %>
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Line of Business <span class="corp-required">*</span>
          </label>
          
          <%= if @edit_mode do %>
            <input
              type="text"
              value={
                Enum.find_value(@line_of_businesses, "", fn l ->
                  to_string(l.id) == to_string(@form_data["ref_md_line_of_businesses_id"] || "") &&
                    l.line_of_business_value
                end)
              }
              class="corp-input corp-input--readonly"
              readonly
            />
            <input
              type="hidden"
              name="ref_md_line_of_businesses_id"
              value={@form_data["ref_md_line_of_businesses_id"] || ""}
            />
          <% else %>
            <select
              name="ref_md_line_of_businesses_id"
              class="corp-input"
              required
            >
              <option value="">Select Line of Business</option>
              
              <%= for lob <- @line_of_businesses do %>
                <option
                  value={lob.id}
                  selected={
                    to_string(@form_data["ref_md_line_of_businesses_id"] || "") ==
                      to_string(lob.id)
                  }
                >
                  {lob.line_of_business_value}
                </option>
              <% end %>
            </select>
          <% end %>
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Policy Type <span class="corp-required">*</span>
          </label>
          
          <%= if @edit_mode do %>
            <input
              type="text"
              value={
                Enum.find_value(@policy_types, "", fn p ->
                  to_string(p.id) == to_string(@form_data["ref_md_policy_types_id"] || "") &&
                    p.policy_type_value
                end)
              }
              class="corp-input corp-input--readonly"
              readonly
            />
            <input
              type="hidden"
              name="ref_md_policy_types_id"
              value={@form_data["ref_md_policy_types_id"] || ""}
            />
          <% else %>
            <select
              name="ref_md_policy_types_id"
              class="corp-input"
              required
              disabled={length(@policy_types) == 0}
            >
              <option value="">Select a policy type</option>
              
              <%= for pt <- @policy_types do %>
                <option
                  value={pt.id}
                  selected={to_string(@form_data["ref_md_policy_types_id"] || "") == to_string(pt.id)}
                >
                  {pt.policy_type_value}
                </option>
              <% end %>
            </select>
          <% end %>
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Select Insurer <span class="corp-required">*</span>
          </label>
          
          <select
            name="ref_select_insurer_id"
            class="corp-input"
            required
          >
            <option value="">Select an insurer</option>
            
            <%= for ins <- @insurers do %>
              <option
                value={ins.id}
                selected={to_string(@form_data["ref_select_insurer_id"] || "") == to_string(ins.id)}
              >
                {ins.name}
              </option>
            <% end %>
          </select>
        </div>
        
        <div :if={@show_sum_insured_type} class="corp-field-group">
          <label class="corp-label">
            Sum Insured Type <span class="corp-required">*</span>
          </label>
          
          <select
            name="ref_md_sum_insured_types_id"
            class="corp-input"
            required={@show_sum_insured_type}
          >
            <option value="">Select Sum Insured Type</option>
            
            <%= for sit <- @sum_insured_types do %>
              <option
                value={sit.id}
                selected={
                  to_string(@form_data["ref_md_sum_insured_types_id"] || "") == to_string(sit.id)
                }
              >
                {sit.name}
              </option>
            <% end %>
          </select>
        </div>
        
        <div :if={@show_tpa_family} class="corp-field-group">
          <label class="corp-label">Select TPA</label>
          <select
            name="ref_tpa_id"
            class="corp-input"
          >
            <option value="">Select TPA</option>
            
            <%= for tpa <- @tpas do %>
              <option
                value={tpa.id}
                selected={to_string(@form_data["ref_tpa_id"] || "") == to_string(tpa.id)}
              >
                {tpa.name}
              </option>
            <% end %>
          </select>
        </div>
        
        <div :if={@show_tpa_family} class="corp-field-group">
          <label class="corp-label">
            Family Definition <span class="corp-required">*</span>
          </label>
          
          <select
            name="ref_md_family_definitions_id"
            class="corp-input"
            required={@show_tpa_family}
          >
            <option value="">Select Family Definition</option>
            
            <%= for fd <- @family_definitions do %>
              <option
                value={fd.id}
                selected={
                  to_string(@form_data["ref_md_family_definitions_id"] || "") ==
                    to_string(fd.id)
                }
              >
                {fd.name}
              </option>
            <% end %>
          </select>
        </div>
        
        <div class="corp-field-group">
          <span class="corp-label">
            Do you have policy number? <span class="corp-required">*</span>
          </span>
          
          <div class="flex gap-4 mt-2">
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="have_policy_number"
                value="1"
                checked={@show_policy_number}
                class="corp-radio"
              /> Yes
            </label>
            
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="have_policy_number"
                value="0"
                checked={!@show_policy_number}
                class="corp-radio"
              /> No
            </label>
          </div>
        </div>
        
        <div :if={@show_policy_number} class="corp-field-group">
          <label class="corp-label">
            Policy Number <span class="corp-required">*</span>
          </label>
          
          <input
            type="text"
            name="policy_number"
            value={@form_data["policy_number"] || ""}
            class="corp-input"
            placeholder="Policy Number"
            required
          />
        </div>
        
        <div :if={@show_policy_number and not @show_sum_insured_type} class="corp-field-group">
          <label class="corp-label">Policy number identifier</label>
          <input
            type="text"
            name="policy_number_identifier"
            value={@form_data["policy_number_identifier"] || ""}
            class="corp-input"
            placeholder="Enter Policy Holder"
          />
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Policy start date <span class="corp-required">*</span>
          </label>
          
          <div class="relative w-full">
            <input
              type="date"
              name="policy_start_date"
              value={@form_data["policy_start_date"] || ""}
              class="corp-input w-full pr-10 [&::-webkit-calendar-picker-indicator]:opacity-0 [&::-webkit-calendar-picker-indicator]:absolute [&::-webkit-calendar-picker-indicator]:w-full"
              onclick="this.showPicker()"
              required
            />
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-gray-800"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
          </div>
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Policy end date <span class="corp-required">*</span>
          </label>
          
          <div class="relative w-full">
            <input
              type="date"
              name="policy_end_date"
              value={@form_data["policy_end_date"] || ""}
              class="corp-input w-full pr-10 [&::-webkit-calendar-picker-indicator]:opacity-0 [&::-webkit-calendar-picker-indicator]:absolute [&::-webkit-calendar-picker-indicator]:w-full"
              onclick="this.showPicker()"
              required
            />
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-gray-800"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
          </div>
        </div>
        
        <div class="corp-field-group">
          <label class="corp-label">
            Claim submission visibility <span class="corp-required">*</span>
          </label>
          
          <div class="flex gap-4 mt-2">
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="claim_submission_visibility"
                value="1"
                checked={@show_claim_submission_email}
                class="corp-radio"
              /> On
            </label>
            
            <label class="inline-flex items-center gap-2">
              <input
                type="radio"
                name="claim_submission_visibility"
                value="0"
                checked={!@show_claim_submission_email}
                class="corp-radio"
              /> Off
            </label>
          </div>
        </div>
        
        <div :if={!@show_claim_submission_email} class="corp-field-group">
          <label class="corp-label">
            Intimate claim visibility <span class="corp-required">*</span>
          </label>
          
          <select
            name="ref_intimate_claim_visibilities_id"
            class="corp-input"
            required
          >
            <option value="">Select</option>
            
            <%= for cv <- @claim_visibilities do %>
              <option
                value={cv.id}
                selected={
                  to_string(@form_data["ref_intimate_claim_visibilities_id"] || "") ==
                    to_string(cv.id)
                }
              >
                {cv.name}
              </option>
            <% end %>
          </select>
        </div>
        
        <div :if={@show_claim_submission_email} class="corp-field-group">
          <label class="corp-label">
            Claim submission additional email <span class="corp-required">*</span>
          </label>
          
          <input
            type="email"
            name="claim_submission_additional_email"
            value={@form_data["claim_submission_additional_email"] || ""}
            class="corp-input"
            placeholder="Enter email(s), comma separated"
            required
          />
        </div>
        
        <div class="corp-field-group corp-field-group--full corp-form-actions">
          <button type="button" phx-click="cancel" class="btn btn-secondary">
            Cancel
          </button>
          
          <button type="submit" class="btn btn-primary">
            <.icon name="hero-check" class="w-4 h-4 mr-1" /> {if @edit_mode,
              do: "Save Changes",
              else: "Create Policy & Next"}
          </button>
        </div>
      </.form>
    </div>
    """
  end

  defp calculate_end_date(start_date_str) do
    case Date.from_iso8601(start_date_str) do
      {:ok, start_date} ->
        next_year = start_date.year + 1

        end_date =
          case Date.new(next_year, start_date.month, start_date.day) do
            {:ok, date} -> Date.add(date, -1)
            {:error, :invalid_date} -> Date.new!(next_year, start_date.month, start_date.day - 1)
          end

        Date.to_iso8601(end_date)

      _ ->
        ""
    end
  end
end
