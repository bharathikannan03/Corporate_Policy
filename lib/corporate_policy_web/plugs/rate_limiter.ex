defmodule CorporatePolicyWeb.Plugs.RateLimiter do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias CorporatePolicy.RateLimiter

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method == "POST" and
         conn.request_path in ["/admin/login", "/corporate/login", "/employee/login"] do
      case RateLimiter.check_rate(conn.remote_ip) do
        {:ok, _attempts_remaining} ->
          conn

        {:error, :rate_limited} ->
          redirect_path =
            cond do
              String.starts_with?(conn.request_path, "/admin") -> "/admin/login"
              String.starts_with?(conn.request_path, "/corporate") -> "/corporate/login"
              String.starts_with?(conn.request_path, "/employee") -> "/employee/login"
              true -> "/"
            end

          conn
          |> put_flash(:error, "Too many login attempts. Please try again in 1 minute.")
          |> redirect(to: redirect_path)
          |> halt()
      end
    else
      conn
    end
  end
end
