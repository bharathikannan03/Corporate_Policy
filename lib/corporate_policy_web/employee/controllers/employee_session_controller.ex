defmodule CorporatePolicyWeb.Employee.EmployeeSessionController do
  use CorporatePolicyWeb, :controller

  import Phoenix.Component, only: [to_form: 2]

  alias CorporatePolicy.EmployeePortal

  def new(conn, _params) do
    form = to_form(%{}, as: :employee_auth)
    render(conn, :new, page_title: "Employee Login", form: form, otp_sent: false)
  end

  def create(conn, %{"employee_auth" => params}) do
    mobile_number = EmployeePortal.normalize_mobile_number(params["mobile_number"])

    form =
      to_form(%{"mobile_number" => mobile_number, "otp" => params["otp"]}, as: :employee_auth)

    case params["action"] do
      "request_otp" ->
        request_otp(conn, mobile_number, form)

      "login" ->
        login_with_otp(conn, mobile_number, params["otp"], form)

      _ ->
        conn
        |> put_flash(:error, "Invalid employee login request.")
        |> render(:new, page_title: "Employee Login", form: form, otp_sent: false)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Signed out")
    |> redirect(to: ~p"/employee/login")
  end

  defp request_otp(conn, mobile_number, form) do
    cond do
      not EmployeePortal.valid_mobile_number?(mobile_number) ->
        conn
        |> put_flash(:error, "Enter a valid 10-digit mobile number.")
        |> render(:new, page_title: "Employee Login", form: form, otp_sent: false)

      employee = EmployeePortal.eligible_employee_by_mobile(mobile_number) ->
        otp = EmployeePortal.generate_otp()

        expires_at =
          DateTime.utc_now() |> DateTime.add(EmployeePortal.otp_expiry_minutes() * 60, :second)

        :ok = EmployeePortal.send_otp(mobile_number, otp)

        conn
        |> put_session(:employee_login_otp, otp)
        |> put_session(:employee_login_mobile, mobile_number)
        |> put_session(:employee_login_employee_id, employee.id)
        |> put_session(:employee_login_otp_expires_at, DateTime.to_iso8601(expires_at))
        |> put_flash(
          :info,
          "OTP sent successfully. Use default OTP #{EmployeePortal.default_otp()}."
        )
        |> render(:new, page_title: "Employee Login", form: form, otp_sent: true)

      true ->
        conn
        |> put_flash(
          :error,
          "Mobile number is not mapped to an active employee/self record for the employee portal."
        )
        |> render(:new, page_title: "Employee Login", form: form, otp_sent: false)
    end
  end

  defp login_with_otp(conn, mobile_number, otp, form) do
    with true <- mobile_number == get_session(conn, :employee_login_mobile),
         true <- valid_otp_session?(conn),
         true <-
           to_string(get_session(conn, :employee_login_otp)) == String.trim(to_string(otp || "")),
         employee_id when not is_nil(employee_id) <-
           get_session(conn, :employee_login_employee_id),
         {:ok, employee} <- EmployeePortal.get_authenticated_employee_session(employee_id) do
      _ = EmployeePortal.log_employee_login(employee.id, conn)

      conn
      |> configure_session(renew: true)
      |> clear_employee_login_session()
      |> delete_session(:current_user_id)
      |> put_session(:current_employee_id, employee.employee_id)
      |> put_flash(:info, "Welcome back!")
      |> redirect(to: ~p"/employee/dashboard")
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid or expired OTP. Please request a new OTP and try again.")
        |> render(:new, page_title: "Employee Login", form: form, otp_sent: true)
    end
  end

  defp valid_otp_session?(conn) do
    case get_session(conn, :employee_login_otp_expires_at) do
      nil ->
        false

      value ->
        case DateTime.from_iso8601(value) do
          {:ok, expires_at, _offset} -> DateTime.compare(expires_at, DateTime.utc_now()) == :gt
          _ -> false
        end
    end
  end

  defp clear_employee_login_session(conn) do
    conn
    |> delete_session(:employee_login_otp)
    |> delete_session(:employee_login_mobile)
    |> delete_session(:employee_login_employee_id)
    |> delete_session(:employee_login_otp_expires_at)
  end
end
