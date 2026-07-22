defmodule CorporatePolicyWeb.Employee.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  alias CorporatePolicy.EmployeePortal

  def on_mount(:default, _params, session, socket) do
    if employee_id = session["current_employee_id"] do
      case EmployeePortal.get_authenticated_employee_session(employee_id) do
        {:ok, employee} ->
          {:cont,
           socket
           |> assign(:current_employee, employee)
           |> assign(:current_user, employee)}

        _ ->
          {:halt, redirect(socket, to: "/employee/login")}
      end
    else
      {:halt, redirect(socket, to: "/employee/login")}
    end
  end
end
