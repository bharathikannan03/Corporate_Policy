defmodule CorporatePolicyWeb.Employee.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias CorporatePolicy.Accounts

  def on_mount(:default, _params, session, socket) do
    if user_id = session["current_user_id"] do
      if user = Accounts.get_user(user_id) do
        {:cont, assign(socket, :current_user, user)}
      else
        {:halt, redirect(socket, to: "/employee/login")}
      end
    else
      {:halt, redirect(socket, to: "/employee/login")}
    end
  end
end
