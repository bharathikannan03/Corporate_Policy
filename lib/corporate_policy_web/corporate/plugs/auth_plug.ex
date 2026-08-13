defmodule CorporatePolicyWeb.Corporate.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias CorporatePolicy.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user_id)
    employee_id = get_session(conn, :current_employee_id)

    cond do
      not is_nil(employee_id) ->
        conn
        |> clear_session()
        |> put_flash(:error, "You must be logged in to access the corporate portal.")
        |> redirect(to: "/corporate/login")
        |> halt()

      is_nil(user_id) ->
        conn
        |> put_flash(:error, "You must be logged in to access the corporate portal.")
        |> redirect(to: "/corporate/login")
        |> halt()

      user = Accounts.get_user(user_id) ->
        if Accounts.corporate_user?(user) do
          assign(conn, :current_user, user)
        else
          conn
          |> clear_session()
          |> put_flash(:error, "Unauthorized access. You must be logged in as a corporate user.")
          |> redirect(to: "/corporate/login")
          |> halt()
        end

      true ->
        conn
        |> clear_session()
        |> put_flash(:error, "Session expired. Please log in again.")
        |> redirect(to: "/corporate/login")
        |> halt()
    end
  end
end
