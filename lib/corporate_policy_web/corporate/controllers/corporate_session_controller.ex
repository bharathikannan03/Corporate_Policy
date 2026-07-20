defmodule CorporatePolicyWeb.Corporate.CorporateSessionController do
  use CorporatePolicyWeb, :controller

  import Phoenix.Component, only: [to_form: 2]

  alias CorporatePolicy.Accounts

  def new(conn, _params) do
    form = to_form(%{}, as: :user)
    render(conn, :new, page_title: "Corporate Login", form: form)
  end

  def create(conn, %{"user" => %{"email_address" => email, "password" => password}}) do
    form = to_form(%{"email_address" => email}, as: :user)

    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        if corporate_user?(user) do
          conn
          |> configure_session(renew: true)
          |> put_session(:current_user_id, user.id)
          |> put_flash(:info, "Welcome back!")
          |> redirect(to: ~p"/corporate/dashboard")
        else
          conn
          |> put_flash(:error, "credentials are invalid for corporate")
          |> render(:new, page_title: "Corporate Login", form: form)
        end

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "credentials are invalid for corporate")
        |> render(:new, page_title: "Corporate Login", form: form)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Signed out")
    |> redirect(to: ~p"/corporate/login")
  end

  defp corporate_user?(user) do
    not is_nil(user.ref_corporate_id) and user.department_id not in [1, 3, 9]
  end
end
