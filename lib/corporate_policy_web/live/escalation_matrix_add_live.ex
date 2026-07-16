defmodule CorporatePolicyWeb.EscalationMatrixAddLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.EscalationMatrices
  alias CorporatePolicy.EscalationMatrices.EscalationMatrix

  @impl true
  def mount(params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/escalation-matrix/add-user")

    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    changeset = EscalationMatrices.change_escalation_matrix(%EscalationMatrix{})

    socket
    |> assign(:page_title, "Add New User Escalation Matrix")
    |> assign(:escalation_matrix, %EscalationMatrix{})
    |> assign(:form, to_form(changeset, as: :escalation_matrix))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    escalation_matrix = EscalationMatrices.get_escalation_matrix!(id)
    changeset = EscalationMatrices.change_escalation_matrix(escalation_matrix)

    socket
    |> assign(:page_title, "Edit User Escalation Matrix")
    |> assign(:escalation_matrix, escalation_matrix)
    |> assign(:form, to_form(changeset, as: :escalation_matrix))
  end

  @impl true
  def handle_event("validate", %{"escalation_matrix" => params}, socket) do
    processed = process_params(params)

    changeset =
      socket.assigns.escalation_matrix
      |> EscalationMatrices.change_escalation_matrix(processed)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :escalation_matrix))}
  end

  @impl true
  def handle_event("save", %{"escalation_matrix" => params}, socket) do
    processed = process_params(params)
    save_escalation_matrix(socket, socket.assigns.live_action, processed)
  end

  defp save_escalation_matrix(socket, :new, params) do
    case EscalationMatrices.create_escalation_matrix(params) do
      {:ok, _escalation_matrix} ->
        {:noreply,
         socket
         |> put_flash(:info, "User Escalation Matrix created successfully")
         |> push_navigate(to: ~p"/admin/escalation-matrix/user-master")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :escalation_matrix))}
    end
  end

  defp save_escalation_matrix(socket, :edit, params) do
    case EscalationMatrices.update_escalation_matrix(socket.assigns.escalation_matrix, params) do
      {:ok, _escalation_matrix} ->
        {:noreply,
         socket
         |> put_flash(:info, "User Escalation Matrix updated successfully")
         |> push_navigate(to: ~p"/admin/escalation-matrix/user-master")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :escalation_matrix))}
    end
  end

  defp process_params(params) do
    type_id = Map.get(params, "type_id")

    type_name =
      case type_id do
        "1" -> "Broker"
        "2" -> "TPA"
        _ -> nil
      end

    params
    |> Map.put("type", type_name)
    |> Map.update("send_mail_alt_email", false, fn
      "true" -> true
      true -> true
      _ -> false
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-form-page" id="escalation-form-page">
        <div class="corp-form-header">
          <h1 class="corp-form-title">{@page_title}</h1>
        </div>
        
        <div class="corp-form-card" id="escalation-form-card">
          <.form
            for={@form}
            id="escalation-matrix-form"
            phx-change="validate"
            phx-submit="save"
          >
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <!-- Full Name -->
              <div class="corp-field-group">
                <label class="corp-label" for="fullname">
                  Full Name <span class="corp-required">*</span>
                </label>
                
                <.input
                  field={@form[:fullname]}
                  type="text"
                  placeholder="Enter Full Name"
                  class="corp-input"
                  id="fullname"
                />
              </div>
              <!-- Phone Number -->
              <div class="corp-field-group">
                <label class="corp-label" for="phone_number">
                  Phone Number
                </label>
                
                <.input
                  field={@form[:phone_number]}
                  type="text"
                  placeholder="Enter Phone Number"
                  class="corp-input"
                  id="phone_number"
                />
              </div>
              <!-- Mobile Number -->
              <div class="corp-field-group">
                <label class="corp-label" for="mobile_number">
                  Mobile Number <span class="corp-required">*</span>
                </label>
                
                <.input
                  field={@form[:mobile_number]}
                  type="text"
                  placeholder="Enter Mobile Number"
                  class="corp-input"
                  id="mobile_number"
                />
              </div>
              <!-- Email Address -->
              <div class="corp-field-group">
                <label class="corp-label" for="email_id">
                  Email Address <span class="corp-required">*</span>
                </label>
                
                <.input
                  field={@form[:email_id]}
                  type="email"
                  placeholder="Enter Email Id"
                  class="corp-input"
                  id="email_id"
                />
              </div>
              <!-- Alternate Email ID -->
              <div class="corp-field-group">
                <label class="corp-label" for="alt_email_id">
                  Alternate Email ID
                </label>
                
                <.input
                  field={@form[:alt_email_id]}
                  type="email"
                  placeholder="Enter Alternate email id"
                  class="corp-input"
                  id="alt_email_id"
                />
              </div>
              <!-- Send email to alternate email -->
              <div class="corp-field-group">
                <label class="corp-label">
                  Send email to alternate email
                </label>
                
                <div class="flex gap-6 mt-3">
                  <label class="flex items-center gap-2 cursor-pointer font-medium text-slate-700">
                    <input
                      type="radio"
                      name="escalation_matrix[send_mail_alt_email]"
                      value="false"
                      checked={
                        to_string(@form[:send_mail_alt_email].value) in ["false", "nil", "", "false"]
                      }
                      class="radio radio-primary w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500"
                    /> No
                  </label>
                  
                  <label class="flex items-center gap-2 cursor-pointer font-medium text-slate-700">
                    <input
                      type="radio"
                      name="escalation_matrix[send_mail_alt_email]"
                      value="true"
                      checked={to_string(@form[:send_mail_alt_email].value) == "true"}
                      class="radio radio-primary w-5 h-5 text-blue-600 border-gray-300 focus:ring-blue-500"
                    /> Yes
                  </label>
                </div>
              </div>
              <!-- Full Address -->
              <div class="corp-field-group md:col-span-2">
                <label class="corp-label" for="company_fulladdress">
                  Full address of Respective Company
                </label>
                
                <.input
                  field={@form[:company_fulladdress]}
                  type="textarea"
                  placeholder="Enter Company Address"
                  class="corp-input h-20"
                  id="company_fulladdress"
                  rows="3"
                />
              </div>
              <!-- Type -->
              <div class="corp-field-group">
                <label class="corp-label" for="type_id">
                  Type
                </label>
                
                <.input
                  field={@form[:type_id]}
                  type="select"
                  prompt="Select Type"
                  options={[{"Broker", "1"}, {"TPA", "2"}]}
                  class="corp-input w-full select"
                  id="type_id"
                />
              </div>
            </div>
            
            <div class="mt-8 flex justify-start">
              <button
                type="submit"
                class="btn-primary px-6 py-2.5 rounded-lg font-semibold shadow-md transition duration-200 hover:shadow-lg cursor-pointer"
                id="escalation-submit-btn"
              >
                Submit
              </button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
