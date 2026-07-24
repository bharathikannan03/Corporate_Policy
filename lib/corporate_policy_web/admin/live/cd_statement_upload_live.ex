defmodule CorporatePolicyWeb.Admin.CdStatementUploadLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.CdStatements
  alias CorporatePolicy.Policies

  @max_csv_size 5_000_000

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
    default_corporate_id = if policy, do: policy.ref_corporate_id, else: nil

    socket =
      socket
      |> assign(:page_title, "CD Statement")
      |> assign(:current_user, current_user)
      |> assign(
        :active_path,
        if(standalone?, do: "/admin/cd-statements/cd-statement", else: "/admin/policy-details")
      )
      |> assign(:standalone?, standalone?)
      |> assign(:policy, policy)
      |> assign(:corporates, CdStatements.list_active_corporates())
      |> assign(
        :available_cd_accounts,
        if(default_corporate_id,
          do: CdStatements.list_cd_numbers_for_corporate(default_corporate_id),
          else: []
        )
      )
      |> assign(:search, "")
      |> assign(:sort_by, "inserted_at")
      |> assign(:sort_dir, "desc")
      |> assign(:page, 1)
      |> assign(:selected_upload_errors, nil)
      |> assign(
        :form,
        to_form(%{
          "corporate_id" => (default_corporate_id && to_string(default_corporate_id)) || "",
          "cd_number" => ""
        })
      )
      |> allow_upload(:cd_csv, accept: ~w(.csv), max_entries: 1, max_file_size: @max_csv_size)
      |> load_uploads()

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_form", %{"corporate_id" => corporate_id} = params, socket) do
    cd_accounts =
      case Integer.parse(corporate_id || "") do
        {id, ""} -> CdStatements.list_cd_numbers_for_corporate(id)
        _ -> []
      end

    params =
      if params["cd_number"] && Enum.any?(cd_accounts, &(&1.cd_number == params["cd_number"])) do
        params
      else
        Map.put(params, "cd_number", "")
      end

    {:noreply,
     socket
     |> assign(:available_cd_accounts, cd_accounts)
     |> assign(:form, to_form(params))}
  end

  @impl true
  def handle_event("remove_cd_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cd_csv, ref)}
  end

  @impl true
  def handle_event(
        "save_upload",
        %{"corporate_id" => corporate_id, "cd_number" => cd_number},
        socket
      ) do
    try do
      case consume_csv_upload(socket) do
        {:ok, socket, file_info} ->
          upload_result =
            if socket.assigns.policy do
              CdStatements.create_policy_cd_statement_upload(
                socket.assigns.policy,
                %{"corporate_id" => corporate_id, "cd_number" => cd_number},
                file_info,
                socket.assigns.current_user.id
              )
            else
              CdStatements.create_cd_statement_upload(
                %{"corporate_id" => corporate_id, "cd_number" => cd_number},
                file_info,
                socket.assigns.current_user.id
              )
            end

          case upload_result do
            {:ok, %{errors_count: 0}} ->
              {:noreply,
               socket
               |> put_flash(:info, "CD Statement uploaded successfully.")
               |> assign(:page, 1)
               |> load_uploads()}

            {:ok, %{errors_count: count}} ->
              {:noreply,
               socket
               |> put_flash(:error, "CD Statement uploaded with #{count} validation errors.")
               |> assign(:page, 1)
               |> load_uploads()}

            {:error, message} ->
              {:noreply, put_flash(socket, :error, message)}
          end

        {:error, socket, message} ->
          {:noreply, put_flash(socket, :error, message)}
      end
    rescue
      e in Postgrex.Error ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "CD Statement upload failed because the database schema is not fully updated. Run mix ecto.migrate and try again. Details: #{Exception.message(e)}"
         )}
    end
  end

  @impl true
  def handle_event("search_uploads", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> assign(:page, 1) |> load_uploads()}
  end

  @impl true
  def handle_event("sort_uploads", %{"sort_by" => sort_by}, socket) do
    sort_dir =
      if socket.assigns.sort_by == sort_by and socket.assigns.sort_dir == "asc",
        do: "desc",
        else: "asc"

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_dir, sort_dir)
     |> assign(:page, 1)
     |> load_uploads()}
  end

  @impl true
  def handle_event("paginate_table", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, page) |> load_uploads()}
  end

  @impl true
  def handle_event("show_errors", %{"upload_id" => upload_id}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_upload_errors,
       CdStatements.get_upload_errors(String.to_integer(upload_id))
     )}
  end

  @impl true
  def handle_event("close_errors", _, socket) do
    {:noreply, assign(socket, :selected_upload_errors, nil)}
  end

  defp load_uploads(socket) do
    opts = %{
      "page" => socket.assigns.page,
      "search" => socket.assigns.search,
      "sort_by" => socket.assigns.sort_by,
      "sort_dir" => socket.assigns.sort_dir
    }

    page_data =
      if socket.assigns.policy do
        CdStatements.list_policy_cd_statement_uploads(socket.assigns.policy.id, opts)
      else
        CdStatements.list_cd_statement_uploads_paginated(opts)
      end

    assign(socket, :uploads_page, page_data)
  end

  defp consume_csv_upload(socket) do
    upload_errors_present =
      not Enum.empty?(upload_errors(socket.assigns.uploads.cd_csv)) or
        Enum.any?(socket.assigns.uploads.cd_csv.entries, fn entry ->
          not Enum.empty?(upload_errors(socket.assigns.uploads.cd_csv, entry))
        end)

    cond do
      upload_errors_present ->
        {:error, socket, "Please fix the selected file before uploading."}

      Enum.empty?(socket.assigns.uploads.cd_csv.entries) ->
        {:error, socket, "CSV file is required."}

      true ->
        [file_info] =
          consume_uploaded_entries(socket, :cd_csv, fn %{path: path}, entry ->
            filename = "#{entry.uuid}.csv"
            relative_path = Path.join(["uploads", "cd_statements", filename])
            absolute_path = Path.join(["priv", "static", relative_path])
            File.mkdir_p!(Path.dirname(absolute_path))
            File.cp!(path, absolute_path)

            {:ok,
             %{
               original_file_name: entry.client_name,
               public_path: "/" <> String.replace(relative_path, "\\", "/"),
               absolute_path: Path.expand(absolute_path)
             }}
          end)

        {:ok, socket, file_info}
    end
  end

  defp status_badge_class(1), do: "badge badge-success badge-outline"
  defp status_badge_class(2), do: "badge badge-error badge-outline"
  defp status_badge_class(_), do: "badge badge-warning badge-outline"

  defp status_label(1), do: "Success"
  defp status_label(2), do: "Failed"
  defp status_label(_), do: "Processing"

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
            navigate={~p"/admin/policy-details/#{@policy.id}/edit?step=step7"}
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
            <div class="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
              <.form
                for={@form}
                id="add-cd-statement-form"
                phx-change="validate_form"
                phx-submit="save_upload"
                class="w-full"
              >
                <div class="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
                  <div class="w-full lg:max-w-xl">
                    <h1 class="text-2xl font-semibold mb-6">Add CD Statement</h1>
                    
                    <div class="space-y-4">
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
                        field={@form[:cd_number]}
                        type="select"
                        label="CD Number"
                        options={Enum.map(@available_cd_accounts, &{&1.cd_number, &1.cd_number})}
                        prompt="Select CD Number"
                        required
                        disabled={Enum.empty?(@available_cd_accounts)}
                        class="corp-input"
                      />
                      <.link
                        navigate={
                          if @policy do
                            ~p"/admin/policy-details/#{@policy.id}/cd-accounts/new"
                          else
                            ~p"/admin/cd-statements/cd-accounts"
                          end
                        }
                        class="link link-primary text-sm"
                      >
                        Add CD Number
                      </.link>
                      
                      <button
                        type="submit"
                        class="btn btn-success"
                        disabled={
                          Enum.empty?(@available_cd_accounts) or Enum.empty?(@uploads.cd_csv.entries)
                        }
                      >
                        Upload
                      </button>
                    </div>
                  </div>
                  
                  <div class="w-full lg:max-w-3xl">
                    <div class="flex items-center justify-between mb-2">
                      <label class="corp-label">CD Statement Data Upload</label>
                      <.link href="/templates/cd_ledger.csv" download class="btn btn-sm btn-primary">
                        Download Sample CSV
                      </.link>
                    </div>
                    
                    <div
                      class="border-2 border-dashed border-gray-300 rounded-lg p-10 text-center bg-gray-50"
                      phx-drop-target={@uploads.cd_csv.ref}
                    >
                      <div class="flex flex-col items-center gap-3">
                        <.icon name="hero-arrow-up-tray" class="w-12 h-12 text-blue-500" />
                        <.live_file_input upload={@uploads.cd_csv} class="hidden" />
                        <label
                          for={@uploads.cd_csv.ref}
                          class="cursor-pointer text-blue-600 hover:underline"
                        >
                          Drag and drop a file here or click
                        </label>
                        
                        <p :if={Enum.empty?(@available_cd_accounts)} class="text-sm text-red-600">
                          No CD Number exists for the selected corporate. Please create one first.
                        </p>
                      </div>
                    </div>
                    
                    <%= for err <- upload_errors(@uploads.cd_csv) do %>
                      <p class="mt-2 text-sm text-error">{Phoenix.Naming.humanize(err)}</p>
                    <% end %>
                    
                    <%= for entry <- @uploads.cd_csv.entries do %>
                      <div class="flex items-center justify-between bg-white border rounded-lg p-3 mt-4">
                        <div>
                          <p class="font-medium">{entry.client_name}</p>
                          
                          <%= for err <- upload_errors(@uploads.cd_csv, entry) do %>
                            <p class="text-sm text-error">{Phoenix.Naming.humanize(err)}</p>
                          <% end %>
                        </div>
                        
                        <div class="flex items-center gap-3">
                          <span class="text-sm text-success">{entry.progress}%</span>
                          <button
                            type="button"
                            phx-click="remove_cd_entry"
                            phx-value-ref={entry.ref}
                            class="btn btn-xs btn-ghost"
                          >Cancel</button>
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>
              </.form>
            </div>
            
            <div class="mt-10">
              <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-4">
                <h2 class="text-lg font-semibold">Upload History</h2>
                
                <input
                  type="text"
                  name="search"
                  value={@search}
                  placeholder="Search CD number or file"
                  phx-keyup="search_uploads"
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
                            phx-click="sort_uploads"
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
                            phx-click="sort_uploads"
                            phx-value-sort_by="original_file_name"
                            class="flex items-center gap-1"
                          >
                            File Name
                            <.sort_icon
                              active={@sort_by == "original_file_name"}
                              direction={@sort_dir}
                            />
                          </button>
                        </th>
                        
                        <th class="corp-th">Status</th>
                        
                        <th class="corp-th">
                          <button
                            type="button"
                            phx-click="sort_uploads"
                            phx-value-sort_by="inserted_at"
                            class="flex items-center gap-1"
                          >
                            Created At
                            <.sort_icon active={@sort_by == "inserted_at"} direction={@sort_dir} />
                          </button>
                        </th>
                        
                        <th class="corp-th text-right">Actions</th>
                      </tr>
                    </thead>
                    
                    <tbody>
                      <%= if @uploads_page.entries == [] do %>
                        <tr class="corp-empty-row">
                          <td colspan="6" class="corp-empty-cell py-10">
                            No CD Statement uploads found for this policy
                          </td>
                        </tr>
                      <% else %>
                        <%= for {upload, index} <- Enum.with_index(@uploads_page.entries, 1) do %>
                          <tr class="corp-tr">
                            <td class="corp-td">
                              {(@uploads_page.page - 1) * @uploads_page.page_size + index}
                            </td>
                            
                            <td class="corp-td">{upload.cd_number}</td>
                            
                            <td class="corp-td">
                              <%= if upload.data_upload_file do %>
                                <.link
                                  href={upload.data_upload_file}
                                  target="_blank"
                                  download
                                  class="link link-primary"
                                >
                                  {upload.original_file_name}
                                </.link>
                              <% else %>
                                -
                              <% end %>
                            </td>
                            
                            <td class="corp-td">
                              <span class={status_badge_class(upload.status)}>{status_label(
                                upload.status
                              )}</span>
                            </td>
                            
                            <td class="corp-td whitespace-nowrap">
                              {Calendar.strftime(upload.inserted_at, "%d-%m-%Y %H:%M")}
                            </td>
                            
                            <td class="corp-td">
                              <div class="flex justify-end">
                                <button
                                  :if={upload.status == 2}
                                  type="button"
                                  phx-click="show_errors"
                                  phx-value-upload_id={upload.id}
                                  class="btn btn-xs btn-outline btn-error"
                                >
                                  View Detail
                                </button>
                              </div>
                            </td>
                          </tr>
                        <% end %>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>
              
              <.pagination
                page={@uploads_page.page}
                page_size={@uploads_page.page_size}
                total_entries={@uploads_page.total_entries}
                total_pages={@uploads_page.total_pages}
                event="paginate_table"
              />
            </div>
          </div>
        </div>
      </div>
      
      <%= if @selected_upload_errors do %>
        <div class="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div class="bg-white rounded-xl shadow-xl w-full max-w-3xl max-h-[85vh] overflow-hidden">
            <div class="flex items-center justify-between px-6 py-4 border-b">
              <h3 class="text-lg font-semibold">Upload Error Details</h3>
              
              <button type="button" phx-click="close_errors" class="btn btn-sm btn-ghost">Close</button>
            </div>
            
            <div class="overflow-x-auto max-h-[70vh] p-6">
              <table class="table table-zebra">
                <thead>
                  <tr>
                    <th>Row</th>
                    
                    <th>Column</th>
                    
                    <th>Error</th>
                  </tr>
                </thead>
                
                <tbody>
                  <%= for error <- @selected_upload_errors do %>
                    <tr>
                      <td>{error.row}</td>
                      
                      <td>{error.column_name}</td>
                      
                      <td>{error.errors}</td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.admin>
    """
  end
end
