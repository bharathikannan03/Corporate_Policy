defmodule CorporatePolicyWeb.Employee.ComingSoonLive do
  use CorporatePolicyWeb, :live_view

  import CorporatePolicyWeb.Employee.PortalComponents

  alias CorporatePolicy.EmployeePortal

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    key = feature_key(socket.assigns.live_action)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:policy, EmployeePortal.get_policy_details(current_user.ref_policy_id))
     |> assign(:active_path, active_path_for(key))
     |> assign(:page_title, page_title_for(key))
     |> assign(:feature_key, key)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.shell
        current_user={@current_user}
        policy={@policy}
        active_path={@active_path}
        page_title={@page_title}
      >
        <.development_notice
          title={@page_title}
          message="This module is under development and will be connected to the existing workflow soon."
        />
      </.shell>
    </Layouts.app>
    """
  end

  defp page_title_for("network-hospital"), do: "Network Hospital"
  defp page_title_for("download-forms"), do: "Download Forms"
  defp page_title_for("claim-status"), do: "Claim Status"
  defp page_title_for("intimate-claim"), do: "Intimate Claim"
  defp page_title_for(_), do: "Development In Progress"

  defp active_path_for(key), do: "/employee/#{key}"

  defp feature_key(:network_hospital), do: "network-hospital"
  defp feature_key(:download_forms), do: "download-forms"
  defp feature_key(:claim_status), do: "claim-status"
  defp feature_key(:intimate_claim), do: "intimate-claim"
  defp feature_key(_), do: "feature"
end
