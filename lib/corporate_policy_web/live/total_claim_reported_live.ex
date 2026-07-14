defmodule CorporatePolicyWeb.TotalClaimReportedLive do
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
     |> assign(:page_title, "Total Claim Reported")
     |> assign(:current_user, current_user)
     |> assign(:active_path, "/admin/total-claim-reported")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_user={@current_user} active_path={@active_path}>
      <div class="coming-soon-wrapper" id="total-claim-reported-coming-soon">
        <div class="coming-soon-icon">
          <.icon name="hero-clipboard-document-list" class="w-16 h-16 text-blue-400" />
        </div>
        
        <h1 class="coming-soon-title">Total Claim Reported</h1>
        
        <p class="coming-soon-text">This module is under development. Check back soon.</p>
      </div>
    </Layouts.admin>
    """
  end
end
