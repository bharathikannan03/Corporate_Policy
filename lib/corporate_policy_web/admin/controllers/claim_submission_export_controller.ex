defmodule CorporatePolicyWeb.Admin.ClaimSubmissionExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Claims

  def export(conn, _params) do
    user = conn.assigns.current_user
    claims = Claims.list_claims_for_export(user, :admin)
    csv = Claims.to_csv(claims)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=claim-submissions-admin.csv")
    |> send_resp(200, csv)
  end
end
