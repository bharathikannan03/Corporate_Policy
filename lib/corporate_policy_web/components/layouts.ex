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

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main>
      {render_slot(@inner_block)}
    </main>
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

  slot :inner_block, required: true

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

            <p class="user-role">Vibe Admin</p>
          </div>

          <div class="user-actions">
            <.link
              href={~p"/logout"}
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

          <.sidebar_dropdown
            icon="hero-document-text"
            label="Policy Details"
            active={@active_path =~ ~r{^/admin/policy-details}}
            id="policy-details-dropdown"
          >
            <.sidebar_dropdown_item
              label="All Policies"
              href={~p"/admin/policy-details"}
              active={@active_path == "/admin/policy-details"}
            />
            <.sidebar_dropdown_item
              label="Add Policy"
              href={~p"/admin/policy-details/add"}
              active={@active_path == "/admin/policy-details/add"}
            />
          </.sidebar_dropdown>

          <.sidebar_item
            icon="hero-banknotes"
            label="CD Statements"
            href={~p"/admin/cd-statements"}
            active={@active_path == "/admin/cd-statements"}
          />
          <.sidebar_item
            icon="hero-cog-6-tooth"
            label="Roles Configuration"
            href={~p"/admin/roles-configuration"}
            active={@active_path == "/admin/roles-configuration"}
          />
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
          <.sidebar_item
            icon="hero-paper-airplane"
            label="Claims Submission"
            href={~p"/admin/claims-submission"}
            active={@active_path == "/admin/claims-submission"}
          />
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
                href={~p"/logout"}
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
          <.flash_group flash={@flash} /> {render_slot(@inner_block)}
        </main>
      </div>
    </div>
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
  attr :active, :boolean, default: false
  attr :id, :string, required: true

  slot :inner_block, required: true

  def sidebar_dropdown(assigns) do
    ~H"""
    <div
      class={[
        "sidebar-dropdown",
        @active && "open"
      ]}
      phx-hook="SidebarDropdown"
      id={@id}
    >
      <button
        type="button"
        class={[
          "sidebar-nav-item sidebar-dropdown-toggle",
          @active && "sidebar-nav-item--active"
        ]}
      >
        <.icon name={@icon} class="sidebar-nav-icon" />
        <span class="sidebar-nav-label">{@label}</span>
        <.icon name="hero-chevron-down" class="sidebar-dropdown-chevron" />
      </button>

      <div class="sidebar-dropdown-menu">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :href, :string, required: true
  attr :active, :boolean, default: false

  defp sidebar_dropdown_item(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "sidebar-dropdown-item",
        @active && "sidebar-dropdown-item--active"
      ]}
    >
      {@label}
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
end
