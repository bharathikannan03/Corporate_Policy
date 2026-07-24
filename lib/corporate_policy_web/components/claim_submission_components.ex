defmodule CorporatePolicyWeb.ClaimSubmissionComponents do
  use CorporatePolicyWeb, :html

  alias CorporatePolicy.Claims
  alias CorporatePolicy.Claims.MasterClaimSubmission
  alias CorporatePolicy.StringUtils

  attr :portal, :atom, required: true
  attr :current_user, :map, default: nil
  attr :page_title, :string, required: true
  attr :active_path, :string, default: ""
  attr :selected_policy_id, :integer, default: nil
  attr :show_navigation, :boolean, default: true
  slot :inner_block, required: true

  def portal_shell(assigns) do
    ~H"""
    <div class="corp-list-page" id={"#{@portal}-claims-shell"}>
      <div class="corp-list-header">
        <div>
          <h1 class="corp-list-title">{@page_title}</h1>
          
          <%= if @portal != :employee do %>
            <p class="corp-list-subtitle">
              Manage claim submissions for the {portal_label(@portal)}.
            </p>
          <% end %>
        </div>
        
        <div class="header-actions gap-3 flex items-center">
          <%= if @portal == :corporate do %>
            <div class="text-sm text-gray-500">
              Logged in as
              <span class="font-semibold text-gray-700">
                {if @current_user,
                  do: @current_user.full_name || @current_user.first_name,
                  else: "User"}
              </span>
            </div>
          <% end %>
        </div>
      </div>
      
      <%= if @show_navigation do %>
        <div class="mb-6 border-b border-gray-200">
          <div class="flex gap-3 flex-wrap">
            <.link
              navigate={policy_aware_path(@portal, "/claims-submission", @selected_policy_id)}
              class={tab_class(@active_path == portal_path(@portal, "/claims-submission"))}
            >
              All Claims
            </.link>
            
            <.link
              navigate={policy_aware_path(@portal, "/claims-submission/add", @selected_policy_id)}
              class={tab_class(@active_path == portal_path(@portal, "/claims-submission/add"))}
            >
              Add Claim
            </.link>
          </div>
        </div>
      <% end %>
       {render_slot(@inner_block)}
    </div>
    """
  end

  attr :claims_page, :map, required: true
  attr :portal, :atom, required: true
  attr :status_options, :list, default: []
  attr :selected_policy_id, :integer, default: nil

  def submissions_index(assigns) do
    ~H"""
    <div class="corp-table-card">
      <div class="flex flex-col gap-4 p-4 border-b border-gray-200 md:flex-row md:items-end md:justify-between">
        <.form
          for={to_form(%{"search" => @claims_page.search, "status" => @claims_page.status})}
          id={"#{@portal}-claims-filter-form"}
          phx-change="filter"
          class="grid grid-cols-1 gap-4 md:grid-cols-3 md:w-full"
        >
          <div>
            <label class="corp-label">Search</label>
            <input
              type="text"
              name="search"
              value={@claims_page.search}
              placeholder="Claim no, policy no, patient..."
              class="corp-input"
            />
          </div>
          
          <div>
            <label class="corp-label">Status</label>
            <select name="status" class="corp-input">
              <option value="">All Statuses</option>
              
              <%= for status <- @status_options do %>
                <option value={status} selected={StringUtils.equal?(@claims_page.status, status)}>
                  {status}
                </option>
              <% end %>
            </select>
          </div>
        </.form>
        
        <div class="header-actions flex gap-2">
          <.link
            navigate={
              policy_aware_path(@portal, "/claims-submission/add", assigns[:selected_policy_id])
            }
            class="btn btn-success employee-primary-action"
          >
            <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add New
          </.link>
          
          <.link
            href={
              policy_aware_path(@portal, "/claims-submission/export", assigns[:selected_policy_id])
            }
            class="btn-secondary"
          >
            <.icon name="hero-arrow-down-tray" class="w-4 h-4 mr-1" /> Export
          </.link>
        </div>
      </div>
      
      <div class="overflow-x-auto">
        <table class="corp-table">
          <thead>
            <tr>
              <th class="corp-th">SI No</th>
              
              <th class="corp-th">{sortable_link(assigns, "Claim Number", "claim_number")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Corporate Name", "corporate_name")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Policy Number", "policy_number")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Employee Code", "employee_code")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Patient Name", "patient_name")}</th>
              
              <th class="corp-th">
                {sortable_link(assigns, "Hospitalization", "hospitalization_date")}
              </th>
              
              <th class="corp-th">{sortable_link(assigns, "Discharge", "discharge_date")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Status", "claim_status")}</th>
              
              <th class="corp-th">{sortable_link(assigns, "Created At", "inserted_at")}</th>
              
              <th class="corp-th text-right">Actions</th>
            </tr>
          </thead>
          
          <tbody>
            <%= if @claims_page.entries == [] do %>
              <tr class="corp-empty-row">
                <td colspan="11" class="corp-empty-cell">
                  <div class="corp-empty-state">
                    <.icon name="hero-inbox" class="w-12 h-12 text-gray-300 mb-3" />
                    <p class="corp-empty-text">No claim submissions found</p>
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {claim, index} <- Enum.with_index(@claims_page.entries, 1) do %>
                <tr class="corp-tr">
                  <td class="corp-td">{(@claims_page.page - 1) * @claims_page.page_size + index}</td>
                  
                  <td class="corp-td">{claim.claim_number}</td>
                  
                  <td class="corp-td">{claim.corporate_name}</td>
                  
                  <td class="corp-td">{claim.policy_number}</td>
                  
                  <td class="corp-td">{claim.employee_code}</td>
                  
                  <td class="corp-td">{claim.patient_name}</td>
                  
                  <td class="corp-td">{format_date(claim.hospitalization_date)}</td>
                  
                  <td class="corp-td">{format_date(claim.discharge_date)}</td>
                  
                  <td class="corp-td"><.status_badge status={claim.claim_status} /></td>
                  
                  <td class="corp-td">{format_datetime(claim.inserted_at)}</td>
                  
                  <td class="corp-td">
                    <div class="corp-actions justify-end">
                      <.link
                        navigate={portal_path(@portal, "/claims-submission/#{claim.id}/edit")}
                        class="corp-action-btn-text corp-action-btn-text--edit"
                      >
                        <.icon name="hero-pencil-square" class="w-4 h-4 mr-1" /> Edit
                      </.link>
                    </div>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>
      
      <.pagination
        page={@claims_page.page}
        page_size={@claims_page.page_size}
        total_entries={@claims_page.total_entries}
        total_pages={@claims_page.total_pages}
        event="paginate"
      />
    </div>
    """
  end

  attr :portal, :atom, required: true
  attr :claim, :map, default: nil
  attr :form, :map, required: true
  attr :corporates, :list, default: []
  attr :policies, :list, default: []
  attr :employees, :list, default: []
  attr :patient_options, :list, default: []
  attr :selected_policy, :map, default: nil
  attr :document_form, :map, required: true
  attr :documents_page, :map, required: true
  attr :uploads, :map, required: true
  attr :show_upload_modal, :boolean, default: false
  attr :document_requirements, :list, default: []
  attr :claim_statuses, :list, default: []
  attr :current_step, :string, default: "details"
  attr :edit_mode, :boolean, default: false
  attr :minimum_documents, :integer, required: true

  def claim_form(assigns) do
    ~H"""
    <div class="corp-form-card">
      <div class="w-full mb-8 border rounded-lg bg-base-100 shadow-sm flex overflow-hidden">
        <%= for {step_id, step_num, step_name} <- [
          {"details", 1, "Claim Details"},
          {"documents", 2, "Claim Document Upload"}
        ] do %>
          <% is_active = @current_step == step_id %> <% is_completed =
            @claim && step_id == "details" && @current_step == "documents" %>
          <div class={[
            "flex-1 flex items-center justify-center py-4 border-r last:border-r-0",
            is_active && "border-b-2 border-b-blue-500 bg-blue-50/30"
          ]}>
            <div class={[
              "flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold mr-2",
              if(is_active or is_completed,
                do: "bg-blue-500 text-white",
                else: "bg-gray-300 text-gray-600"
              )
            ]}>
              <%= if is_completed do %>
                <.icon name="hero-check" class="w-5 h-5" />
              <% else %>
                {step_num}
              <% end %>
            </div>
            
            <span class={[
              "text-sm",
              if(is_active, do: "text-blue-500 font-semibold", else: "text-gray-600")
            ]}>
              {step_name}
            </span>
          </div>
        <% end %>
      </div>
      
      <%= if @current_step == "details" do %>
        <.form
          for={@form}
          id={"#{@portal}-claim-form"}
          phx-change="validate"
          phx-submit="save"
          class="corp-form-grid"
        >
          <%= if @form.errors != [] do %>
            <div class="col-span-full mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-md">
              <p class="font-bold mb-2">Please correct the highlighted fields.</p>
              
              <ul class="list-disc pl-5">
                <%= for {field, {msg, _}} <- @form.errors do %>
                  <li><strong>{Phoenix.Naming.humanize(field)}:</strong> {msg}</li>
                <% end %>
              </ul>
            </div>
          <% end %>
          
          <%= if @portal == :employee do %>
            <input
              type="hidden"
              name="claim[ref_corporate_id]"
              value={@form[:ref_corporate_id].value || ""}
            />
            <input
              type="hidden"
              name="claim[ref_policy_id]"
              value={@form[:ref_policy_id].value || ""}
            />
            <input
              type="hidden"
              name="claim[employee_code]"
              value={@form[:employee_code].value || ""}
            />
            <div class="corp-field-group">
              <label class="corp-label">Corporate Name <span class="corp-required">*</span></label>
              <input
                type="text"
                class="corp-input"
                value={(@selected_policy && @selected_policy.corporate_name) || ""}
                placeholder="Auto populated from your employee policy"
                readonly
              />
            </div>
            
            <div class="corp-field-group">
              <label class="corp-label">Policy Number <span class="corp-required">*</span></label>
              <input
                type="text"
                class="corp-input"
                value={(@selected_policy && @selected_policy.policy_number) || ""}
                placeholder="Auto populated from selected policy type"
                readonly
              />
            </div>
            
            <div class="corp-field-group">
              <label class="corp-label">Employee Code <span class="corp-required">*</span></label>
              <input
                type="text"
                class="corp-input"
                value={@form[:employee_code].value || ""}
                placeholder="Auto populated from your login"
                readonly
              />
            </div>
          <% else %>
            <div class="corp-field-group">
              <label class="corp-label">Corporate Name <span class="corp-required">*</span></label>
              <select
                name="claim[ref_corporate_id]"
                class="corp-input"
                required
                disabled={readonly_field?(@claim, :ref_corporate_id)}
              >
                <option value="">Select Corporate Name</option>
                
                <%= for corporate <- @corporates do %>
                  <option
                    value={corporate.corporate_id}
                    selected={
                      to_string(@form[:ref_corporate_id].value || "") ==
                        to_string(corporate.corporate_id)
                    }
                  >
                    {corporate.corporate_name}
                  </option>
                <% end %>
              </select>
            </div>
            
            <div class="corp-field-group">
              <label class="corp-label">Policy Number <span class="corp-required">*</span></label>
              <select
                name="claim[ref_policy_id]"
                class="corp-input"
                required
                disabled={
                  readonly_field?(@claim, :ref_policy_id) or
                    @form[:ref_corporate_id].value in [nil, ""]
                }
              >
                <option value="">Select Policy Number</option>
                
                <%= for policy <- @policies do %>
                  <option
                    value={policy.id}
                    selected={to_string(@form[:ref_policy_id].value || "") == to_string(policy.id)}
                  >
                    {Claims.policy_option_label(policy)}
                  </option>
                <% end %>
              </select>
            </div>
            
            <div class="corp-field-group">
              <label class="corp-label">Employee Code <span class="corp-required">*</span></label>
              <select
                name="claim[employee_code]"
                class="corp-input"
                required
                disabled={
                  readonly_field?(@claim, :employee_code) or @form[:ref_policy_id].value in [nil, ""]
                }
              >
                <option value="">Select Employee Code</option>
                
                <%= for employee <- @employees do %>
                  <option
                    value={employee.employee_code}
                    selected={
                      StringUtils.equal?(@form[:employee_code].value || "", employee.employee_code)
                    }
                  >
                    {employee.employee_code}
                  </option>
                <% end %>
              </select>
            </div>
          <% end %>
          
          <div class="corp-field-group">
            <label class="corp-label">Patient Name <span class="corp-required">*</span></label>
            <select
              name="claim[patient_name]"
              class="corp-input"
              required
              disabled={
                readonly_field?(@claim, :patient_name) or
                  (@portal == :employee and is_nil(@selected_policy)) or
                  @form[:employee_code].value in [nil, ""]
              }
            >
              <option value="">
                {if @portal == :employee,
                  do: "Select covered member",
                  else: "Select Patient Name"}
              </option>
              
              <%= for patient <- @patient_options do %>
                <option
                  value={patient.employee_name}
                  selected={
                    StringUtils.equal?(@form[:patient_name].value || "", patient.employee_name)
                  }
                >
                  {patient.employee_name} ({patient.relationship})
                </option>
              <% end %>
            </select>
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Reason for Claim <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[claim_reason]"
              value={@form[:claim_reason].value || ""}
              class="corp-input"
              placeholder="Enter reason for claim"
              required
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Estimated / Claim Amount (₹)
            <span class="corp-required">*</span></label>
            <input
              type="number"
              min="0"
              step="0.01"
              name="claim[estimated_amount]"
              value={@form[:estimated_amount].value || ""}
              class="corp-input"
              placeholder="e.g. 50000"
              required
              readonly={readonly_field?(@claim, :estimated_amount)}
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Hospitalization Date <span class="corp-required">*</span></label>
            <div class="corp-input-with-icon">
              <input
                id={"#{@portal}-hospitalization-date"}
                type="date"
                name="claim[hospitalization_date]"
                value={@form[:hospitalization_date].value || ""}
                class="corp-input"
                required
              />
              <button
                type="button"
                id={"#{@portal}-hospitalization-date-trigger"}
                class="corp-date-trigger"
                phx-hook="DatePickerTrigger"
                data-input-id={"#{@portal}-hospitalization-date"}
                aria-label="Open hospitalization date picker"
              >
                <.icon name="hero-calendar-days" class="corp-date-trigger-icon" />
              </button>
            </div>
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Discharge Date <span class="corp-required">*</span></label>
            <div class="corp-input-with-icon">
              <input
                id={"#{@portal}-discharge-date"}
                type="date"
                name="claim[discharge_date]"
                value={@form[:discharge_date].value || ""}
                min={next_discharge_date(@form[:hospitalization_date].value)}
                class="corp-input"
                required
              />
              <button
                type="button"
                id={"#{@portal}-discharge-date-trigger"}
                class="corp-date-trigger"
                phx-hook="DatePickerTrigger"
                data-input-id={"#{@portal}-discharge-date"}
                aria-label="Open discharge date picker"
              >
                <.icon name="hero-calendar-days" class="corp-date-trigger-icon" />
              </button>
            </div>
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Name of the Hospital <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[hospital_name]"
              value={@form[:hospital_name].value || ""}
              class="corp-input"
              placeholder="Enter hospital name"
              required
            />
          </div>
          
          <div class="corp-field-group corp-field-group--full">
            <label class="corp-label">Hospital Address <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[hospital_address]"
              value={@form[:hospital_address].value || ""}
              class="corp-input"
              placeholder="Hospital address"
              required
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">City <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[city]"
              value={@form[:city].value || ""}
              class="corp-input"
              placeholder="City"
              required
              readonly
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">State <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[state]"
              value={@form[:state].value || ""}
              class="corp-input"
              placeholder="State"
              required
              readonly
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Pincode <span class="corp-required">*</span></label>
            <input
              type="text"
              name="claim[pincode]"
              value={@form[:pincode].value || ""}
              class="corp-input"
              placeholder="Pincode"
              required
              inputmode="numeric"
              pattern="[0-9]{6}"
              maxlength="6"
            />
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Claim Type <span class="corp-required">*</span></label>
            <select name="claim[claim_type]" class="corp-input" required>
              <option value="">Select Claim Type</option>
              
              <%= for type <- ["Cashless", "Reimbursement"] do %>
                <option value={type} selected={StringUtils.equal?(@form[:claim_type].value, type)}>
                  {type}
                </option>
              <% end %>
            </select>
          </div>
          
          <div class="corp-field-group">
            <label class="corp-label">Claim Status</label>
            <select name="claim[claim_status]" class="corp-input">
              <%= for status <- @claim_statuses do %>
                <option
                  value={status}
                  selected={StringUtils.equal?(@form[:claim_status].value, status)}
                >
                  {status}
                </option>
              <% end %>
            </select>
          </div>
          
          <div class="corp-field-group corp-field-group--full">
            <label class="corp-label">Treatment Details</label> <textarea
              name="claim[treatment_details]"
              class="corp-input min-h-28"
              placeholder="Enter treatment details"
            >{@form[:treatment_details].value || ""}</textarea>
          </div>
          
          <div class="corp-field-group corp-field-group--full">
            <label class="corp-label">Remarks</label> <textarea
              name="claim[remarks]"
              class="corp-input min-h-28"
              placeholder="Enter any additional remarks"
            >{@form[:remarks].value || ""}</textarea>
          </div>
          
          <div class="corp-field-group corp-field-group--full corp-form-actions">
            <.link
              navigate={
                policy_aware_path(
                  @portal,
                  "/claims-submission",
                  @selected_policy && @selected_policy.id
                )
              }
              class="btn btn-secondary"
            >
              Cancel
            </.link>
            
            <button type="submit" class="btn btn-success employee-primary-action">
              <.icon name="hero-check" class="w-4 h-4 mr-1" /> {if @claim,
                do: "Save Claim",
                else: "Save & Next"}
            </button>
          </div>
        </.form>
      <% else %>
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-semibold">Claim Document Upload</h2>
              
              <p class="text-sm text-gray-500 mt-1">
                Upload at least {@minimum_documents} supporting documents before submitting the claim.
              </p>
            </div>
            
            <div class="flex gap-2">
              <button
                type="button"
                phx-click="open_upload_modal"
                class="btn btn-success employee-primary-action"
              >
                <.icon name="hero-arrow-up-tray" class="w-4 h-4 mr-1" /> Upload Document
              </button>
            </div>
          </div>
          
          <div class="corp-table-card">
            <div class="overflow-x-auto">
              <table class="corp-table">
                <thead>
                  <tr>
                    <th class="corp-th">SI NO</th>
                    
                    <th class="corp-th">Document Name</th>
                    
                    <th class="corp-th">Attachment Copy</th>
                    
                    <th class="corp-th">Created At</th>
                    
                    <th class="corp-th text-right">Action</th>
                  </tr>
                </thead>
                
                <tbody>
                  <%= if @documents_page.entries == [] do %>
                    <tr class="corp-empty-row">
                      <td colspan="5" class="corp-empty-cell">
                        <div class="corp-empty-state">
                          <.icon name="hero-paper-clip" class="w-12 h-12 text-gray-300 mb-3" />
                          <p class="corp-empty-text">No claim documents uploaded yet</p>
                        </div>
                      </td>
                    </tr>
                  <% else %>
                    <%= for {document, index} <- Enum.with_index(@documents_page.entries, 1) do %>
                      <tr class="corp-tr">
                        <td class="corp-td">
                          {(@documents_page.page - 1) * @documents_page.page_size + index}
                        </td>
                        
                        <td class="corp-td">{document.document_name}</td>
                        
                        <td class="corp-td">
                          <a
                            href={static_upload_path(document.file_path)}
                            target="_blank"
                            class="text-blue-600 hover:underline"
                          >
                            Download Attachment
                          </a>
                        </td>
                        
                        <td class="corp-td">{format_datetime(document.inserted_at)}</td>
                        
                        <td class="corp-td">
                          <div class="corp-actions justify-end">
                            <button
                              type="button"
                              phx-click="confirm_delete_document"
                              phx-value-id={document.id}
                              class="corp-action-btn-text corp-action-btn-text--delete"
                            >
                              Delete
                            </button>
                          </div>
                        </td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>
            
            <.pagination
              page={@documents_page.page}
              page_size={@documents_page.page_size}
              total_entries={@documents_page.total_entries}
              total_pages={@documents_page.total_pages}
              event="paginate_documents"
            />
          </div>
          
          <div class="flex justify-end gap-4 mt-6">
            <button type="button" phx-click="back_to_details" class="btn btn-secondary">Previous</button>
            <button
              type="button"
              phx-click="submit_claim"
              class="btn btn-success employee-primary-action"
            >
              Complete
            </button>
          </div>
        </div>
      <% end %>
      
      <%= if @show_upload_modal do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div class="w-full max-w-2xl rounded-2xl bg-white p-6 shadow-2xl">
            <div class="space-y-4">
              <div class="flex items-start justify-between gap-4">
                <div>
                  <h3 class="text-lg font-semibold">Upload Claim Document</h3>
                  
                  <p class="text-sm text-gray-500">
                    Allowed types: PDF, PNG, JPG, JPEG. Maximum size: 8 MB per file.
                  </p>
                </div>
                
                <button
                  type="button"
                  phx-click="close_upload_modal"
                  class="text-gray-400 transition hover:text-gray-600"
                >
                  <.icon name="hero-x-mark" class="w-5 h-5" />
                </button>
              </div>
              
              <.form
                for={@document_form}
                id={"#{@portal}-claim-document-form"}
                phx-submit="save_document"
                class="space-y-4"
              >
                <div>
                  <label class="corp-label">Document Type <span class="corp-required">*</span></label>
                  <select name="document[document_name]" class="corp-input" required>
                    <option value="">Select document type</option>
                    
                    <%= for name <- @document_requirements do %>
                      <option value={name} selected={@document_form[:document_name].value == name}>
                        {name}
                      </option>
                    <% end %>
                  </select>
                </div>
                
                <div>
                  <label class="corp-label">Attach Document <span class="corp-required">*</span></label>
                  <div
                    class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center"
                    phx-drop-target={@uploads.claim_document.ref}
                  >
                    <.live_file_input
                      upload={@uploads.claim_document}
                      id={@uploads.claim_document.ref}
                      class="upload-file-input"
                    />
                    <label
                      for={@uploads.claim_document.ref}
                      class="upload-btn"
                    >
                      <.icon name="hero-arrow-up-tray" class="w-4 h-4" /> Click to upload
                    </label>
                  </div>
                  
                  <%= for entry <- @uploads.claim_document.entries do %>
                    <div class="flex justify-between items-center bg-white p-3 rounded border mt-3">
                      <span class="text-sm text-gray-700">{entry.client_name}</span>
                      <button
                        type="button"
                        phx-click="remove_upload_entry"
                        phx-value-ref={entry.ref}
                        class="text-red-500 hover:text-red-700"
                      >
                        Cancel
                      </button>
                    </div>
                  <% end %>
                </div>
                
                <div class="corp-form-actions">
                  <button type="button" phx-click="close_upload_modal" class="btn btn-secondary">Cancel</button>
                  <button
                    type="submit"
                    class="btn btn-success employee-primary-action"
                    disabled={Enum.empty?(@uploads.claim_document.entries)}
                  >
                    Upload
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  attr :status, :string, required: true

  def status_badge(assigns) do
    ~H"""
    <span class={MasterClaimSubmission.status_badge_class(@status)}>{@status}</span>
    """
  end

  def readonly_field?(nil, _field), do: false

  def readonly_field?(_claim, field),
    do:
      field in [
        :ref_corporate_id,
        :ref_policy_id,
        :employee_code,
        :patient_name,
        :estimated_amount
      ]

  def static_upload_path(path) when is_binary(path) do
    "/#{path |> String.replace("\\", "/") |> String.trim_leading("/")}"
  end

  def portal_path(:admin, suffix), do: "/admin#{suffix}"
  def portal_path(:corporate, suffix), do: "/corporate#{suffix}"
  def portal_path(:employee, suffix), do: "/employee#{suffix}"

  def policy_aware_path(:employee, suffix, policy_id) when is_integer(policy_id),
    do: "#{portal_path(:employee, suffix)}?policy_id=#{policy_id}"

  def policy_aware_path(portal, suffix, _policy_id), do: portal_path(portal, suffix)

  def portal_label(:admin), do: "Admin Portal"
  def portal_label(:corporate), do: "Corporate Portal"
  def portal_label(:employee), do: "Employee Portal"

  defp format_date(nil), do: "-"
  defp format_date(%Date{} = date), do: Calendar.strftime(date, "%d-%m-%Y")

  defp format_datetime(nil), do: "-"
  defp format_datetime(%DateTime{} = datetime), do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp format_datetime(%NaiveDateTime{} = datetime),
    do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp tab_class(true), do: "px-4 py-3 border-b-2 border-blue-500 text-blue-600 font-semibold"

  defp tab_class(false),
    do: "px-4 py-3 border-b-2 border-transparent text-gray-500 hover:text-gray-700"

  defp sortable_link(assigns, label, field) do
    direction =
      if assigns.claims_page.sort_by == field and assigns.claims_page.sort_dir == "asc",
        do: "desc",
        else: "asc"

    assigns =
      assign(assigns,
        sortable_label: label,
        sortable_field: field,
        sortable_dir: direction
      )

    ~H"""
    <button
      type="button"
      phx-click="sort"
      phx-value-field={@sortable_field}
      phx-value-direction={@sortable_dir}
      class="corp-sort-button"
    >
      {@sortable_label} <.icon name="hero-arrows-up-down" class="w-4 h-4 text-gray-400" />
    </button>
    """
  end

  defp next_discharge_date(nil), do: nil
  defp next_discharge_date(""), do: nil

  defp next_discharge_date(%Date{} = hospitalization_date) do
    hospitalization_date
    |> Date.add(1)
    |> Date.to_iso8601()
  end

  defp next_discharge_date(hospitalization_date) when is_binary(hospitalization_date) do
    case Date.from_iso8601(hospitalization_date) do
      {:ok, date} -> next_discharge_date(date)
      _ -> nil
    end
  end
end
