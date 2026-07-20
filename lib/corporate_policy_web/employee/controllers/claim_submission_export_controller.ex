defmodule CorporatePolicyWeb.Employee.ClaimSubmissionExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.Claims

  def export(conn, _params) do
    user = conn.assigns[:current_user] || Accounts.get_user(get_session(conn, :current_user_id))
    claims = Claims.list_claims_for_export(user, :employee)
    csv = Claims.to_csv(claims)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=claim-submissions-employee.csv"
    )
    |> send_resp(200, csv)
  end
end
