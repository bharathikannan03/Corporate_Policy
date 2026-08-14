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
        if Accounts.corporate_user?(user) and user.status == 1 do
          live_view_module = socket.view
          module_id = get_module_id(live_view_module)

          if has_module_access?(user, module_id) do
            {:cont, assign(socket, :current_user, user)}
          else
            if module_id == 1 do
              {:halt,
               socket
               |> put_flash(:error, "You do not have permission to access the corporate portal.")
               |> redirect(to: "/corporate/login")}
            else
              {:halt,
               socket
               |> put_flash(:error, "You do not have permission to access this page.")
               |> redirect(to: "/corporate/dashboard")}
            end
          end
        else
          {:halt, redirect(socket, to: "/corporate/login")}
        end

      true ->
        {:halt, redirect(socket, to: "/corporate/login")}
    end
  end

  defp get_module_id(CorporatePolicyWeb.Corporate.DashboardLive), do: 1
  defp get_module_id(CorporatePolicyWeb.Corporate.EnrollmentDetailsLive), do: 2
  defp get_module_id(CorporatePolicyWeb.Corporate.EmployeeActivityLive), do: 10
  defp get_module_id(CorporatePolicyWeb.Corporate.ClaimsLive), do: 3
  # Claim submission is excluded from RBAC restriction per user comment
  defp get_module_id(CorporatePolicyWeb.Corporate.ClaimsSubmissionIndexLive), do: nil
  defp get_module_id(CorporatePolicyWeb.Corporate.ClaimSubmissionFormLive), do: nil
  defp get_module_id(CorporatePolicyWeb.Corporate.EscalationMatrixLive), do: 5
  defp get_module_id(CorporatePolicyWeb.Corporate.DocumentsLive), do: 7
  defp get_module_id(CorporatePolicyWeb.Corporate.PolicyFeaturesLive), do: 6
  defp get_module_id(CorporatePolicyWeb.Corporate.CashlessHospitalsLive), do: 4
  defp get_module_id(_), do: nil

  defp has_module_access?(_user, nil), do: true

  defp has_module_access?(user, module_id) do
    case CorporatePolicy.Corporates.get_allowed_modules(user.department_id) do
      :all -> true
      list when is_list(list) -> Enum.member?(list, module_id)
      _ -> true
    end
  end
end
