defmodule CorporatePolicyWeb.Router do
  use CorporatePolicyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CorporatePolicyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_auth do
    plug CorporatePolicyWeb.Plugs.AuthPlug
  end

  # ─── Public routes ──────────────────────────────────────────────────────────
  scope "/", CorporatePolicyWeb do
    pipe_through :browser

    get "/", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # ─── Corporate public routes ────────────────────────────────────────────────
  scope "/corporate", CorporatePolicyWeb do
    pipe_through :browser

    get "/login", CorporateSessionController, :new
    post "/login", CorporateSessionController, :create
    delete "/logout", CorporateSessionController, :delete
  end

  # ─── Corporate authenticated routes ─────────────────────────────────────────
  scope "/corporate", CorporatePolicyWeb do
    pipe_through [:browser, :require_auth]

    live_session :corporate_authenticated, on_mount: [{CorporatePolicyWeb.LiveAuth, :default}] do
      live "/dashboard", CorporateDashboardLive
    end
  end

  # ─── Authenticated admin routes ─────────────────────────────────────────────
  scope "/admin", CorporatePolicyWeb do
    pipe_through [:browser, :require_auth]

    live_session :admin_authenticated, on_mount: [{CorporatePolicyWeb.LiveAuth, :default}] do
      live "/dashboard", DashboardLive
      live "/corporate", CorporateLive
      live "/corporate/new", CorporateNewLive
      live "/corporate/:id/edit", CorporateEditLive
      get "/corporate/export", CorporateExportController, :export
      live "/policy-details", PolicyDetailsLive, :index
      live "/policy-details/add", AddPolicyLive, :new
      live "/policy-details/:id/edit", AddPolicyLive, :edit
      live "/cd-statements", CdStatementsLive
      live "/roles-configuration", RolesConfigurationLive

      live "/users", UsersLive
      live "/corporate-employees", CorporateEmployeesLive
      live "/cashless-hospitals", CashlessHospitalsLive

      live "/escalation-matrix", EscalationMatrixAddLive, :new
      live "/escalation-matrix/add-user", EscalationMatrixAddLive, :new
      live "/escalation-matrix/edit-user/:id", EscalationMatrixAddLive, :edit
      live "/escalation-matrix/user-master", EscalationMatrixMasterLive, :index
      get "/escalation-matrix/export", EscalationMatrixExportController, :export

      live "/total-claim-reported", TotalClaimReportedLive
      live "/claims-intimation", ClaimsIntimationLive
      live "/claims-submission", ClaimsSubmissionLive
    end
  end

  # ─── API routes ─────────────────────────────────────────────────────────────
  scope "/api", CorporatePolicyWeb.Api, as: :api do
    pipe_through :api

    get "/get_visibility_role_id_tempalte", VisibilityRoleController, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:corporate_policy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CorporatePolicyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
