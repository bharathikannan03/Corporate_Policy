defmodule CorporatePolicyWeb.Employee.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias CorporatePolicy.EmployeePortal

  def on_mount(:default, _params, session, socket) do
    employee_id = session["current_employee_id"]
    user_id = session["current_user_id"]

    cond do
      not is_nil(user_id) ->
        {:halt, redirect(socket, to: "/employee/login")}

      is_nil(employee_id) ->
        {:halt, redirect(socket, to: "/employee/login")}

      true ->
        case EmployeePortal.get_authenticated_employee_session(employee_id) do
          {:ok, employee} ->
            {:cont,
             socket
             |> assign(:current_employee, employee)
             |> assign(:current_user, employee)}

          _ ->
            {:halt, redirect(socket, to: "/employee/login")}
        end
    end
  end
end
