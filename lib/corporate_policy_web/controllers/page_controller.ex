defmodule CorporatePolicyWeb.PageController do
  use CorporatePolicyWeb, :controller

  def home(conn, _params) do
    redirect(
      conn,
      to:
        case System.get_env("PORTAL", "all") do
          "emp" -> "/employee/login"
          "corp" -> "/corporate/login"
          "admin" -> "/admin/login"
          _ -> "/admin/login"
        end
    )
  end
end
