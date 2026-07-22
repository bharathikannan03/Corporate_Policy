defmodule CorporatePolicyWeb.Corporate.EmployeeExportController do
  use CorporatePolicyWeb, :controller
  alias CorporatePolicy.Policies

  def export(conn, params) do
    policy_id = params["policy_id"] || params["id"]
    list_type = params["list_type"]

    {csv_data, filename} =
      if list_type && list_type != "" do
        data = Policies.export_policy_list_view_csv(policy_id, list_type)
        name = "policy_list_#{list_type}_#{policy_id || "all"}_#{Date.utc_today()}.csv"
        {data, name}
      else
        data = Policies.export_policy_employees_csv(policy_id)
        name = "policy_employees_#{policy_id || "all"}_#{Date.utc_today()}.csv"
        {data, name}
      end

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_resp(200, csv_data)
  end
end
