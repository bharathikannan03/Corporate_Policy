defmodule CorporatePolicyWeb.Admin.CashlessHospitalsLive do
  use CorporatePolicyWeb, :live_view

  alias CorporatePolicy.Policies

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    all_insurers = Policies.list_insurers()
    all_tpas = Policies.list_tpas()

    socket =
      socket
      |> assign(:page_title, "Import Cashless Hospital")
      |> assign(:current_user, current_user)
      |> assign(:active_path, "/admin/cashless-hospitals")
      # All items for instant lookup
      |> assign(:all_insurers, all_insurers)
      |> assign(:all_tpas, all_tpas)
      # Autocomplete states for Insurer
      |> assign(:insurer_query, "")
      |> assign(:insurer_results, [])
      |> assign(:selected_insurer_id, nil)
      |> assign(:selected_insurer_name, nil)
      |> assign(:show_insurer_dropdown, false)
      # Autocomplete states for TPA
      |> assign(:tpa_query, "")
      |> assign(:tpa_results, [])
      |> assign(:selected_tpa_id, nil)
      |> assign(:selected_tpa_name, nil)
      |> assign(:show_tpa_dropdown, false)
      # Main table listing states
      |> assign(:search, "")
      |> assign(:page, 1)
      |> assign(:total_pages, 1)
      |> assign(:total_entries, 0)
      |> assign(:uploads_list, [])
      |> assign(:error_message, nil)
      # File upload
      |> allow_upload(:ch_file, accept: ~w(.csv), max_entries: 1, max_file_size: 10_000_000)
      |> load_imports()

    {:ok, socket}
  end

  @impl true
  def handle_event("search_insurer", %{"value" => query}, socket) do
    socket = socket |> assign(:insurer_query, query)
    results = filter_list(socket.assigns.all_insurers, query, 5)
    {:noreply, assign(socket, insurer_results: results, show_insurer_dropdown: true)}
  end

  def handle_event("show_insurer_dropdown", _params, socket) do
    results = filter_list(socket.assigns.all_insurers, socket.assigns.insurer_query, 5)
    {:noreply, assign(socket, insurer_results: results, show_insurer_dropdown: true)}
  end

  def handle_event("select_insurer", %{"id" => id, "name" => name}, socket) do
    {:noreply,
     socket
     |> assign(:selected_insurer_id, String.to_integer(id))
     |> assign(:selected_insurer_name, name)
     |> assign(:insurer_query, name)
     |> assign(:show_insurer_dropdown, false)}
  end

  def handle_event("clear_insurer", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_insurer_id, nil)
     |> assign(:selected_insurer_name, nil)
     |> assign(:insurer_query, "")
     |> assign(:insurer_results, [])}
  end

  @impl true
  def handle_event("search_tpa", %{"value" => query}, socket) do
    socket = socket |> assign(:tpa_query, query)
    results = filter_list(socket.assigns.all_tpas, query, 5)
    {:noreply, assign(socket, tpa_results: results, show_tpa_dropdown: true)}
  end

  def handle_event("show_tpa_dropdown", _params, socket) do
    results = filter_list(socket.assigns.all_tpas, socket.assigns.tpa_query, 5)
    {:noreply, assign(socket, tpa_results: results, show_tpa_dropdown: true)}
  end

  def handle_event("select_tpa", %{"id" => id, "name" => name}, socket) do
    {:noreply,
     socket
     |> assign(:selected_tpa_id, String.to_integer(id))
     |> assign(:selected_tpa_name, name)
     |> assign(:tpa_query, name)
     |> assign(:show_tpa_dropdown, false)}
  end

  def handle_event("clear_tpa", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_tpa_id, nil)
     |> assign(:selected_tpa_name, nil)
     |> assign(:tpa_query, "")
     |> assign(:tpa_results, [])}
  end

  def handle_event("close_dropdowns", _params, socket) do
    {:noreply, socket |> assign(show_insurer_dropdown: false, show_tpa_dropdown: false)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :ch_file, ref)}
  end

  def handle_event("save_upload", _params, socket) do
    insurer_id = socket.assigns.selected_insurer_id
    insurer_name = socket.assigns.selected_insurer_name
    tpa_id = socket.assigns.selected_tpa_id
    tpa_name = socket.assigns.selected_tpa_name

    cond do
      is_nil(insurer_id) ->
        {:noreply, put_flash(socket, :error, "Please select an Insurer.")}

      Enum.empty?(socket.assigns.uploads.ch_file.entries) ->
        {:noreply, put_flash(socket, :error, "Please upload a CSV file.")}

      true ->
        uploaded_files =
          consume_uploaded_entries(socket, :ch_file, fn %{path: path}, entry ->
            dest = Path.join("priv/static/uploads", filename(entry))
            File.mkdir_p!(Path.dirname(dest))
            File.cp!(path, dest)
            {:ok, %{original_file_name: entry.client_name, file_path: dest}}
          end)

        case uploaded_files do
          [file_info] ->
            attrs = %{
              ref_insurer_id: insurer_id,
              insurer_name: insurer_name,
              ref_tpa_id: tpa_id,
              tpa_name: tpa_name,
              ch_upload_data: file_info.file_path,
              original_file_name: file_info.original_file_name
            }

            case Policies.create_cashless_hospital_import(attrs) do
              {:ok, _ch} ->
                {:noreply,
                 socket
                 |> put_flash(:info, "Cashless hospital data uploaded successfully.")
                 |> assign(:selected_insurer_id, nil)
                 |> assign(:selected_insurer_name, nil)
                 |> assign(:insurer_query, "")
                 |> assign(:insurer_results, [])
                 |> assign(:selected_tpa_id, nil)
                 |> assign(:selected_tpa_name, nil)
                 |> assign(:tpa_query, "")
                 |> assign(:tpa_results, [])
                 |> assign(:page, 1)
                 |> load_imports()}

              {:error, _changeset} ->
                error_msg = "Database error: Failed to parse or insert cashless hospital records."
                {:noreply, socket |> put_flash(:error, error_msg)}
            end

          _ ->
            {:noreply, put_flash(socket, :error, "Failed to receive uploaded file.")}
        end
    end
  end

  def handle_event("search_table", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> assign(:page, 1) |> load_imports()}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, String.to_integer(page)) |> load_imports()}
  end

  defp filename(entry) do
    extension = Path.extname(entry.client_name)
    "ch_#{System.unique_integer([:positive])}#{extension}"
  end

  defp load_imports(socket) do
    res =
      Policies.list_cashless_hospitals_paginated(
        page: socket.assigns.page,
        search: socket.assigns.search
      )

    socket
    |> assign(:uploads_list, res.entries)
    |> assign(:total_pages, res.total_pages)
    |> assign(:total_entries, res.total_entries)
    |> assign(:page, res.page)
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d-%m-%Y %I:%M %p")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="corp-list-page" phx-click="close_dropdowns">
        <!-- Main Form Card -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6 mb-8">
          <h2 class="text-xl font-semibold text-gray-800 mb-6">Import Cashless Hospital</h2>

          <.form
            for={%{}}
            id="cashless-upload-form"
            phx-submit="save_upload"
            class="grid grid-cols-1 md:grid-cols-2 gap-6"
          >
            <div class="space-y-4">
              <!-- Insurer input -->
              <div class="relative w-full" phx-click-stop>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                  Insurer Name <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input
                    type="text"
                    placeholder="Type to search or select..."
                    value={@insurer_query}
                    class="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none pr-10"
                    phx-keyup="search_insurer"
                    phx-debounce="300"
                    phx-focus="show_insurer_dropdown"
                    readonly={!is_nil(@selected_insurer_id)}
                  />
                  <%= if @selected_insurer_id do %>
                    <button
                      type="button"
                      phx-click="clear_insurer"
                      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      <.icon name="hero-x-mark" class="w-5 h-5" />
                    </button>
                  <% else %>
                    <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">
                      <.icon name="hero-chevron-down" class="w-5 h-5" />
                    </div>
                  <% end %>
                </div>

                <%= if @show_insurer_dropdown do %>
                  <div class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-36 overflow-y-auto">
                    <%= if Enum.empty?(@insurer_results) do %>
                      <div class="p-3 text-sm text-gray-500">No matching insurers found</div>
                    <% else %>
                      <%= for insurer <- @insurer_results do %>
                        <div
                          phx-click="select_insurer"
                          phx-value-id={insurer.id}
                          phx-value-name={insurer.name}
                          class="p-3 text-sm hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-0 text-gray-800"
                        >
                          {insurer.name}
                        </div>
                      <% end %>
                    <% end %>
                  </div>
                <% end %>
              </div>

              <!-- TPA input -->
              <div class="relative w-full" phx-click-stop>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                  TPA Name
                </label>
                <div class="relative">
                  <input
                    type="text"
                    placeholder="Type to search or select..."
                    value={@tpa_query}
                    class="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none pr-10"
                    phx-keyup="search_tpa"
                    phx-debounce="300"
                    phx-focus="show_tpa_dropdown"
                    readonly={!is_nil(@selected_tpa_id)}
                  />
                  <%= if @selected_tpa_id do %>
                    <button
                      type="button"
                      phx-click="clear_tpa"
                      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      <.icon name="hero-x-mark" class="w-5 h-5" />
                    </button>
                  <% else %>
                    <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">
                      <.icon name="hero-chevron-down" class="w-5 h-5" />
                    </div>
                  <% end %>
                </div>

                <%= if @show_tpa_dropdown do %>
                  <div class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-36 overflow-y-auto">
                    <%= if Enum.empty?(@tpa_results) do %>
                      <div class="p-3 text-sm text-gray-500">No matching TPAs found</div>
                    <% else %>
                      <%= for tpa <- @tpa_results do %>
                        <div
                          phx-click="select_tpa"
                          phx-value-id={tpa.id}
                          phx-value-name={tpa.name}
                          class="p-3 text-sm hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-0 text-gray-800"
                        >
                          {tpa.name}
                        </div>
                      <% end %>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>

            <!-- Upload Area -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Cashless Hospital Data Upload <span class="text-red-500">*</span>
              </label>
              <div
                class="border-2 border-dashed border-gray-300 hover:border-blue-400 transition-colors rounded-lg p-8 text-center cursor-pointer relative"
                phx-drop-target={@uploads.ch_file.ref}
              >
                <.live_file_input upload={@uploads.ch_file} class="hidden" />
                <label for={@uploads.ch_file.ref} class="cursor-pointer">
                  <div class="flex flex-col items-center justify-center">
                    <.icon name="hero-cloud-arrow-up" class="w-12 h-12 text-blue-500 mb-2" />
                    <p class="text-sm font-semibold text-gray-700">
                      Drag and drop a file here or click
                    </p>
                    <p class="text-xs text-gray-500 mt-1">Only CSV files are supported</p>
                  </div>
                </label>
              </div>

              <!-- Pending upload list -->
              <%= for entry <- @uploads.ch_file.entries do %>
                <div class="flex justify-between items-center bg-gray-50 p-3 rounded border border-gray-200 mt-4">
                  <div class="flex items-center space-x-2">
                    <.icon name="hero-document-text" class="w-5 h-5 text-gray-400" />
                    <span class="text-sm text-gray-700 font-medium">{entry.client_name}</span>
                  </div>
                  <div class="flex items-center gap-4">
                    <span class="text-xs font-semibold text-green-600">{entry.progress}%</span>
                    <button
                      type="button"
                      phx-click="cancel_upload"
                      phx-value-ref={entry.ref}
                      class="text-red-500 hover:text-red-700 text-sm font-semibold"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              <% end %>
            </div>

            <!-- Action buttons block -->
            <div class="col-span-full border-t border-gray-100 pt-4 flex flex-wrap gap-4 items-center justify-start">
              <!-- Upload Data is the submit button for form (green color scheme as per Rule 6) -->
              <button
                type="submit"
                class="btn btn-success text-white font-medium"
                disabled={is_nil(@selected_insurer_id) || Enum.empty?(@uploads.ch_file.entries)}
              >
                Upload Data
              </button>

              <a
                href="/uploads/samples/cashless_hospital_template.csv"
                download="cashless_hospital_template.csv"
                class="btn btn-outline btn-primary font-medium"
              >
                Download sample
              </a>

              <!-- <a href="#" class="text-blue-600 hover:underline text-sm font-medium ml-2">
                Track API Activity
              </a> -->
            </div>
          </.form>
        </div>

        <!-- History Listing Card -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6">
            <div>
              <h3 class="text-lg font-semibold text-gray-800">Upload History</h3>
              <p class="text-sm text-gray-500">
                Track and download previous cashless hospital data imports
              </p>
            </div>

            <div class="mt-4 sm:mt-0 w-full sm:w-72">
              <form phx-change="search_table" class="relative">
                <input
                  type="text"
                  name="search"
                  value={@search}
                  placeholder="Search Insurer or TPA..."
                  class="w-full rounded-md border border-gray-300 pl-10 pr-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                />
                <div class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
                  <.icon name="hero-magnifying-glass" class="w-4 h-4" />
                </div>
              </form>
            </div>
          </div>

          <div class="corp-table-card">
            <div class="overflow-x-auto">
              <table class="corp-table w-full text-left">
                <thead>
                  <tr>
                    <th class="corp-th">#</th>
                    <th class="corp-th">INSURER NAME</th>
                    <th class="corp-th">TPA NAME</th>
                    <th class="corp-th">FILE NAME</th>
                    <th class="corp-th">PROGRESS</th>
                    <th class="corp-th">STATUS</th>
                    <th class="corp-th">EVENT TYPE</th>
                    <th class="corp-th">CREATED AT</th>
                  </tr>
                </thead>
                <tbody id="imports-table-body">
                  <%= if Enum.empty?(@uploads_list) do %>
                    <tr class="corp-tr">
                      <td colspan="8" class="corp-td text-center text-gray-400 py-12">
                        <div class="flex flex-col items-center justify-center">
                          <.icon name="hero-building-office" class="w-12 h-12 text-gray-300 mb-2" />
                          <span>No upload records found</span>
                        </div>
                      </td>
                    </tr>
                  <% else %>
                    <%= for ch <- @uploads_list do %>
                      <tr class="corp-tr border-b border-gray-100 hover:bg-gray-50">
                        <td class="corp-td font-medium text-gray-700">{ch.row_num}</td>
                        <td class="corp-td font-semibold text-gray-900">{ch.insurer_name}</td>
                        <td class="corp-td text-gray-600">{ch.tpa_name || "Internal TPA"}</td>
                        <td class="corp-td">
                          <a
                            href={"/uploads/#{Path.basename(ch.ch_upload_data)}"}
                            download={ch.original_file_name}
                            class="text-blue-600 hover:underline flex items-center font-medium"
                          >
                            <.icon name="hero-arrow-down-tray" class="w-4 h-4 mr-1 shrink-0" />
                            {ch.original_file_name}
                          </a>
                        </td>
                        <td class="corp-td">
                          <!-- progress bar -->
                          <div class="flex items-center space-x-2 w-28">
                            <progress class="progress progress-success w-full" value="100" max="100"></progress>
                            <span class="text-xs text-gray-500 font-semibold">100%</span>
                          </div>
                        </td>
                        <td class="corp-td">
                          <span class="inline-flex items-center rounded-full bg-green-50 px-2 py-1 text-xs font-semibold text-green-700 border border-green-200">
                            Import Success
                          </span>
                        </td>
                        <td class="corp-td text-gray-500 font-medium">Import</td>
                        <td class="corp-td text-gray-600 whitespace-nowrap">
                          {format_datetime(ch.inserted_at)}
                        </td>
                      </tr>
                    <% end %>
                  <% end %>
                </tbody>
              </table>
            </div>

            <!-- Pagination component -->
            <%= if @total_pages > 1 do %>
              <.pagination
                page={@page}
                page_size={15}
                total_entries={@total_entries}
                total_pages={@total_pages}
                event="paginate"
                target={nil}
                class="bg-white"
              />
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  defp filter_list(items, query, limit) do
    if query == "" or is_nil(query) do
      Enum.take(items, limit)
    else
      query_lower = String.downcase(query)

      items
      |> Enum.filter(fn item -> String.contains?(String.downcase(item.name), query_lower) end)
      |> Enum.take(limit)
    end
  end
end
