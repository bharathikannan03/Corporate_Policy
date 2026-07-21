defmodule CorporatePolicyWeb.Router do
  use CorporatePolicyWeb, :router

  @portal System.get_env("PORTAL", "all")

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

  pipeline :admin_require_auth do
    plug CorporatePolicyWeb.Admin.Plugs.AuthPlug
  end

  # ─── Public Root Route ──────────────────────────────────────────────────────
  scope "/", CorporatePolicyWeb.Admin do
    pipe_through :browser

    get "/", SessionController, :new
  end

  # ─── 1. Admin Portal Routes ────────────────────────────────────────────────
  if @portal in ["admin", "all"] do
    scope "/admin", CorporatePolicyWeb.Admin, as: :admin do
      pipe_through :browser

      get "/", SessionController, :new
      get "/login", SessionController, :new
      post "/login", SessionController, :create
      delete "/logout", SessionController, :delete
    end

    scope "/admin", CorporatePolicyWeb.Admin, as: :admin do
      pipe_through [:browser, :admin_require_auth]

      live_session :admin_authenticated,
        on_mount: [{CorporatePolicyWeb.Admin.LiveAuth, :default}],
        layout: {CorporatePolicyWeb.Layouts, :app} do
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
  end

  pipeline :corp_require_auth do
    plug CorporatePolicyWeb.Corporate.Plugs.AuthPlug
  end

  # ─── 2. Corporate Portal Scope ───────────────────────────────────────────
  if @portal in ["corp", "all"] do
    scope "/corporate", CorporatePolicyWeb.Corporate, as: :corporate do
      pipe_through :browser

      get "/", CorporateSessionController, :new
      get "/login", CorporateSessionController, :new
      post "/login", CorporateSessionController, :create
      delete "/logout", CorporateSessionController, :delete
    end

    scope "/corporate", CorporatePolicyWeb.Corporate, as: :corporate do
      pipe_through [:browser, :corp_require_auth]

      live_session :corporate_authenticated,
        on_mount: [{CorporatePolicyWeb.Corporate.LiveAuth, :default}],
        layout: {CorporatePolicyWeb.Layouts, :app} do
        live "/dashboard", DashboardLive
      end
    end
  end

  # ─── 3. Employee Portal Scope (Placeholder) ───────────────────────────────
  if @portal in ["emp", "all"] do
    scope "/employee", CorporatePolicyWeb.Employee, as: :employee do
      pipe_through :browser

      # Future Employee Portal routes go here
    end
  end

  # ─── API routes ─────────────────────────────────────────────────────────────
  scope "/api", CorporatePolicyWeb.Api, as: :api do
    pipe_through :api

    get "/get_visibility_role_id_tempalte", VisibilityRoleController, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:corporate_policy, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CorporatePolicyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
