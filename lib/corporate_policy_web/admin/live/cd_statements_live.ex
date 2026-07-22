defmodule CorporatePolicyWeb.Admin.CdStatementsLive do
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
     |> assign(:page_title, "CD Statements")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/cd-statements")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="p-6">
        <div class="max-w-4xl mx-auto bg-base-100 rounded-box shadow-xl p-8">
          <h1 class="text-2xl font-semibold mb-3">CD Statements</h1>

          <p class="text-base-content/70 mb-6">
            Choose one of the CD Statements module options below.
          </p>

          <div class="flex flex-col gap-4 md:flex-row">
            <.link navigate={~p"/admin/cd-statements/cd-statement"} class="btn btn-primary">
              CD Statement
            </.link>

            <.link navigate={~p"/admin/cd-statements/cd-accounts"} class="btn btn-secondary">
              CD Accounts
            </.link>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end
end
