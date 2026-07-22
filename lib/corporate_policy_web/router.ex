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

  pipeline :admin_portal_enabled do
    plug :ensure_admin_portal_enabled
  end

  pipeline :corporate_portal_enabled do
    plug :ensure_corporate_portal_enabled
  end

  pipeline :employee_portal_enabled do
    plug :ensure_employee_portal_enabled
  end

  pipeline :admin_require_auth do
    plug CorporatePolicyWeb.Admin.Plugs.AuthPlug
  end

  pipeline :corporate_require_auth do
    plug CorporatePolicyWeb.Corporate.Plugs.AuthPlug
  end

  pipeline :employee_require_auth do
    plug CorporatePolicyWeb.Employee.Plugs.AuthPlug
  end

  case @portal do
    "admin" ->
      scope "/", CorporatePolicyWeb.Admin do
        pipe_through :browser

        get "/", SessionController, :new
      end

    "corp" ->
      scope "/", CorporatePolicyWeb.Corporate do
        pipe_through :browser

        get "/", CorporateSessionController, :new
      end

    "emp" ->
      scope "/", CorporatePolicyWeb.Employee do
        pipe_through :browser

        get "/", EmployeeSessionController, :new
      end

    _ ->
      scope "/", CorporatePolicyWeb.Admin do
        pipe_through :browser

        get "/", SessionController, :new
      end
  end

  scope "/admin", CorporatePolicyWeb.Admin, as: :admin do
    pipe_through [:browser, :admin_portal_enabled]

    get "/", SessionController, :new
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  scope "/admin", CorporatePolicyWeb.Admin, as: :admin do
    pipe_through [:browser, :admin_portal_enabled, :admin_require_auth]

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
      live "/policy-details/:policy_id/cd-statements/new", CdStatementUploadLive, :new
      live "/policy-details/:policy_id/cd-accounts/new", CdAccountsLive, :new
      live "/cd-statements/cd-statement", CdStatementUploadLive, :index
      live "/cd-statements/cd-accounts", CdAccountsLive, :index
      get "/policy-details/:policy_id/cd-statements/export", CdStatementExportController, :export
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
      live "/claims-submission", ClaimsSubmissionIndexLive, :index
      live "/claims-submission/add", ClaimSubmissionFormLive, :new
      live "/claims-submission/:id/edit", ClaimSubmissionFormLive, :edit
    end

    get "/total-claim-reported/export", TotalClaimReportedExportController, :export
    get "/claims-submission/export", ClaimSubmissionExportController, :export
  end

  scope "/corporate", CorporatePolicyWeb.Corporate, as: :corporate do
    pipe_through [:browser, :corporate_portal_enabled]

    get "/", CorporateSessionController, :new
    get "/login", CorporateSessionController, :new
    post "/login", CorporateSessionController, :create
    delete "/logout", CorporateSessionController, :delete
  end

  scope "/corporate", CorporatePolicyWeb.Corporate, as: :corporate do
    pipe_through [:browser, :corporate_portal_enabled, :corporate_require_auth]

    live_session :corporate_authenticated,
      on_mount: [{CorporatePolicyWeb.Corporate.LiveAuth, :default}],
      layout: {CorporatePolicyWeb.Layouts, :app} do
      live "/dashboard", DashboardLive
      live "/enrollment-details", EnrollmentDetailsLive
      live "/employee", EnrollmentDetailsLive
      live "/claims", ClaimsLive
      live "/escalation-matrix", EscalationMatrixLive
      live "/documents", DocumentsLive
      live "/claims-submission", ClaimsSubmissionIndexLive, :index
      live "/claims-submission/add", ClaimSubmissionFormLive, :new
      live "/claims-submission/:id/edit", ClaimSubmissionFormLive, :edit
    end

    get "/enrollment-details/export", EmployeeExportController, :export
    get "/claims/export", TotalClaimReportExportController, :export
    get "/claims-submission/export", ClaimSubmissionExportController, :export
  end

  scope "/employee", CorporatePolicyWeb.Employee, as: :employee do
    pipe_through [:browser, :employee_portal_enabled]

    get "/login", EmployeeSessionController, :new
    post "/login", EmployeeSessionController, :create
    delete "/logout", EmployeeSessionController, :delete
  end

  scope "/employee", CorporatePolicyWeb.Employee, as: :employee do
    pipe_through [:browser, :employee_portal_enabled, :employee_require_auth]

    live_session :employee_authenticated,
      on_mount: [{CorporatePolicyWeb.Employee.LiveAuth, :default}],
      layout: {CorporatePolicyWeb.Layouts, :app} do
      live "/", DashboardLive
      live "/dashboard", DashboardLive
      live "/my-coverages", CoveragesLive
      live "/members-covered", MembersLive
      live "/contact-matrix", ContactMatrixLive
      live "/network-hospital", ComingSoonLive, :network_hospital
      live "/download-forms", ComingSoonLive, :download_forms
      live "/claim-status", ComingSoonLive, :claim_status
      live "/intimate-claim", ComingSoonLive, :intimate_claim
      live "/claims-submission", ClaimsSubmissionIndexLive, :index
      live "/claims-submission/add", ClaimSubmissionFormLive, :new
      live "/claims-submission/:id/edit", ClaimSubmissionFormLive, :edit
    end

    get "/claims-submission/export", ClaimSubmissionExportController, :export
  end

  scope "/api", CorporatePolicyWeb.Api, as: :api do
    pipe_through :api

    get "/get_visibility_role_id_tempalte", VisibilityRoleController, :index
  end

  if Application.compile_env(:corporate_policy, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CorporatePolicyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp ensure_admin_portal_enabled(conn, _opts), do: ensure_portal_enabled(conn, "admin")
  defp ensure_corporate_portal_enabled(conn, _opts), do: ensure_portal_enabled(conn, "corp")
  defp ensure_employee_portal_enabled(conn, _opts), do: ensure_portal_enabled(conn, "emp")

  defp ensure_portal_enabled(conn, expected_portal) do
    active_portal = System.get_env("PORTAL", "all")

    if active_portal in [expected_portal, "all"] do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/")
      |> Plug.Conn.halt()
    end
  end
end
