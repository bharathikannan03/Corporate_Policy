defmodule CorporatePolicyWeb.ClaimSubmissionFormLive do
  alias CorporatePolicy.Claims
  alias CorporatePolicy.Claims.MasterClaimSubmission
  alias CorporatePolicy.StringUtils

  defmacro __using__(opts) do
    portal = Keyword.fetch!(opts, :portal)

    quote do
      use CorporatePolicyWeb, :live_view

      import CorporatePolicyWeb.ClaimSubmissionComponents

      @portal unquote(portal)

      @impl true
      def mount(params, session, socket) do
        current_user =
          case session["current_user_id"] do
            nil -> socket.assigns[:current_user]
            id -> CorporatePolicy.Accounts.get_user(id)
          end

        claim =
          case socket.assigns.live_action do
            :edit -> Claims.get_claim_with_details!(params["id"])
            _ -> nil
          end

        form_params =
          if claim, do: claim_to_params(claim), else: default_claim_params(current_user)

        document_form = to_form(%{"document_name" => ""}, as: :document)

        socket =
          socket
          |> assign(:portal, @portal)
          |> assign(:current_user, current_user)
          |> assign(
            :page_title,
            if(claim, do: "Edit Claim Submission", else: "Add Claim Submission")
          )
          |> assign(:active_path, portal_path(@portal, "/claims-submission/add"))
          |> assign(:claim, claim)
          |> assign(
            :current_step,
            if(claim && StringUtils.equal?(params["step"], "documents"),
              do: "documents",
              else: "details"
            )
          )
          |> assign(:claim_statuses, Claims.claim_statuses())
          |> assign(:document_requirements, Claims.document_requirements())
          |> assign(:show_upload_modal, false)
          |> assign(:minimum_documents, Claims.min_documents())
          |> assign(:document_form, document_form)
          |> assign(:last_pincode, form_params["pincode"])
          |> assign(:form_params, form_params)
          |> assign(:documents, if(claim, do: Claims.list_claim_documents(claim.id), else: []))
          |> allow_upload(:claim_document,
            accept: Claims.allowed_extensions(),
            max_entries: 1,
            max_file_size: Claims.max_upload_size()
          )
          |> sync_documents_page()
          |> load_reference_data()
          |> sync_form()

        {:ok, socket}
      end

      @impl true
      def handle_event("validate", %{"claim" => claim_params}, socket) do
        {merged_params, last_pincode} =
          merge_and_derive(
            socket.assigns.form_params,
            claim_params,
            socket.assigns[:last_pincode]
          )

        socket =
          socket
          |> assign(:form_params, merged_params)
          |> assign(:last_pincode, last_pincode)
          |> load_reference_data()
          |> sync_form()

        {:noreply, socket}
      end

      def handle_event("save", %{"claim" => claim_params}, socket) do
        {attrs, _last_pincode} =
          merge_and_derive(
            socket.assigns.form_params,
            claim_params,
            socket.assigns[:last_pincode]
          )

        case save_claim(socket.assigns.claim, attrs, socket.assigns.current_user) do
          {:ok, claim} ->
            next_path =
              case socket.assigns.claim do
                nil ->
                  portal_path(@portal, "/claims-submission/#{claim.id}/edit?step=documents")

                _ ->
                  portal_path(
                    @portal,
                    "/claims-submission/#{claim.id}/edit?step=#{socket.assigns.current_step}"
                  )
              end

            {:noreply,
             socket
             |> put_flash(
               :info,
               if(socket.assigns.claim,
                 do: "Claim updated successfully.",
                 else: "Claim saved successfully."
               )
             )
             |> push_navigate(to: next_path)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: :claim))}
        end
      end

      def handle_event("open_upload_modal", _params, socket) do
        {:noreply, assign(socket, :show_upload_modal, true)}
      end

      def handle_event("close_upload_modal", _params, socket) do
        {:noreply, assign(socket, :show_upload_modal, false)}
      end

      def handle_event("paginate_documents", %{"page" => page}, socket) do
        {:noreply, sync_documents_page(socket, page)}
      end

      def handle_event("remove_upload_entry", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :claim_document, ref)}
      end

      def handle_event("save_document", %{"document" => %{"document_name" => ""}}, socket) do
        {:noreply, put_flash(socket, :error, "Please select a document type.")}
      end

      def handle_event(
            "save_document",
            %{"document" => %{"document_name" => document_name}},
            socket
          ) do
        claim = socket.assigns.claim

        uploaded_files =
          consume_uploaded_entries(socket, :claim_document, fn %{path: path}, entry ->
            relative_path =
              Path.join(["uploads", "claims", to_string(claim.id), upload_filename(entry)])

            destination = Path.join(["priv", "static", relative_path])
            File.mkdir_p!(Path.dirname(destination))
            File.cp!(path, destination)

            {:ok,
             %{
               "document_name" => document_name,
               "original_file_name" => entry.client_name,
               "file_path" => relative_path,
               "mime_type" => entry.client_type,
               "file_size" => entry.client_size
             }}
          end)

        case uploaded_files do
          [attrs] ->
            case Claims.create_claim_document(claim, attrs, socket.assigns.current_user, @portal) do
              {:ok, _document} ->
                {:noreply,
                 socket
                 |> assign(:documents, Claims.list_claim_documents(claim.id))
                 |> assign(:document_form, to_form(%{"document_name" => ""}, as: :document))
                 |> assign(:show_upload_modal, false)
                 |> sync_documents_page()
                 |> put_flash(:info, "Document uploaded successfully.")}

              {:error, %Ecto.Changeset{} = changeset} ->
                {:noreply, put_flash(socket, :error, format_changeset_errors(changeset))}
            end

          _ ->
            {:noreply, put_flash(socket, :error, "Please attach a valid document file.")}
        end
      end

      def handle_event("confirm_delete_document", %{"id" => id}, socket) do
        document = Enum.find(socket.assigns.documents, &(to_string(&1.id) == id))

        if document do
          case Claims.delete_claim_document(
                 document,
                 socket.assigns.claim,
                 socket.assigns.current_user,
                 @portal
               ) do
            {:ok, _deleted} ->
              {:noreply,
               socket
               |> assign(:documents, Claims.list_claim_documents(socket.assigns.claim.id))
               |> sync_documents_page()
               |> put_flash(:info, "Document deleted successfully.")}

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, "Unable to delete the selected document.")}
          end
        else
          {:noreply, socket}
        end
      end

      def handle_event("submit_claim", _params, socket) do
        case Claims.submit_claim(socket.assigns.claim, socket.assigns.current_user, @portal) do
          {:ok, claim} ->
            {:noreply,
             socket
             |> assign(:claim, claim)
             |> put_flash(:info, "Claim submitted successfully.")
             |> push_navigate(to: portal_path(@portal, "/claims-submission"))}

          {:error, :minimum_documents_not_met} ->
            {:noreply,
             put_flash(
               socket,
               :error,
               "Upload at least #{Claims.min_documents()} documents before submitting the claim."
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, put_flash(socket, :error, format_changeset_errors(changeset))}
        end
      end

      def handle_event("back_to_details", _params, socket) do
        {:noreply, assign(socket, :current_step, "details")}
      end

      @impl true
      def render(var!(assigns)) do
        ~H"""
        <%= if @portal == :admin do %>
          <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
            <.portal_shell
              portal={@portal}
              current_user={@current_user}
              page_title={@page_title}
              active_path={@active_path}
            >
              <.claim_form
                portal={@portal}
                claim={@claim}
                form={@form}
                corporates={@corporates}
                policies={@policies}
                employees={@employees}
                patient_options={@patient_options}
                document_form={@document_form}
                documents_page={@documents_page}
                uploads={@uploads}
                show_upload_modal={@show_upload_modal}
                document_requirements={@document_requirements}
                claim_statuses={@claim_statuses}
                current_step={@current_step}
                edit_mode={@claim != nil}
                minimum_documents={@minimum_documents}
              />
            </.portal_shell>
          </Layouts.admin>
        <% else %>
          <Layouts.app flash={@flash}>
            <div class="p-6">
              <.portal_shell
                portal={@portal}
                current_user={@current_user}
                page_title={@page_title}
                active_path={@active_path}
              >
                <.claim_form
                  portal={@portal}
                  claim={@claim}
                  form={@form}
                  corporates={@corporates}
                  policies={@policies}
                  employees={@employees}
                  patient_options={@patient_options}
                  document_form={@document_form}
                  documents_page={@documents_page}
                  uploads={@uploads}
                  show_upload_modal={@show_upload_modal}
                  document_requirements={@document_requirements}
                  claim_statuses={@claim_statuses}
                  current_step={@current_step}
                  edit_mode={@claim != nil}
                  minimum_documents={@minimum_documents}
                />
              </.portal_shell>
            </div>
          </Layouts.app>
        <% end %>
        """
      end

      defp save_claim(nil, attrs, current_user),
        do: Claims.create_claim(attrs, current_user, @portal)

      defp save_claim(claim, attrs, current_user),
        do: Claims.update_claim(claim, attrs, current_user, @portal)

      defp load_reference_data(socket) do
        user = socket.assigns.current_user
        claim_params = socket.assigns.form_params
        corporates = Claims.list_accessible_corporates(user, @portal)
        policies = Claims.list_accessible_policies(user, @portal)
        selected_corporate_id = parse_int(claim_params["ref_corporate_id"])
        selected_policy_id = parse_int(claim_params["ref_policy_id"])

        policies =
          if selected_corporate_id,
            do: Enum.filter(policies, &(&1.ref_corporate_id == selected_corporate_id)),
            else: policies

        employees =
          if selected_policy_id, do: Claims.list_policy_employees(selected_policy_id), else: []

        selected_employee_code = claim_params["employee_code"]

        patient_options =
          if selected_policy_id && not StringUtils.blank?(selected_employee_code),
            do: Claims.list_patient_options(selected_policy_id, selected_employee_code),
            else: []

        socket
        |> assign(:corporates, corporates)
        |> assign(:policies, policies)
        |> assign(:employees, employees)
        |> assign(:patient_options, patient_options)
      end

      defp sync_form(socket) do
        params = socket.assigns.form_params
        changeset = Claims.change_claim(socket.assigns.claim || %MasterClaimSubmission{}, params)
        assign(socket, :form, to_form(changeset, as: :claim))
      end

      defp sync_documents_page(socket, page \\ nil) do
        current_page =
          page ||
            if(socket.assigns[:documents_page], do: socket.assigns.documents_page.page, else: 1)

        assign(
          socket,
          :documents_page,
          CorporatePolicyWeb.Pagination.paginate_list(socket.assigns.documents, current_page)
        )
      end

      defp claim_to_params(claim) do
        claim
        |> Map.from_struct()
        |> Map.take([
          :ref_corporate_id,
          :ref_policy_id,
          :employee_code,
          :patient_name,
          :estimated_amount,
          :claim_reason,
          :hospitalization_date,
          :discharge_date,
          :hospital_name,
          :hospital_address,
          :city,
          :state,
          :pincode,
          :claim_type,
          :claim_status,
          :treatment_details,
          :remarks
        ])
        |> Enum.into(%{}, fn {key, value} ->
          value =
            case value do
              %Date{} = date -> Date.to_iso8601(date)
              %Decimal{} = decimal -> Decimal.to_string(decimal)
              _ -> value
            end

          {to_string(key), value}
        end)
      end

      defp default_claim_params(current_user) do
        base = %{"claim_status" => "Draft"}

        if (@portal in [:corporate, :employee] and current_user) && current_user.ref_corporate_id do
          Map.put(base, "ref_corporate_id", current_user.ref_corporate_id)
        else
          base
        end
      end

      defp merge_and_derive(existing, incoming, last_pincode) do
        merged =
          existing
          |> Map.merge(incoming)
          |> reset_dependent_fields(existing)

        selected_policy_id = parse_int(merged["ref_policy_id"])
        employee_code = StringUtils.normalize(merged["employee_code"])
        patient_name = StringUtils.normalize(merged["patient_name"])
        pincode = StringUtils.normalize(Map.get(merged, "pincode", ""))

        patient_options =
          if selected_policy_id && not StringUtils.blank?(employee_code) do
            Claims.list_patient_options(selected_policy_id, employee_code)
          else
            []
          end

        merged =
          merged
          |> maybe_autoselect_patient(patient_options)
          |> maybe_apply_employee_details(selected_policy_id)
          |> enforce_discharge_date_rule()

        {merged, apply_pincode_lookup(merged, pincode, last_pincode)}
        |> then(fn {params, new_last_pincode} ->
          {maybe_apply_location(params, pincode, last_pincode), new_last_pincode}
        end)
      end

      defp reset_dependent_fields(merged, existing) do
        corporate_changed? =
          StringUtils.normalize(Map.get(existing, "ref_corporate_id", "")) !=
            StringUtils.normalize(Map.get(merged, "ref_corporate_id", ""))

        policy_changed? =
          StringUtils.normalize(Map.get(existing, "ref_policy_id", "")) !=
            StringUtils.normalize(Map.get(merged, "ref_policy_id", ""))

        employee_changed? =
          not StringUtils.equal?(
            Map.get(existing, "employee_code", ""),
            Map.get(merged, "employee_code", "")
          )

        merged =
          if corporate_changed? do
            merged
            |> Map.put("ref_policy_id", "")
            |> Map.put("employee_code", "")
            |> Map.put("patient_name", "")
          else
            merged
          end

        merged =
          if policy_changed? do
            merged
            |> Map.put("employee_code", "")
            |> Map.put("patient_name", "")
          else
            merged
          end

        if employee_changed? do
          merged
          |> Map.put("patient_name", "")
          |> Map.put("employee_name", nil)
          |> Map.put("relationship", nil)
        else
          merged
        end
      end

      defp maybe_autoselect_patient(merged, []), do: merged

      defp maybe_autoselect_patient(merged, patient_options) do
        current_patient_name = StringUtils.normalize(Map.get(merged, "patient_name", ""))

        selected_patient =
          cond do
            current_patient_name != "" and
                Enum.any?(
                  patient_options,
                  &StringUtils.equal?(&1.employee_name, current_patient_name)
                ) ->
              Enum.find(
                patient_options,
                &StringUtils.equal?(&1.employee_name, current_patient_name)
              )

            self_patient =
                Enum.find(patient_options, &StringUtils.equal?(&1.relationship, "Self")) ->
              self_patient

            length(patient_options) == 1 ->
              hd(patient_options)

            true ->
              nil
          end

        if selected_patient do
          Map.put(merged, "patient_name", selected_patient.employee_name)
        else
          merged
        end
      end

      defp maybe_apply_employee_details(merged, nil), do: merged

      defp maybe_apply_employee_details(merged, selected_policy_id) do
        employee_code = StringUtils.normalize(Map.get(merged, "employee_code", ""))
        patient_name = StringUtils.normalize(Map.get(merged, "patient_name", ""))

        employee =
          if not StringUtils.blank?(employee_code) && not StringUtils.blank?(patient_name) do
            Claims.get_policy_employee(selected_policy_id, employee_code, patient_name)
          end

        if employee do
          merged
          |> Map.put("employee_name", employee.employee_name)
          |> Map.put("relationship", employee.relationship)
        else
          merged
        end
      end

      defp maybe_apply_location(params, "", _last_pincode) do
        params
        |> Map.put("city", "")
        |> Map.put("state", "")
      end

      defp maybe_apply_location(params, pincode, last_pincode) do
        if pincode == StringUtils.normalize(last_pincode) do
          params
        else
          do_apply_location(params, pincode)
        end
      end

      defp do_apply_location(params, pincode) do
        if String.length(pincode) == 6 do
          case Claims.get_location_by_pincode(pincode) do
            %{city: city, state: state} ->
              params
              |> Map.put("city", city)
              |> Map.put("state", state)

            _ ->
              params
              |> Map.put("city", "")
              |> Map.put("state", "")
          end
        else
          params
          |> Map.put("city", "")
          |> Map.put("state", "")
        end
      end

      defp apply_pincode_lookup(_params, "", _last_pincode), do: ""
      defp apply_pincode_lookup(_params, pincode, _last_pincode), do: pincode

      defp enforce_discharge_date_rule(params) do
        hospitalization_date = Map.get(params, "hospitalization_date", "")
        discharge_date = Map.get(params, "discharge_date", "")

        with {:ok, hospitalization_date} <- Date.from_iso8601(hospitalization_date),
             {:ok, discharge_date} <- Date.from_iso8601(discharge_date),
             true <- Date.compare(discharge_date, hospitalization_date) != :gt do
          Map.put(params, "discharge_date", "")
        else
          _ -> params
        end
      end

      defp parse_int(value) when is_integer(value), do: value

      defp parse_int(value) when is_binary(value) and value != "",
        do: value |> String.trim() |> String.to_integer()

      defp parse_int(_value), do: nil

      defp upload_filename(entry) do
        ext = Path.extname(entry.client_name)
        "#{entry.uuid}#{ext}"
      end

      defp format_changeset_errors(changeset) do
        changeset.errors
        |> Enum.map(fn {field, {message, _}} ->
          "#{Phoenix.Naming.humanize(field)} #{message}"
        end)
        |> Enum.join(", ")
      end
    end
  end
end
