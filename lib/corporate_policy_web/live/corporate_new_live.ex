defmodule CorporatePolicyWeb.CorporateNewLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> Accounts.get_user(id)
      end

    group_code = Corporates.generate_group_code()

    changeset =
      Corporates.change_corporate(%CorporatePolicy.Corporates.Corporate{}, %{
        corporate_group_code: group_code,
        corporate_status: 1
      })

    socket =
      socket
      |> assign(:page_title, "Add Corporate")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/corporate/new")
      |> assign(:tab, :details)
      |> assign(:group_code, group_code)
      |> assign(:form, Phoenix.Component.to_form(changeset, as: :corporate))
      |> assign(:contacts, [%{id: Ecto.UUID.generate()}])
      |> assign(:saved_corporate_id, nil)
      |> assign(:details_params, %{})
      |> allow_upload(:logo,
        accept: ~w(.jpg .jpeg .png .gif .webp),
        max_entries: 1,
        max_file_size: 2_097_152
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-form-page" id="corp-form-page">
        <div class="corp-form-header">
          <h1 class="corp-form-title">Corporate Details</h1>
        </div>

        <%!-- Tab Steps --%>
        <div class="form-tabs" id="form-tabs">
          <div class={["tab-step", @tab == :details && "tab-step--active"]} id="tab-step-details">
            <div class="tab-step-number">1</div>
            <span class="tab-step-label">Corporate Details</span>
          </div>
          <div class="tab-step-divider"></div>
          <div class={["tab-step", @tab == :contacts && "tab-step--active"]} id="tab-step-contacts">
            <div class="tab-step-number">2</div>
            <span class="tab-step-label">Corporate Contacts</span>
          </div>
        </div>

        <%!-- Form card --%>
        <div class="corp-form-card" id="corp-form-card">
          <.form
            for={@form}
            id="corporate-form"
            phx-change="validate"
            phx-submit="save"
          >
            <%!-- Tab 1: Corporate Details --%>
            <div class={@tab != :details && "hidden"}>
              <div class="corp-form-grid" id="corp-tab-details">
                <%!-- Row 1 --%>
                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_corporate_name">
                    Corporate Name <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:corporate_name]}
                    type="text"
                    placeholder="Corporate Name"
                    class="corp-input"
                    id="corporate_corporate_name"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_pincode">
                    Pincode <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:pincode]}
                    type="text"
                    placeholder="Pincode"
                    class="corp-input"
                    id="corporate_pincode"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_city">
                    City <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:city]}
                    type="text"
                    placeholder="City"
                    class="corp-input"
                    id="corporate_city"
                  />
                </div>

                <%!-- Row 2 --%>
                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_state">
                    State <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:state]}
                    type="text"
                    placeholder="State"
                    class="corp-input"
                    id="corporate_state"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_corporate_address">
                    Corporate Address <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:corporate_address]}
                    type="text"
                    placeholder="Corporate Address"
                    class="corp-input"
                    id="corporate_corporate_address"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_pan_number">
                    PAN Number <span class="corp-required">*</span>
                  </label>
                  <.input
                    field={@form[:pan_number]}
                    type="text"
                    placeholder="PAN Number"
                    class="corp-input"
                    id="corporate_pan_number"
                  />
                </div>

                <%!-- Row 3 --%>
                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_group_code">
                    Group Code
                  </label>
                  <input
                    type="text"
                    id="corporate_group_code"
                    name="corporate[corporate_group_code]"
                    value={@group_code}
                    readonly
                    class="corp-input corp-input--readonly"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_corporate_landline">
                    Corporate Landline
                  </label>
                  <.input
                    field={@form[:corporate_landline]}
                    type="text"
                    placeholder="Corporate Landline"
                    class="corp-input"
                    id="corporate_corporate_landline"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_coporate_contact_email">
                    Corporate Email Address
                  </label>
                  <.input
                    field={@form[:coporate_contact_email]}
                    type="email"
                    placeholder="Corporate Email Address"
                    class="corp-input"
                    id="corporate_coporate_contact_email"
                  />
                </div>

                <%!-- Row 4 --%>
                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_industry_type">
                    Industry Type
                  </label>
                  <.input
                    field={@form[:industry_type]}
                    type="text"
                    placeholder="Enter Industry Type"
                    class="corp-input"
                    id="corporate_industry_type"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_branch_name">
                    Service Branch Name
                  </label>
                  <.input
                    field={@form[:branch_name]}
                    type="text"
                    placeholder="Service Branch Name"
                    class="corp-input"
                    id="corporate_branch_name"
                  />
                </div>

                <div class="corp-field-group">
                  <label class="corp-label" for="corporate_helpline_no">
                    Vibe Helpline Number
                  </label>
                  <.input
                    field={@form[:helpline_no]}
                    type="text"
                    placeholder="Vibe Helpline Number"
                    class="corp-input"
                    id="corporate_helpline_no"
                  />
                </div>

                <%!-- Logo Upload — spans full row --%>
                <div class="corp-field-group corp-field-group--full" id="logo-upload-group">
                  <label class="corp-label">Corporate Logo</label>
                  <div class="upload-area" id="logo-upload-area" phx-drop-target={@uploads.logo.ref}>
                    <.live_file_input upload={@uploads.logo} class="upload-file-input" />
                    <label for={@uploads.logo.ref} class="upload-btn" id="logo-upload-btn">
                      <.icon name="hero-arrow-up-tray" class="w-4 h-4" /> Click to Upload
                    </label>
                    <p class="upload-hint">(Max file size: 2MB)</p>

                    <%!-- Preview uploaded entries --%>
                    <%= for entry <- @uploads.logo.entries do %>
                      <div class="upload-preview" id={"upload-preview-#{entry.ref}"}>
                        <.live_img_preview entry={entry} class="upload-img-preview" />
                        <span class="upload-filename">{entry.client_name}</span>
                        <button
                          type="button"
                          phx-click="cancel_upload"
                          phx-value-ref={entry.ref}
                          class="upload-cancel"
                          id={"cancel-upload-#{entry.ref}"}
                        >
                          <.icon name="hero-x-mark" class="w-4 h-4" />
                        </button>
                      </div>
                      <%= for err <- upload_errors(@uploads.logo, entry) do %>
                        <p class="upload-error">{upload_error_to_string(err)}</p>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              </div>

              <div class="corp-form-footer" id="corp-footer-details">
                <button type="submit" name="action" value="next" class="btn-primary" id="btn-next">
                  Next
                </button>
              </div>
            </div>

            <%!-- Tab 2: Corporate Contacts --%>
            <div class={@tab != :contacts && "hidden"}>
              <div id="corp-tab-contacts">
                <%= for {contact, idx} <- Enum.with_index(@contacts) do %>
                  <div class="contact-block" id={"contact-block-#{idx}"} phx-update="ignore">
                    <input type="hidden" name={"corporate[contacts][#{idx}][id]"} value={contact.id} />

                    <div class="corp-field-group">
                      <label class="corp-label">Full Name <span class="corp-required">*</span></label>
                      <input
                        type="text"
                        name={"corporate[contacts][#{idx}][full_name]"}
                        placeholder="Full Name"
                        class="corp-input"
                        value={Map.get(contact, :full_name, "")}
                      />
                    </div>

                    <div class="corp-field-group">
                      <label class="corp-label">Mobile Number <span class="corp-required">*</span></label>
                      <input
                        type="text"
                        name={"corporate[contacts][#{idx}][mobile_number]"}
                        placeholder="Mobile Number"
                        class="corp-input"
                        value={Map.get(contact, :mobile_number, "")}
                      />
                    </div>

                    <div class="corp-field-group">
                      <label class="corp-label">Email Address <span class="corp-required">*</span></label>
                      <input
                        type="email"
                        name={"corporate[contacts][#{idx}][email_address]"}
                        placeholder="Email Address"
                        class="corp-input"
                        value={Map.get(contact, :email_address, "")}
                      />
                    </div>

                    <div class="corp-field-group">
                      <label class="corp-label">Corporate Username
                      <span class="corp-required">*</span></label>
                      <input
                        type="text"
                        name={"corporate[contacts][#{idx}][corporate_username]"}
                        placeholder="Corporate Username"
                        class="corp-input"
                        value={Map.get(contact, :corporate_username, "")}
                      />
                    </div>

                    <div class="corp-field-group">
                      <label class="corp-label">Department <span class="corp-required">*</span></label>
                      <input
                        type="text"
                        name={"corporate[contacts][#{idx}][department]"}
                        placeholder="Department"
                        class="corp-input"
                        value={Map.get(contact, :department, "")}
                      />
                    </div>

                    <div class="corp-field-group contact-location-group">
                      <label class="corp-label">Location/Division <span class="corp-required">*</span></label>
                      <div class="location-delete-wrapper">
                        <input
                          type="text"
                          name={"corporate[contacts][#{idx}][location]"}
                          placeholder="Location/Division"
                          class="corp-input"
                          value={Map.get(contact, :location, "")}
                        />
                        <%= if length(@contacts) > 1 do %>
                          <button
                            type="button"
                            class="btn-delete-contact"
                            phx-click="remove_contact"
                            phx-value-index={idx}
                            data-confirm="Are you sure you want to delete this contact?"
                          >Delete</button>
                        <% end %>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>

              <div class="corp-add-contact-wrapper mt-4">
                <button type="button" class="btn-add-user" phx-click="add_contact">Add New User</button>
              </div>

              <div class="corp-form-footer" id="corp-footer-contacts">
                <button type="button" phx-click="prev_tab" class="btn-secondary" id="btn-back">
                  Back
                </button>
                <button type="submit" name="action" value="submit" class="btn-primary" id="btn-submit">
                  Submit
                </button>
              </div>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  @impl true
  def handle_event("validate", %{"corporate" => params}, socket) do
    # Contacts are managed separately; only validate corporate fields
    corporate_params = Map.drop(params, ["contacts"])

    changeset =
      %CorporatePolicy.Corporates.Corporate{}
      |> CorporatePolicy.Corporates.Corporate.changeset(corporate_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: Phoenix.Component.to_form(changeset, as: :corporate))}
  end

  def handle_event("add_contact", _params, socket) do
    new_contact = %{id: Ecto.UUID.generate()}
    {:noreply, assign(socket, :contacts, socket.assigns.contacts ++ [new_contact])}
  end

  def handle_event("remove_contact", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    updated = List.delete_at(socket.assigns.contacts, index)
    {:noreply, assign(socket, :contacts, updated)}
  end

  def handle_event("prev_tab", _params, socket) do
    {:noreply, assign(socket, :tab, :details)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  # ─── Save: handles both Next (save corporate) and Submit (save contacts) ─────

  def handle_event("save", %{"action" => "next", "corporate" => params}, socket) do
    corporate_params = Map.drop(params, ["contacts"])

    changeset =
      %CorporatePolicy.Corporates.Corporate{}
      |> Corporates.change_corporate(corporate_params)

    if changeset.valid? do
      entries = socket.assigns.uploads.logo.entries

      has_upload_errors? =
        not Enum.empty?(upload_errors(socket.assigns.uploads.logo)) or
          Enum.any?(entries, fn entry ->
            not Enum.empty?(upload_errors(socket.assigns.uploads.logo, entry))
          end)

      cond do
        has_upload_errors? ->
          {:noreply,
           socket
           |> put_flash(:error, "Logo upload failed")
           |> assign(form: Phoenix.Component.to_form(changeset, as: :corporate))}

        true ->
          try do
            logo_path =
              if entries != [] do
                consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
                  ext = Path.extname(entry.client_name)
                  filename = "#{Ecto.UUID.generate()}#{ext}"

                  # Save locally in project root
                  dest_source = Path.join(["priv", "static", "uploads", "logos", filename])
                  File.mkdir_p!(Path.dirname(dest_source))
                  File.cp!(path, dest_source)

                  # Save to build output
                  dest_compiled =
                    Path.join([
                      :code.priv_dir(:corporate_policy),
                      "static",
                      "uploads",
                      "logos",
                      filename
                    ])

                  File.mkdir_p!(Path.dirname(dest_compiled))
                  File.cp!(path, dest_compiled)

                  {:ok, "/uploads/logos/" <> filename}
                end)
                |> List.first()
              else
                nil
              end

            case Corporates.create_corporate(corporate_params, logo_path) do
              {:ok, corporate} ->
                {:noreply,
                 socket
                 |> assign(:saved_corporate_id, corporate.corporate_id)
                 |> assign(:tab, :contacts)}

              {:error, failed_changeset} ->
                {:noreply,
                 socket
                 |> put_flash(:error, "Please fix the errors below.")
                 |> assign(form: Phoenix.Component.to_form(failed_changeset, as: :corporate))}
            end
          rescue
            _exception ->
              {:noreply,
               socket
               |> put_flash(:error, "Logo upload failed")
               |> assign(form: Phoenix.Component.to_form(changeset, as: :corporate))}
          end
      end
    else
      failed_changeset = Map.put(changeset, :action, :next)

      {:noreply,
       socket
       |> put_flash(:error, "Please fix the errors below.")
       |> assign(form: Phoenix.Component.to_form(failed_changeset, as: :corporate))}
    end
  end

  def handle_event("save", %{"action" => "submit", "corporate" => params}, socket) do
    case socket.assigns.saved_corporate_id do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Please complete corporate details first.")
         |> assign(:tab, :details)}

      corporate_id ->
        contacts_params =
          params
          |> Map.get("contacts", %{})
          |> Enum.sort_by(fn {idx, _} -> String.to_integer(idx) end)
          |> Enum.map(fn {_idx, c} -> c end)

        case Corporates.save_contacts(corporate_id, contacts_params) do
          {:ok, _users} ->
            {:noreply,
             socket
             |> put_flash(:info, "Corporate created successfully!")
             |> push_navigate(to: ~p"/admin/corporate")}

          {:error, failed_changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Please fix the contact errors below.")
             |> assign(form: Phoenix.Component.to_form(failed_changeset, as: :corporate))}
        end
    end
  end

  defp upload_error_to_string(:too_large), do: "File is too large (max 2MB)"

  defp upload_error_to_string(:not_accepted),
    do: "Invalid file type. Allowed: jpg, jpeg, png, gif, webp"

  defp upload_error_to_string(:too_many_files), do: "Only one logo allowed"
  defp upload_error_to_string(_), do: "Upload error"
end
