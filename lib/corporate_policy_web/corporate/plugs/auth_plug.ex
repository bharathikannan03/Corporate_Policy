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
        if Accounts.corporate_user?(user) and user.status == 1 do
          module_id = get_path_module_id(conn.request_path)

          if has_module_access?(user, module_id) do
            assign(conn, :current_user, user)
          else
            conn
            |> put_flash(:error, "You do not have permission to perform this action.")
            |> redirect(to: "/corporate/dashboard")
            |> halt()
          end
        else
          flash_msg =
            if user.status != 1,
              do: "Your account is inactive or disabled.",
              else: "Unauthorized access. You must be logged in as a corporate user."

          conn
          |> clear_session()
          |> put_flash(:error, flash_msg)
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

  defp get_path_module_id(path) do
    cond do
      String.starts_with?(path, "/corporate/enrollment-details/export") -> 2
      String.starts_with?(path, "/corporate/claims/export") -> 3
      # claims submission export is excluded/skipped per user's instruction
      String.starts_with?(path, "/corporate/claims-submission/export") -> nil
      String.starts_with?(path, "/corporate/cashless-hospitals/export") -> 4
      String.starts_with?(path, "/corporate/employee-activity/export") -> 10
      true -> nil
    end
  end

  defp has_module_access?(_user, nil), do: true

  defp has_module_access?(user, module_id) do
    case CorporatePolicy.Corporates.get_allowed_modules(user.department_id) do
      :all -> true
      list when is_list(list) -> Enum.member?(list, module_id)
      _ -> true
    end
  end
end
