defmodule CorporatePolicyWeb.Corporate.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component
  alias CorporatePolicy.Accounts

  def on_mount(:default, _params, session, socket) do
    user_id = session["current_user_id"]
    employee_id = session["current_employee_id"]

    cond do
      not is_nil(employee_id) ->
        {:halt, redirect(socket, to: "/corporate/login")}

      is_nil(user_id) ->
        {:halt, redirect(socket, to: "/corporate/login")}

      user = Accounts.get_user(user_id) ->
        if Accounts.corporate_user?(user) do
          {:cont, assign(socket, :current_user, user)}
        else
          {:halt, redirect(socket, to: "/corporate/login")}
        end

      true ->
        {:halt, redirect(socket, to: "/corporate/login")}
    end
  end
end
