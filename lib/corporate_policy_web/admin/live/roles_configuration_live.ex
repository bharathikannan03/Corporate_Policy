defmodule CorporatePolicyWeb.Admin.RolesConfigurationLive do
  use CorporatePolicyWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user =
      case session["current_user_id"] do
        nil -> nil
        id -> CorporatePolicy.Accounts.get_user(id)
      end

    {:ok,
     socket
     |> assign(:page_title, "Roles Configuration")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/roles-configuration")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="coming-soon-wrapper" id="roles-config-coming-soon">
        <div class="coming-soon-icon">
          <.icon name="hero-cog-6-tooth" class="w-16 h-16 text-blue-400" />
        </div>

        <h1 class="coming-soon-title">Roles Configuration</h1>

        <p class="coming-soon-text">This module is under development. Check back soon.</p>
      </div>
    </Layouts.admin>
    """
  end
end
