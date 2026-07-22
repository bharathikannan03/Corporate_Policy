defmodule CorporatePolicyWeb.ClaimSubmissionIndexLive do
  alias CorporatePolicy.Claims

  defmacro __using__(opts) do
    portal = Keyword.fetch!(opts, :portal)

    quote do
      use CorporatePolicyWeb, :live_view

      import CorporatePolicyWeb.ClaimSubmissionComponents
      import CorporatePolicyWeb.Employee.PortalComponents

      @portal unquote(portal)

      @impl true
      def mount(params, session, socket) do
        current_user = resolve_current_user(session, socket, @portal)
        current_user = maybe_scope_employee_to_policy(current_user, params)
        employee_policy_options = employee_policy_options(current_user, @portal)

        {:ok,
         socket
         |> assign(:portal, @portal)
         |> assign(:current_user, current_user)
         |> assign(:employee_policy_options, employee_policy_options)
         |> assign(
           :employee_policy,
           if(@portal == :employee && current_user,
             do: Claims.get_policy(current_user.ref_policy_id),
             else: nil
           )
         )
         |> assign(:page_title, "Claim Submission")
         |> assign(:active_path, portal_path(@portal, "/claims-submission"))
         |> assign(:claim_statuses, Claims.claim_statuses())
         |> load_claims(%{})}
      end

      @impl true
      def handle_event("filter", params, socket) do
        {:noreply, load_claims(socket, Map.put(params, "page", 1))}
      end

      def handle_event("paginate", %{"page" => page}, socket) do
        params =
          socket.assigns.claims_page
          |> Map.take([:search, :status, :sort_by, :sort_dir])
          |> stringify()

        {:noreply, load_claims(socket, Map.put(params, "page", page))}
      end

      def handle_event("sort", %{"field" => field, "direction" => direction}, socket) do
        params =
          socket.assigns.claims_page
          |> Map.take([:search, :status])
          |> stringify()
          |> Map.merge(%{"sort_by" => field, "sort_dir" => direction, "page" => 1})

        {:noreply, load_claims(socket, params)}
      end

      @impl true
      def render(var!(assigns)) do
        ~H"""
        <%= cond do %>
          <% @portal == :admin -> %>
            <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
              <.portal_shell
                portal={@portal}
                current_user={@current_user}
                page_title={@page_title}
                active_path={@active_path}
              >
                <.submissions_index
                  claims_page={@claims_page}
                  portal={@portal}
                  status_options={@claim_statuses}
                />
              </.portal_shell>
            </Layouts.admin>
          <% @portal == :employee -> %>
            <Layouts.app flash={@flash}>
              <.shell
                current_user={@current_user}
                policy={@employee_policy}
                policy_options={@employee_policy_options}
                active_path={@active_path}
                page_title={@page_title}
              >
                <.portal_shell
                  portal={@portal}
                  current_user={@current_user}
                  page_title={@page_title}
                  active_path={@active_path}
                  selected_policy_id={@employee_policy && @employee_policy.id}
                >
                  <.submissions_index
                    claims_page={@claims_page}
                    portal={@portal}
                    status_options={@claim_statuses}
                    selected_policy_id={@employee_policy && @employee_policy.id}
                  />
                </.portal_shell>
              </.shell>
            </Layouts.app>
          <% true -> %>
            <Layouts.app flash={@flash}>
              <div class="p-6">
                <.portal_shell
                  portal={@portal}
                  current_user={@current_user}
                  page_title={@page_title}
                  active_path={@active_path}
                >
                  <.submissions_index
                    claims_page={@claims_page}
                    portal={@portal}
                    status_options={@claim_statuses}
                  />
                </.portal_shell>
              </div>
            </Layouts.app>
        <% end %>
        """
      end

      defp load_claims(socket, params) do
        params =
          if @portal == :employee && socket.assigns.current_user do
            Map.put(params, "ref_policy_id", socket.assigns.current_user.ref_policy_id)
          else
            params
          end

        claims_page = Claims.list_claims(socket.assigns.current_user, @portal, params)
        assign(socket, :claims_page, claims_page)
      end

      defp stringify(map) do
        Map.new(map, fn {key, value} -> {to_string(key), value} end)
      end

      defp resolve_current_user(session, socket, portal) do
        if portal == :employee do
          cond do
            socket.assigns[:current_user] &&
                Map.has_key?(socket.assigns.current_user, :ref_policy_id) ->
              socket.assigns.current_user

            employee_id = session["current_employee_id"] ->
              case CorporatePolicy.EmployeePortal.get_authenticated_employee_session(employee_id) do
                {:ok, employee} -> employee
                _ -> socket.assigns[:current_user]
              end

            true ->
              socket.assigns[:current_user]
          end
        else
          case session["current_user_id"] do
            nil -> socket.assigns[:current_user]
            id -> CorporatePolicy.Accounts.get_user(id)
          end
        end
      end

      defp maybe_scope_employee_to_policy(current_user, params) do
        if @portal == :employee && current_user do
          policy_options = CorporatePolicy.EmployeePortal.list_policies_for_employee(current_user)

          policy =
            CorporatePolicy.EmployeePortal.select_policy_for_employee(
              current_user,
              params["policy_id"],
              policy_options
            )

          CorporatePolicy.EmployeePortal.scoped_employee_for_policy(current_user, policy)
        else
          current_user
        end
      end

      defp employee_policy_options(current_user, portal) do
        if portal == :employee && current_user do
          CorporatePolicy.EmployeePortal.list_policies_for_employee(current_user)
        else
          []
        end
      end
    end
  end
end
