defmodule CorporatePolicyWeb.Employee.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias CorporatePolicy.EmployeePortal

  def init(opts), do: opts

  def call(conn, _opts) do
    employee_id = get_session(conn, :current_employee_id)
    user_id = get_session(conn, :current_user_id)

    cond do
      not is_nil(user_id) ->
        conn
        |> clear_session()
        |> put_flash(:error, "You must be logged in as an employee to access this page.")
        |> redirect(to: "/employee/login")
        |> halt()

      is_nil(employee_id) ->
        conn
        |> put_flash(:error, "You must be logged in to access this page.")
        |> redirect(to: "/employee/login")
        |> halt()

      true ->
        case EmployeePortal.get_authenticated_employee_session(employee_id) do
          {:ok, employee} ->
            conn
            |> assign(:current_employee, employee)
            |> assign(:current_user, employee)

          _ ->
            conn
            |> clear_session()
            |> put_flash(:error, "Session expired. Please log in again.")
            |> redirect(to: "/employee/login")
            |> halt()
        end
    end
  end
end
