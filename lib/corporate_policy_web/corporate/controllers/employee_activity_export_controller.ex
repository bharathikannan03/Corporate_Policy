defmodule CorporatePolicyWeb.Corporate.EmployeeActivityExportController do
  use CorporatePolicyWeb, :controller
  alias CorporatePolicy.Policies

  def export(conn, _params) do
    # Fetch the logged-in corporate user's corporate_id
    current_user = conn.assigns[:current_user]

    corporate_id =
      if current_user do
        current_user.ref_corporate_id
      else
        nil
      end

    if corporate_id do
      csv_data = Policies.export_employee_activity_csv(corporate_id)
      filename = "employee_activity_#{corporate_id}_#{Date.utc_today()}.csv"

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
      |> send_resp(200, csv_data)
    else
      conn
      |> put_flash(:error, "Unable to resolve corporate details for export.")
      |> redirect(to: ~p"/corporate/employee")
    end
  end
end
