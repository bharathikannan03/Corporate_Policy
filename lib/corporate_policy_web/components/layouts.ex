defmodule CorporatePolicyWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CorporatePolicyWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block

  def app(assigns) do
    ~H"""
    <%= if assigns[:inner_content] do %>
      {@inner_content}
    <% else %>
      {render_slot(@inner_block)}
    <% end %>
     <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the admin layout with sidebar navigation and top header.
  Used by all authenticated admin LiveViews.
  """
  attr :flash, :map, required: true
  attr :current_user, :map, default: nil
  attr :active_path, :string, default: "/admin/dashboard"

  slot :inner_block

  def admin(assigns) do
    ~H"""
    <div class="admin-layout">
      <style>
        .policy-table-wrapper {
          background: #ffffff;
          border-radius: 0.75rem;
          border: 1px solid #292524 !important;
          overflow: hidden;
          box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
        }
        .policy-table {
          width: 100%;
          text-align: left;
          border-collapse: collapse;
          background: #ffffff;
        }
        .policy-table thead tr {
          background-color: #f3f4f6;
          border-bottom: 1px solid #292524 !important;
        }
        .policy-table th {
          padding: 1rem 1.5rem;
          font-size: 0.75rem;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.05em;
          color: #292524 !important;
        }
        .policy-table tbody tr {
          border-bottom: 1px solid #292524 !important;
          transition: background-color 0.15s ease;
        }
        .policy-table tbody tr:last-child {
          border-bottom: none;
        }
        .policy-table tbody tr:hover {
          background-color: #f8fafc;
        }
        .policy-table td {
          padding: 1rem 1.5rem;
          font-size: 0.875rem;
          color: #292524 !important;
        }
        .admin-main { color: #1e293b !important; }
      </style>
       <%!-- Sidebar --%>
      <aside class="admin-sidebar" id="admin-sidebar">
        <%!-- Brand --%>
        <div class="sidebar-brand">
          <div class="brand-logo">
            <span class="brand-icon">🛡️</span>
          </div>
          
          <div class="brand-text">
            <span class="brand-name">CorpPolicy</span> <span class="brand-tagline">Admin Portal</span>
          </div>
        </div>
         <%!-- User info --%>
        <div class="sidebar-user">
          <div class="user-avatar">
            <.icon name="hero-user-circle" class="w-10 h-10 text-blue-200" />
          </div>
          
          <div class="user-info">
            <p class="user-name">
              {if @current_user,
                do: "#{@current_user.first_name} #{@current_user.last_name}",
                else: "Admin"}
            </p>
          </div>
          
          <div class="user-actions">
            <.link
              href={~p"/admin/logout"}
              method="delete"
              id="logout-link"
              class="logout-btn"
            >
              <.icon name="hero-power" class="w-4 h-4" />
            </.link>
          </div>
        </div>
         <%!-- Navigation --%>
        <nav class="sidebar-nav" id="sidebar-nav">
          <.sidebar_item
            icon="hero-squares-2x2"
            label="Dashboard"
            href={~p"/admin/dashboard"}
            active={@active_path == "/admin/dashboard"}
          />
          <.sidebar_group
            icon="hero-building-office-2"
            label="Corporate"
            open={String.starts_with?(@active_path, "/admin/corporate")}
          >
            <.sidebar_child_item
              label="All Corporates"
              href={~p"/admin/corporate"}
              active={@active_path == "/admin/corporate"}
              id="sidebar-all-corporates"
            />
            <.sidebar_child_item
              label="Add Corporate"
              href={~p"/admin/corporate/new"}
              active={@active_path == "/admin/corporate/new"}
              id="sidebar-add-corporate"
            />
          </.sidebar_group>
          
          <.sidebar_group
            icon="hero-document-text"
            label="Policy Details"
            open={String.starts_with?(@active_path, "/admin/policy-details")}
          >
            <.sidebar_child_item
              label="All Policies"
              href={~p"/admin/policy-details"}
              active={@active_path == "/admin/policy-details"}
              id="sidebar-all-policies"
            />
            <.sidebar_child_item
              label="Add Policy"
              href={~p"/admin/policy-details/add"}
              active={@active_path == "/admin/policy-details/add"}
              id="sidebar-add-policy"
            />
          </.sidebar_group>
          
          <.sidebar_group
            icon="hero-banknotes"
            label="CD Statements"
            open={String.starts_with?(@active_path, "/admin/cd-statements")}
          >
            <.sidebar_child_item
              label="CD Statement"
              href={~p"/admin/cd-statements/cd-statement"}
              active={@active_path == "/admin/cd-statements/cd-statement"}
              id="sidebar-cd-statement"
            />
            <.sidebar_child_item
              label="CD Accounts"
              href={~p"/admin/cd-statements/cd-accounts"}
              active={@active_path == "/admin/cd-statements/cd-accounts"}
              id="sidebar-cd-accounts"
            />
          </.sidebar_group>
          
          <.sidebar_group
            icon="hero-cog-6-tooth"
            label="Roles Configuration"
            open={String.starts_with?(@active_path, "/admin/roles-configuration")}
          >
            <.sidebar_child_item
              label="Roles List"
              href={~p"/admin/roles-configuration/list"}
              active={
                @active_path in ["/admin/roles-configuration", "/admin/roles-configuration/list"]
              }
              id="sidebar-roles-list"
            />
            <.sidebar_child_item
              label="Add Role"
              href={~p"/admin/roles-configuration/add"}
              active={@active_path == "/admin/roles-configuration/add"}
              id="sidebar-roles-add"
            />
          </.sidebar_group>
          
          <.sidebar_item
            icon="hero-users"
            label="Users"
            href={~p"/admin/users"}
            active={@active_path == "/admin/users"}
          />
          <.sidebar_item
            icon="hero-user-group"
            label="Corporate Employees"
            href={~p"/admin/corporate-employees"}
            active={@active_path == "/admin/corporate-employees"}
          />
          <.sidebar_item
            icon="hero-building-office"
            label="Cashless Hospitals"
            href={~p"/admin/cashless-hospitals"}
            active={@active_path == "/admin/cashless-hospitals"}
          />
          <.sidebar_group
            icon="hero-chart-bar"
            label="Escalation Matrix"
            open={String.starts_with?(@active_path, "/admin/escalation-matrix")}
          >
            <.sidebar_child_item
              label="Add User"
              href={~p"/admin/escalation-matrix/add-user"}
              active={
                @active_path == "/admin/escalation-matrix/add-user" ||
                  @active_path == "/admin/escalation-matrix"
              }
              id="sidebar-escalation-matrix-add-user"
            />
            <.sidebar_child_item
              label="User Master"
              href={~p"/admin/escalation-matrix/user-master"}
              active={@active_path == "/admin/escalation-matrix/user-master"}
              id="sidebar-escalation-matrix-user-master"
            />
          </.sidebar_group>
          
          <.sidebar_item
            icon="hero-clipboard-document-list"
            label="Total Claim Reported"
            href={~p"/admin/total-claim-reported"}
            active={@active_path == "/admin/total-claim-reported"}
          />
          <.sidebar_item
            icon="hero-bell-alert"
            label="Claims Intimation"
            href={~p"/admin/claims-intimation"}
            active={@active_path == "/admin/claims-intimation"}
          />
          <.sidebar_group
            icon="hero-paper-airplane"
            label="Claims Submission"
            open={String.starts_with?(@active_path, "/admin/claims-submission")}
          >
            <.sidebar_child_item
              label="All Submissions"
              href={~p"/admin/claims-submission"}
              active={@active_path == "/admin/claims-submission"}
              id="sidebar-claims-submission-all"
            />
            <.sidebar_child_item
              label="Add Claim"
              href={~p"/admin/claims-submission/add"}
              active={@active_path == "/admin/claims-submission/add"}
              id="sidebar-claims-submission-add"
            />
          </.sidebar_group>
        </nav>
      </aside>
       <%!-- Main content area --%>
      <div class="admin-main">
        <%!-- Top header --%>
        <header class="admin-topbar">
          <div class="topbar-left">
            <h2 class="topbar-title">Admin Portal</h2>
          </div>
          
          <div class="topbar-right">
            <div class="topbar-user">
              <.icon name="hero-user-circle" class="w-6 h-6 text-gray-500" />
              <span class="topbar-username">
                Welcome, {if @current_user,
                  do: "#{@current_user.first_name} #{@current_user.last_name}",
                  else: "Admin"}
              </span>
              
              <.link
                href={~p"/admin/logout"}
                method="delete"
                id="topbar-logout"
                class="topbar-logout"
              >
                <.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" />
              </.link>
            </div>
          </div>
        </header>
         <%!-- Page content --%>
        <main class="admin-content">
          <%= if assigns[:inner_content] do %>
            {@inner_content}
          <% else %>
            {render_slot(@inner_block)}
          <% end %>
        </main>
      </div>
    </div>
    """
  end

  @doc """
  Renders the corporate portal layout with sidebar navigation, top bar,
  and header for Corporate Name, Policy Types, and Policy Numbers.
  Used by corporate LiveViews.
  """
  attr :flash, :map, required: true
  attr :current_user, :map, default: nil
  attr :corporate, :map, default: nil
  attr :corporate_name, :string, default: "Corporate Portal"
  attr :financial_years, :list, default: []
  attr :current_fy_name, :string, default: "2025-2026"
  attr :policy_types, :list, default: []
  attr :active_policy_type, :string, default: nil
  attr :policy_numbers, :list, default: []
  attr :active_policy_number, :string, default: nil
  attr :active_path, :string, default: "/corporate/dashboard"
  attr :show_policy_numbers, :boolean, default: true
  attr :allowed_modules, :any, default: nil

  slot :inner_block

  def corporate(assigns) do
    allowed_modules =
      assigns[:allowed_modules] ||
        if user = assigns[:current_user] do
          CorporatePolicy.Corporates.get_allowed_modules(user.department_id)
        else
          :all
        end

    assigns = assign(assigns, :allowed_modules, allowed_modules)

    ~H"""
    <div class="corp-portal-wrapper">
      <%!-- Left Sidebar --%>
      <aside class="corp-portal-sidebar">
        <%!-- Brand Logo --%>
        <div class="corp-sidebar-brand">
          <div class="vibe-logo-text flex items-center">
            <span class="vibe-v">V</span> <span class="vibe-i">I</span> <span class="vibe-b">B</span>
            <span class="vibe-e">E</span>
          </div>
          
          <div class="vibe-tagline">
            An Initiative By Intermedia
          </div>
        </div>
         <%!-- Corporate Profile Card --%>
        <div class="corp-sidebar-user">
          <div class="corp-user-avatar">
            <.icon name="hero-user" class="w-10 h-10" />
          </div>
          
          <h2 class="corp-user-name">
            {@corporate_name}
          </h2>
           <span class="corp-user-role">Corporate</span> <%!-- Action Icons --%>
          <div class="corp-user-actions">
            <button type="button" class="corp-action-circle">
              <.icon name="hero-user" class="w-3.5 h-3.5" />
            </button>
            
            <.link
              href={~p"/corporate/logout"}
              method="delete"
              class="corp-action-circle corp-action-circle--logout"
            >
              <.icon name="hero-power" class="w-3.5 h-3.5" />
            </.link>
            
            <button type="button" class="corp-action-circle">
              <.icon name="hero-envelope" class="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
         <%!-- Sidebar Menu --%>
        <nav class="corp-sidebar-nav">
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 1)}
            icon="hero-squares-2x2"
            label="Dashboard"
            href={~p"/corporate/dashboard"}
            active={@active_path == "/corporate/dashboard"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 2)}
            icon="hero-calendar"
            label="Enrollment"
            href={~p"/corporate/enrollment-details"}
            active={String.starts_with?(@active_path, "/corporate/enrollment")}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 3)}
            icon="hero-clipboard-document-list"
            label="Claims"
            href={~p"/corporate/claims"}
            active={String.starts_with?(@active_path, "/corporate/claims")}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 4)}
            icon="hero-building-office"
            label="Cashless Hospitals"
            href={~p"/corporate/cashless-hospitals"}
            active={@active_path == "/corporate/cashless-hospitals"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 5)}
            icon="hero-chart-bar"
            label="Escalation Matrix"
            href={~p"/corporate/escalation-matrix"}
            active={@active_path == "/corporate/escalation-matrix"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 6)}
            icon="hero-document-text"
            label="Policy Features"
            href={~p"/corporate/policy-features"}
            active={@active_path == "/corporate/policy-features"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 7)}
            icon="hero-document-duplicate"
            label="Documents"
            href={~p"/corporate/documents"}
            active={@active_path == "/corporate/documents"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 8) or show_module?(@allowed_modules, 9)}
            icon="hero-document-check"
            label="CD & Endorsement"
            href="#"
            active={@active_path == "/corporate/cd-endorsement"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 10)}
            icon="hero-user-group"
            label="Employee"
            href={~p"/corporate/employee"}
            active={@active_path == "/corporate/employee"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 13)}
            icon="hero-calculator"
            label="Endorsement Calculation"
            href="#"
            active={@active_path == "/corporate/endorsement-calc"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 11)}
            icon="hero-chart-pie"
            label="Reports"
            href="#"
            active={@active_path == "/corporate/reports"}
          />
          <.corp_nav_item
            :if={show_module?(@allowed_modules, 12)}
            icon="hero-document"
            label="Summary"
            href="#"
            active={@active_path == "/corporate/summary"}
          />
        </nav>
      </aside>
       <%!-- Main Content Area --%>
      <div class="flex-1 flex flex-col min-w-0">
        <%!-- Top Header Bar --%>
        <header class="corp-top-bar">
          <div class="flex items-center space-x-3">
            <form phx-change="change_fy" id="corp-fy-form">
              <select name="fy_name" class="corp-select-sm">
                <%= for fy <- @financial_years do %>
                  <option value={fy.year_name} selected={fy.year_name == @current_fy_name}>
                    {fy.year_name}
                  </option>
                <% end %>
                
                <%= if @financial_years == [] do %>
                  <option value={@current_fy_name} selected>{@current_fy_name}</option>
                <% end %>
              </select>
            </form>
            
            <select name="language" class="corp-select-sm">
              <option value="en">Select Language</option>
            </select>
          </div>
          
          <div class="flex items-center space-x-4">
            <button type="button" class="text-white hover:opacity-80">
              <.icon name="hero-bell" class="w-5 h-5" />
            </button>
            
            <div class="flex items-center space-x-2 text-xs font-semibold text-white">
              <div class="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center">
                <.icon name="hero-user" class="w-4 h-4 text-white" />
              </div>
              
              <span>
                {if @current_user,
                  do: String.upcase("#{@current_user.first_name} #{@current_user.last_name}"),
                  else: "RICHIE JOSEPH"}
              </span>
               <.icon name="hero-chevron-down" class="w-3 h-3 text-white" />
            </div>
          </div>
        </header>
         <%!-- Header Banner (Welcome + Corporate Name + Policy Types) --%>
        <div class="corp-welcome-banner">
          <h1 class="corp-welcome-title">Hi, Welcome back!</h1>
           <%!-- Corporate Name & Policy Types Card --%>
          <div class="corp-header-card">
            <div class="corp-title-text">
              {@corporate_name}
              <span class="corp-title-fy">(Financial Year: {@current_fy_name})</span>
            </div>
             <%!-- Policy Type Tabs --%>
            <div class="corp-policy-types-row">
              <%= for pt <- @policy_types do %>
                <button
                  type="button"
                  phx-click="select_policy_type"
                  phx-value-type={pt}
                  class={[
                    "corp-policy-type-tab",
                    pt == @active_policy_type && "corp-policy-type-tab--active"
                  ]}
                >
                  <span>{pt}</span> <.icon name="hero-sparkles" class="w-3.5 h-3.5 text-blue-500" />
                </button>
              <% end %>
            </div>
          </div>
        </div>
         <%!-- Policy Number Pills Row --%>
        <div :if={@show_policy_numbers and @policy_numbers != []} class="corp-policy-numbers-bar">
          <div class="flex items-center space-x-4 text-xs font-bold">
            <%= for pn <- @policy_numbers do %>
              <button
                type="button"
                phx-click="select_policy_number"
                phx-value-number={pn}
                class={[
                  "corp-policy-number-tab",
                  pn == @active_policy_number && "font-bold text-blue-600 border-blue-600",
                  pn != @active_policy_number &&
                    "text-gray-600 border-transparent hover:text-blue-500"
                ]}
              >
                {pn}
              </button>
            <% end %>
          </div>
        </div>
         <%!-- Page Specific Body --%>
        <main class="flex-1 p-6 overflow-y-auto">
          <%= if assigns[:inner_content] do %>
            {@inner_content}
          <% else %>
            {render_slot(@inner_block)}
          <% end %>
        </main>
      </div>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :href, :string, required: true
  attr :active, :boolean, default: false

  defp corp_nav_item(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "corp-nav-link",
        @active && "corp-nav-link--active"
      ]}
    >
      <.icon name={@icon} class="w-4 h-4" /> <span>{@label}</span>
    </.link>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :href, :string, required: true
  attr :active, :boolean, default: false

  defp sidebar_item(assigns) do
    ~H"""
    <.link
      navigate={@href}
      id={"sidebar-#{String.replace(@label, " ", "-") |> String.downcase()}"}
      class={[
        "sidebar-nav-item",
        @active && "sidebar-nav-item--active"
      ]}
    >
      <.icon name={@icon} class="sidebar-nav-icon" /> <span class="sidebar-nav-label">{@label}</span>
    </.link>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :open, :boolean, default: false
  slot :inner_block, required: true

  defp sidebar_group(assigns) do
    group_id = String.replace(String.downcase(assigns.label), " ", "-")
    assigns = assign(assigns, :group_id, group_id)

    ~H"""
    <div
      class={["sidebar-group", @open && "sidebar-group--open"]}
      id={"group-#{@group_id}"}
    >
      <button
        type="button"
        id={"group-toggle-#{@group_id}"}
        class="sidebar-group-header"
        phx-click={
          JS.toggle(to: "#group-children-#{@group_id}")
          |> JS.toggle_class("sidebar-group--open", to: "#group-#{@group_id}")
        }
      >
        <span class="sidebar-group-header-left">
          <.icon name={@icon} class="sidebar-nav-icon" />
          <span class="sidebar-nav-label">{@label}</span>
        </span>
         <.icon name="hero-chevron-right" class="sidebar-group-chevron" />
      </button>
      
      <div
        id={"group-children-#{@group_id}"}
        class="sidebar-group-children"
        style={if @open, do: "display:block", else: "display:none"}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :href, :string, required: true
  attr :active, :boolean, default: false
  attr :id, :string, required: true

  defp sidebar_child_item(assigns) do
    ~H"""
    <.link
      navigate={@href}
      id={@id}
      class={["sidebar-child-item", @active && "sidebar-child-item--active"]}
    >
      <span class="sidebar-child-dot"></span> {@label}
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} /> <.flash kind={:error} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
      
      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />
      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      
      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
      
      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  defp show_module?(allowed_modules, module_id) do
    case allowed_modules do
      :all -> true
      list when is_list(list) -> Enum.member?(list, module_id)
      _ -> true
    end
  end
end
