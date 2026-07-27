defmodule CorporatePolicyWeb.Admin.CdAccountsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.CdStatements
  alias CorporatePolicy.Policies

  @impl true
  def mount(params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    policy =
      case params["policy_id"] do
        nil ->
          nil

        policy_id ->
          policy_id
          |> Policies.get_policy!()
          |> CorporatePolicy.Repo.preload([:corporate, :insurer_ref])
      end

    standalone? = is_nil(policy)
    selected_corporate_id = if policy, do: policy.ref_corporate_id, else: nil

    socket =
      socket
      |> assign(:page_title, "CD Accounts")
      |> assign(:current_user, current_user)
      |> assign(
        :active_path,
        if(standalone?, do: "/admin/cd-statements/cd-accounts", else: "/admin/policy-details")
      )
      |> assign(:standalone?, standalone?)
      |> assign(:policy, policy)
      |> assign(:corporates, CdStatements.list_active_corporates())
      |> assign(
        :policy_options,
        if(selected_corporate_id,
          do: CdStatements.list_policy_options_for_corporate(selected_corporate_id),
          else: []
        )
      )
      |> assign(:search, "")
      |> assign(:sort_by, "inserted_at")
      |> assign(:sort_dir, "desc")
      |> assign(:page, 1)
      |> assign(
        :form,
        to_form(%{
          "corporate_id" => (selected_corporate_id && to_string(selected_corporate_id)) || "",
          "policy_id" => "",
          "insurer_name" => "",
          "cd_number" => ""
        })
      )
      |> load_accounts()

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_form", %{"corporate_id" => corporate_id} = params, socket) do
    policy_options =
      case Integer.parse(corporate_id || "") do
        {id, ""} -> CdStatements.list_policy_options_for_corporate(id)
        _ -> []
      end

    params =
      if to_string(socket.assigns.form.params["corporate_id"]) != to_string(corporate_id) do
        params |> Map.put("policy_id", "") |> Map.put("insurer_name", "")
      else
        params
      end

    selected_policy =
      Enum.find(policy_options, &(to_string(&1.id) == to_string(params["policy_id"])))

    {:noreply,
     socket
     |> assign(:policy_options, policy_options)
     |> assign(
       :form,
       to_form(
         Map.put(params, "insurer_name", (selected_policy && selected_policy.insurer_name) || "")
       )
     )}
  end

  @impl true
  def handle_event("save_account", params, socket) do
    try do
      case CdStatements.create_cd_account(params, socket.assigns.current_user.id) do
        {:ok, _account} ->
          return_path =
            if socket.assigns.policy do
              ~p"/admin/policy-details/#{socket.assigns.policy.id}/cd-statements/new"
            else
              ~p"/admin/cd-statements/cd-statement"
            end

          {:noreply,
           socket
           |> put_flash(:info, "CD Account created successfully.")
           |> push_navigate(to: return_path)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Failed to create CD Account.")
           |> assign(:form, to_form(changeset))}

        {:error, message} ->
          {:noreply, put_flash(socket, :error, message)}
      end
    rescue
      e in Postgrex.Error ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "CD Account save failed. Details: #{Exception.message(e)}"
         )}
    end
  end

  @impl true
  def handle_event("search_accounts", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> assign(:page, 1) |> load_accounts()}
  end

  @impl true
  def handle_event("sort_accounts", %{"sort_by" => sort_by}, socket) do
    sort_dir =
      if socket.assigns.sort_by == sort_by and socket.assigns.sort_dir == "asc",
        do: "desc",
        else: "asc"

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_dir, sort_dir)
     |> assign(:page, 1)
     |> load_accounts()}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, page) |> load_accounts()}
  end

  defp load_accounts(socket) do
    page_data =
      CdStatements.list_cd_accounts_paginated(%{
        "page" => socket.assigns.page,
        "search" => socket.assigns.search,
        "sort_by" => socket.assigns.sort_by,
        "sort_dir" => socket.assigns.sort_dir
      })

    assign(socket, :accounts_page, page_data)
  end

  attr :active, :boolean, required: true
  attr :direction, :string, required: true

  defp sort_icon(assigns) do
    ~H"""
    <span class="text-xs text-gray-400">
      <%= cond do %>
        <% @active and @direction == "asc" -> %>
          ↑
        <% @active and @direction == "desc" -> %>
          ↓
        <% true -> %>
          ↕
      <% end %>
    </span>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="p-6">
        <div class="max-w-7xl mx-auto space-y-6">
          <.link
            :if={@policy}
            navigate={~p"/admin/policy-details/#{@policy.id}/cd-statements/new"}
            class="btn btn-sm btn-primary"
          >
            <.icon name="hero-chevron-left" class="w-4 h-4" /> Back To CD Statement
          </.link>

          <.link
            :if={@standalone?}
            navigate={~p"/admin/cd-statements"}
            class="btn btn-sm btn-primary"
          >
            <.icon name="hero-chevron-left" class="w-4 h-4" /> Back To CD Statements
          </.link>

          <div class="bg-base-100 rounded-box shadow-xl p-6">
            <h1 class="text-2xl font-semibold mb-6">CD Accounts</h1>

            <.form
              for={@form}
              id="add-cd-account-form"
              phx-change="validate_form"
              phx-submit="save_account"
            >
              <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                <.input
                  field={@form[:cd_number]}
                  label="CD Number"
                  required
                  class="corp-input"
                  placeholder="Enter CD Number"
                />
                <.input
                  field={@form[:corporate_id]}
                  type="select"
                  label="Corporate Name"
                  options={Enum.map(@corporates, &{&1.corporate_name, &1.corporate_id})}
                  prompt="Select Corporate name"
                  required
                  class="corp-input"
                />
                <.input
                  field={@form[:policy_id]}
                  type="select"
                  label="Policy Number"
                  options={Enum.map(@policy_options, &{&1.policy_number, &1.id})}
                  prompt="Select Policy number"
                  required
                  disabled={Enum.empty?(@policy_options)}
                  class="corp-input"
                />
                <.input
                  field={@form[:insurer_name]}
                  label="Insurer"
                  readonly
                  class="corp-input corp-input--readonly"
                />
              </div>

              <div class="mt-4 flex justify-end">
                <button type="submit" class="btn btn-success">Add CD Account</button>
              </div>
            </.form>

            <div class="mt-10">
              <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-4">
                <h2 class="text-lg font-semibold">Existing CD Accounts</h2>

                <input
                  type="text"
                  name="search"
                  value={@search}
                  placeholder="Search CD number, policy, insurer"
                  phx-keyup="search_accounts"
                  phx-debounce="300"
                  class="input input-bordered"
                />
              </div>

              <div class="corp-table-card">
                <div class="overflow-x-auto">
                  <table class="corp-table">
                    <thead>
                      <tr>
                        <th class="corp-th">#</th>

                        <th class="corp-th">
                          <button
                            type="button"
                            phx-click="sort_accounts"
                            phx-value-sort_by="cd_number"
                            class="flex items-center gap-1"
                          >
                            CD Number
                            <.sort_icon active={@sort_by == "cd_number"} direction={@sort_dir} />
                          </button>
                        </th>

                        <th class="corp-th">
                          <button
                            type="button"
                            phx-click="sort_accounts"
                            phx-value-sort_by="corporate_name"
                            class="flex items-center gap-1"
                          >
                            Corporate Name
                            <.sort_icon active={@sort_by == "corporate_name"} direction={@sort_dir} />
                          </button>
                        </th>

                        <th class="corp-th">
                          <button
                            type="button"
                            phx-click="sort_accounts"
                            phx-value-sort_by="policy_number"
                            class="flex items-center gap-1"
                          >
                            Policy Number
                            <.sort_icon active={@sort_by == "policy_number"} direction={@sort_dir} />
                          </button>
                        </th>

                        <th class="corp-th">
                          <button
                            type="button"
                            phx-click="sort_accounts"
                            phx-value-sort_by="insurer_name"
                            class="flex items-center gap-1"
                          >
                            Insurer
                            <.sort_icon active={@sort_by == "insurer_name"} direction={@sort_dir} />
                          </button>
                        </th>

                        <th class="corp-th">Created At</th>
                      </tr>
                    </thead>

                    <tbody>
                      <%= if @accounts_page.entries == [] do %>
                        <tr class="corp-empty-row">
                          <td colspan="6" class="corp-empty-cell py-10">No CD Accounts found</td>
                        </tr>
                      <% else %>
                        <%= for {account, index} <- Enum.with_index(@accounts_page.entries, 1) do %>
                          <tr class="corp-tr">
                            <td class="corp-td">
                              {(@accounts_page.page - 1) * @accounts_page.page_size + index}
                            </td>

                            <td class="corp-td">{account.cd_number}</td>

                            <td class="corp-td">{account.corporate_name}</td>

                            <td class="corp-td">{account.policy_number}</td>

                            <td class="corp-td">{account.insurer_name}</td>

                            <td class="corp-td whitespace-nowrap">
                              {Calendar.strftime(account.inserted_at, "%d-%m-%Y")}
                            </td>
                          </tr>
                        <% end %>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>

              <.pagination
                page={@accounts_page.page}
                page_size={@accounts_page.page_size}
                total_entries={@accounts_page.total_entries}
                total_pages={@accounts_page.total_pages}
                event="paginate_table"
              />
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
