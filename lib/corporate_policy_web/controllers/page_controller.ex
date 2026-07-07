defmodule CorporatePolicyWeb.PageController do
  use CorporatePolicyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
