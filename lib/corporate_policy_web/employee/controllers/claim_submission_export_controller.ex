defmodule CorporatePolicyWeb.Employee.ClaimSubmissionExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Claims
  alias CorporatePolicy.EmployeePortal

  def export(conn, _params) do
    user =
      conn.assigns[:current_user] ||
        with employee_id when not is_nil(employee_id) <- get_session(conn, :current_employee_id),
             {:ok, employee} <- EmployeePortal.get_authenticated_employee_session(employee_id) do
          employee
        end

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
