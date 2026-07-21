defmodule CorporatePolicyWeb.ClaimSubmissionIndexLive do
  alias CorporatePolicy.Claims

  defmacro __using__(opts) do
    portal = Keyword.fetch!(opts, :portal)

    quote do
      use CorporatePolicyWeb, :live_view

      import CorporatePolicyWeb.ClaimSubmissionComponents

      @portal unquote(portal)

      @impl true
      def mount(_params, session, socket) do
        current_user =
          case session["current_user_id"] do
            nil -> socket.assigns[:current_user]
            id -> CorporatePolicy.Accounts.get_user(id)
          end

        {:ok,
         socket
         |> assign(:portal, @portal)
         |> assign(:current_user, current_user)
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
        <%= if @portal == :admin do %>
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
        <% else %>
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
        claims_page = Claims.list_claims(socket.assigns.current_user, @portal, params)
        assign(socket, :claims_page, claims_page)
      end

      defp stringify(map) do
        Map.new(map, fn {key, value} -> {to_string(key), value} end)
      end
    end
  end
end
