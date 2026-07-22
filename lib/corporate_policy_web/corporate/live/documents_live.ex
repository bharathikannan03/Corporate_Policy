defmodule CorporatePolicyWeb.Corporate.DocumentsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Corporates
  alias CorporatePolicy.Policies
  alias CorporatePolicyWeb.Layouts

  @impl true
  def mount(_params, session, socket) do
    user_id = session["current_user_id"]

    current_user =
      socket.assigns[:current_user] || (user_id && Accounts.get_user(user_id))

    corporate =
      if current_user && current_user.ref_corporate_id do
        Corporates.get_corporate!(current_user.ref_corporate_id)
      else
        nil
      end

    corporate_name =
      (corporate && corporate.corporate_name) ||
        "Vibe Insurance Broking & Advisory Service pvt Ltd"

    corporate_id = corporate && corporate.corporate_id
    financial_years = Policies.list_financial_years()

    all_policies =
      if corporate_id,
        do: Policies.list_active_policies_by_corporate(corporate_id),
        else: Policies.list_active_policies()

    current_fy =
      case all_policies do
        [first_policy | _] ->
          first_policy.financial_year_ref || Enum.find(financial_years, &(&1.status == 1)) ||
            List.first(financial_years)

        [] ->
          Enum.find(financial_years, &(&1.status == 1)) || List.first(financial_years)
      end

    current_fy_name = (current_fy && current_fy.year_name) || "2025-2026"
    current_fy_id = current_fy && current_fy.id

    policies =
      if current_fy_id do
        Enum.filter(all_policies, &(&1.ref_fy_year_id == current_fy_id))
      else
        all_policies
      end

    fetched_types =
      policies
      |> Enum.map(&get_policy_type_name/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    policy_types = if fetched_types == [], do: ["GMC", "GPA"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id

    active_doc_type = "policy"
    documents = fetch_documents(policy_id, active_doc_type)

    socket =
      socket
      |> assign(:page_title, "Documents - Corporate Portal")
      |> assign(:current_user, current_user)
      |> assign(:corporate, corporate)
      |> assign(:corporate_name, corporate_name)
      |> assign(:corporate_id, corporate_id)
      |> assign(:financial_years, financial_years)
      |> assign(:current_fy_name, current_fy_name)
      |> assign(:current_fy_id, current_fy_id)
      |> assign(:all_policies, all_policies)
      |> assign(:policies, policies)
      |> assign(:policy_types, policy_types)
      |> assign(:active_policy_type, active_policy_type)
      |> assign(:policy_numbers, policy_numbers)
      |> assign(:active_policy_number, active_policy_number)
      |> assign(:selected_policy, selected_policy)
      |> assign(:policy_id, policy_id)
      |> assign(:active_doc_type, active_doc_type)
      |> assign(:documents, documents)
      |> assign(:active_path, "/corporate/documents")

    {:ok, socket}
  end

  @impl true
  def handle_event("select_doc_type", %{"type" => doc_type}, socket) do
    documents = fetch_documents(socket.assigns.policy_id, doc_type)

    {:noreply,
     socket
     |> assign(:active_doc_type, doc_type)
     |> assign(:documents, documents)}
  end

  @impl true
  def handle_event("select_policy_type", %{"type" => type}, socket) do
    policy_numbers = get_numbers_for_type(socket.assigns.policies, type)
    active_policy_number = List.first(policy_numbers)

    selected_policy =
      get_selected_policy(socket.assigns.policies, type, active_policy_number)

    policy_id = selected_policy && selected_policy.id
    documents = fetch_documents(policy_id, socket.assigns.active_doc_type)

    {:noreply,
     socket
     |> assign(:active_policy_type, type)
     |> assign(:policy_numbers, policy_numbers)
     |> assign(:active_policy_number, active_policy_number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:documents, documents)}
  end

  @impl true
  def handle_event("select_policy_number", %{"number" => number}, socket) do
    selected_policy =
      get_selected_policy(socket.assigns.policies, socket.assigns.active_policy_type, number)

    policy_id = selected_policy && selected_policy.id
    documents = fetch_documents(policy_id, socket.assigns.active_doc_type)

    {:noreply,
     socket
     |> assign(:active_policy_number, number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:documents, documents)}
  end

  @impl true
  def handle_event("change_financial_year", %{"fy_id" => fy_id_str}, socket) do
    fy_id = String.to_integer(fy_id_str)
    fy = Enum.find(socket.assigns.financial_years, &(&1.id == fy_id))
    fy_name = (fy && fy.year_name) || socket.assigns.current_fy_name

    policies =
      Enum.filter(socket.assigns.all_policies, &(&1.ref_fy_year_id == fy_id))

    fetched_types =
      policies
      |> Enum.map(&get_policy_type_name/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    policy_types = if fetched_types == [], do: ["GMC", "GPA"], else: fetched_types
    active_policy_type = List.first(policy_types)

    fetched_numbers = get_numbers_for_type(policies, active_policy_type)
    policy_numbers = if fetched_numbers == [], do: ["PG11260000000094"], else: fetched_numbers
    active_policy_number = List.first(policy_numbers)

    selected_policy = get_selected_policy(policies, active_policy_type, active_policy_number)
    policy_id = selected_policy && selected_policy.id
    documents = fetch_documents(policy_id, socket.assigns.active_doc_type)

    {:noreply,
     socket
     |> assign(:current_fy_name, fy_name)
     |> assign(:current_fy_id, fy_id)
     |> assign(:policies, policies)
     |> assign(:policy_types, policy_types)
     |> assign(:active_policy_type, active_policy_type)
     |> assign(:policy_numbers, policy_numbers)
     |> assign(:active_policy_number, active_policy_number)
     |> assign(:selected_policy, selected_policy)
     |> assign(:policy_id, policy_id)
     |> assign(:documents, documents)}
  end

  defp fetch_documents(policy_id, doc_type) do
    db_docs = Policies.list_documents_for_policy(policy_id, doc_type)

    Enum.map(db_docs, fn doc ->
      %{
        id: doc.id,
        document_name: doc.document_name,
        file_path: doc.file_path,
        original_file_name: doc.original_file_name || doc.document_name
      }
    end)
  end

  defp get_policy_type_name(policy) do
    cond do
      policy.policy_type_ref && Map.get(policy.policy_type_ref, :policy_type_value) ->
        policy.policy_type_ref.policy_type_value

      policy.policy_type_ref && Map.get(policy.policy_type_ref, :name) ->
        policy.policy_type_ref.name

      is_binary(policy.policy_type) and policy.policy_type != "" ->
        policy.policy_type

      true ->
        nil
    end
  end

  defp get_numbers_for_type(policies, target_type) do
    policies
    |> Enum.filter(fn p ->
      type_name = get_policy_type_name(p)
      type_name == target_type or (is_nil(type_name) and target_type == "GMC")
    end)
    |> Enum.map(& &1.policy_number)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp get_selected_policy(policies, type, number) do
    Enum.find(policies, fn p ->
      type_name = get_policy_type_name(p)

      (type_name == type or (is_nil(type_name) and type == "GMC")) and
        p.policy_number == number
    end) || List.first(policies)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.corporate
      flash={@flash}
      current_user={@current_user}
      corporate={@corporate}
      corporate_name={@corporate_name}
      financial_years={@financial_years}
      current_fy_name={@current_fy_name}
      policy_types={@policy_types}
      active_policy_type={@active_policy_type}
      policy_numbers={@policy_numbers}
      active_policy_number={@active_policy_number}
      active_path={@active_path}
    >
      <div class="space-y-4 my-4">
        <%!-- Title Bar with Policy Document / Service Document Segmented Controls --%>
        <div class="bg-white rounded-lg p-3 sm:p-4 shadow-xs flex flex-wrap items-center justify-between gap-3 border border-gray-200">
          <h2 class="text-lg sm:text-xl font-bold text-gray-900">
            {if @active_doc_type == "policy", do: "Policy Document", else: "Service Document"}
          </h2>

          <div class="inline-flex rounded-md shadow-xs p-1 bg-gray-100 border border-gray-200">
            <button
              type="button"
              phx-click="select_doc_type"
              phx-value-type="policy"
              class={[
                "px-4 py-1.5 text-xs sm:text-sm font-semibold rounded-md transition-all duration-150",
                @active_doc_type == "policy" && "bg-blue-600 text-white shadow-xs",
                @active_doc_type != "policy" &&
                  "text-gray-700 hover:text-gray-900 hover:bg-gray-200/60"
              ]}
            >
              Policy Document
            </button>

            <button
              type="button"
              phx-click="select_doc_type"
              phx-value-type="service"
              class={[
                "px-4 py-1.5 text-xs sm:text-sm font-semibold rounded-md transition-all duration-150",
                @active_doc_type == "service" && "bg-blue-600 text-white shadow-xs",
                @active_doc_type != "service" &&
                  "text-gray-700 hover:text-gray-900 hover:bg-gray-200/60"
              ]}
            >
              Service Document
            </button>
          </div>
        </div>
        <%!-- Documents Grid Display Card --%>
        <div class="bg-white rounded-xl shadow-xs border border-gray-200 p-6 sm:p-10 min-h-[300px]">
          <%= if Enum.empty?(@documents) do %>
            <div class="text-center py-12 text-slate-500">
              <.icon name="hero-document-text" class="w-12 h-12 mx-auto text-slate-300 mb-3" />
              <p class="text-base font-medium">No documents available for this policy.</p>
            </div>
          <% else %>
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-6 sm:gap-8 items-start">
              <%= for doc <- @documents do %>
                <a
                  href={doc.file_path}
                  target="_blank"
                  download
                  class="group flex flex-col items-center text-center p-4 rounded-xl hover:bg-slate-50 transition-all duration-200 border border-transparent hover:border-slate-200 cursor-pointer focus:outline-none"
                  title={"Download #{doc.document_name}"}
                >
                  <%!-- Red PDF Document Icon --%>
                  <div class="relative mb-3 transition-transform duration-200 group-hover:scale-105">
                    <svg
                      class="w-16 h-20 text-red-500 drop-shadow-xs"
                      viewBox="0 0 56 72"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M36 0H6C2.68629 0 0 2.68629 0 6V66C0 69.3137 2.68629 72 6 72H50C53.3137 72 56 69.3137 56 66V20L36 0Z"
                        fill="#FF4B4B"
                      />
                      <path
                        d="M36 0V14C36 17.3137 38.6863 20 42 20H56L36 0Z"
                        fill="#D92D2D"
                      /> <%!-- Inner Adobe PDF Logo graphics --%>
                      <path
                        d="M16 48C16 48 18 36 28 36C38 36 40 48 40 48"
                        stroke="white"
                        stroke-width="3"
                        stroke-linecap="round"
                      /> <circle cx="28" cy="33" r="3" fill="white" />
                    </svg>
                  </div>

                  <span class="text-xs sm:text-sm font-medium text-slate-700 group-hover:text-blue-600 transition-colors line-clamp-2">
                    {doc.document_name}
                  </span>
                </a>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.corporate>
    """
  end
end
