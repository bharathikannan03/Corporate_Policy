defmodule CorporatePolicyWeb.Admin.UsersLive do
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
     |> assign(:page_title, "Users")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/users")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="coming-soon-wrapper" id="users-coming-soon">
        <div class="coming-soon-icon">
          <.icon name="hero-users" class="w-16 h-16 text-blue-400" />
        </div>

        <h1 class="coming-soon-title">Users</h1>

        <p class="coming-soon-text">This module is under development. Check back soon.</p>
      </div>
    </Layouts.admin>
    """
  end
end
