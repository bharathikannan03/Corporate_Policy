defmodule CorporatePolicyWeb.Corporate.Plugs.AuthPlug do
  @moduledoc """
  Ensures the corporate user is authenticated before accessing protected corporate routes.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias CorporatePolicy.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user_id)

    cond do
      is_nil(user_id) ->
        conn
        |> put_flash(:error, "You must be logged in to access the corporate portal.")
        |> redirect(to: "/corporate/login")
        |> halt()

      user = Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        conn
        |> clear_session()
        |> put_flash(:error, "Session expired. Please log in again.")
        |> redirect(to: "/corporate/login")
        |> halt()
    end
  end
end
