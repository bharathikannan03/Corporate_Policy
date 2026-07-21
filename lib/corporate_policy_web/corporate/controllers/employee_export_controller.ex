defmodule CorporatePolicyWeb.Corporate.EmployeeExportController do
  use CorporatePolicyWeb, :controller
  alias CorporatePolicy.Policies

  def export(conn, params) do
    policy_id = params["policy_id"] || params["id"]
    csv_data = Policies.export_policy_employees_csv(policy_id)

    filename = "policy_employees_#{policy_id || "all"}_#{Date.utc_today()}.csv"

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_resp(200, csv_data)
  end
end
