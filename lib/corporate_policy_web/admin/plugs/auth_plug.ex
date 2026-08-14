defmodule CorporatePolicyWeb.Admin.Plugs.AuthPlug do
  @moduledoc """
  Ensures the admin user is authenticated before accessing protected admin routes.
  Loads the current user from the session and assigns it to the connection.
  """
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
        |> put_flash(:error, "You must be logged in as an admin to access this page.")
        |> redirect(to: "/admin/login")
        |> halt()

      is_nil(user_id) ->
        conn
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: "/admin/login")
        |> halt()

      user = Accounts.get_user(user_id) ->
        if Accounts.admin_user?(user) and user.status == 1 do
          assign(conn, :current_user, user)
        else
          flash_msg =
            if user.status != 1,
              do: "Your account is inactive or disabled.",
              else: "Unauthorized access. You must be logged in as an admin."

          conn
          |> clear_session()
          |> put_flash(:error, flash_msg)
          |> redirect(to: "/admin/login")
          |> halt()
        end

      true ->
        conn
        |> clear_session()
        |> put_flash(:error, "Session expired. Please log in again.")
        |> redirect(to: "/admin/login")
        |> halt()
    end
  end
end
