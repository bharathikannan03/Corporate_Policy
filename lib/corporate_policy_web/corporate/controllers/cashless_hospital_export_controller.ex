defmodule CorporatePolicyWeb.Corporate.CashlessHospitalExportController do
  use CorporatePolicyWeb, :controller
  alias CorporatePolicy.Policies

  def export(conn, params) do
    tpa_id = params["tpa_id"]
    search = params["search"] || ""

    csv_data = Policies.export_cashless_hospitals_csv(tpa_id, search)
    filename = "cashless_hospitals_#{tpa_id || "all"}_#{Date.utc_today()}.csv"

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_resp(200, csv_data)
  end
end
