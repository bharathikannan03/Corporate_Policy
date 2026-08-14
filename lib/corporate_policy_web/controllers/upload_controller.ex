defmodule CorporatePolicyWeb.UploadController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Accounts
  alias CorporatePolicy.EmployeePortal

  def show(conn, %{"path" => path}) do
    if excluded_path?(path) or authenticated?(conn) do
      serve_upload(conn, path)
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(html: CorporatePolicyWeb.ErrorHTML, json: CorporatePolicyWeb.ErrorJSON)
      |> render(:"401")
    end
  end

  defp excluded_path?(["samples" | _]), do: true
  defp excluded_path?(_), do: false

  defp authenticated?(conn) do
    user_id = get_session(conn, :current_user_id)
    employee_id = get_session(conn, :current_employee_id)

    cond do
      # 1. Admin/Corporate User
      not is_nil(user_id) ->
        case Accounts.get_user(user_id) do
          %Accounts.User{status: 1} = user ->
            Accounts.admin_user?(user) or Accounts.corporate_user?(user)

          _ ->
            false
        end

      # 2. Employee
      not is_nil(employee_id) ->
        case EmployeePortal.get_authenticated_employee_session(employee_id) do
          {:ok, _employee} -> true
          _ -> false
        end

      # 3. Otherwise
      true ->
        false
    end
  end

  defp serve_upload(conn, path) do
    if safe_path?(path) do
      base_dir = Path.expand("priv/static/uploads")
      file_path = Path.expand(Path.join([base_dir | path]))

      if String.starts_with?(file_path, base_dir) and File.exists?(file_path) do
        conn
        |> put_resp_content_type(MIME.from_path(file_path))
        |> send_file(200, file_path)
      else
        conn
        |> put_status(:not_found)
        |> put_view(html: CorporatePolicyWeb.ErrorHTML, json: CorporatePolicyWeb.ErrorJSON)
        |> render(:"404")
      end
    else
      conn
      |> put_status(:forbidden)
      |> put_view(html: CorporatePolicyWeb.ErrorHTML, json: CorporatePolicyWeb.ErrorJSON)
      |> render(:"403")
    end
  end

  defp safe_path?(path_segments) do
    Enum.all?(path_segments, fn segment ->
      segment != ".." and segment != "." and not String.contains?(segment, "/") and
        not String.contains?(segment, "\\")
    end)
  end
end
