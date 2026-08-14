defmodule CorporatePolicyWeb.Employee.PortalComponents do
  use CorporatePolicyWeb, :html

  attr :current_user, :map, required: true
  attr :policy, :map, default: nil
  attr :policy_options, :list, default: []
  attr :active_path, :string, default: "/employee/dashboard"
  attr :page_title, :string, required: true
  slot :inner_block, required: true

  def shell(assigns) do
    assigns =
      assigns
      |> assign(:nav_items, nav_items())
      |> assign(:quick_links, quick_links())
      |> assign(
        :display_policy_options,
        display_policy_options(assigns.policy_options, assigns.policy)
      )
      |> assign(:current_policy_label, current_policy_label(assigns.policy))
      |> assign(:selected_policy_id, selected_policy_id(assigns.policy))

    ~H"""
    <div class="employee-shell">
      <header class="employee-topbar">
        <div class="employee-brand">
          <div class="employee-brand-lockup">
            <span class="employee-brand-icon">
              <.icon name="hero-shield-check" class="w-5 h-5" />
            </span>
            
            <div>
              <div class="employee-brand-mark">Employee Portal</div>
              
              <p class="employee-brand-tag">Benefits, Members, and Claims</p>
            </div>
          </div>
        </div>
        
        <div class="employee-topbar-actions">
          <div class="employee-greeting">
            <span class="employee-greeting-label">Hi,</span>
            <span class="employee-greeting-name">{@current_user.full_name}</span>
          </div>
          
          <.link href={~p"/employee/logout"} method="delete" class="employee-logout-btn">
            <.icon name="hero-arrow-path-rounded-square" class="w-4 h-4" /> Logout
          </.link>
        </div>
      </header>
      
      <main class="employee-shell-main">
        <section class="employee-hero">
          <div class="employee-hero-copy">
            <p class="employee-eyebrow">Employee Portal</p>
            
            <h1 class="employee-hero-title">{@page_title}</h1>
            
            <p class="employee-hero-text">
              Access only the benefits, members, contacts, and claims linked to your policy.
            </p>
          </div>
          
          <div class="employee-hero-actions">
            <%= if @current_policy_label != "" do %>
              <span class="employee-current-policy-badge">{@current_policy_label}</span>
            <% end %>
          </div>
        </section>
        
        <section class="employee-policy-strip">
          <div class="employee-policy-pillset">
            <%= for policy_option <- @display_policy_options do %>
              <.link
                navigate={with_policy_query(@active_path, policy_option.id)}
                class={employee_policy_type_class(policy_option, @policy)}
              >
                <span class="employee-policy-pill-icon">
                  <.icon name={policy_type_icon(policy_option.policy_type)} class="w-4 h-4" />
                </span>
                 {policy_type_label(policy_option)}
              </.link>
            <% end %>
          </div>
        </section>
        
        <section class="employee-nav-card">
          <div class="employee-nav-grid">
            <%= for item <- @nav_items do %>
              <.link
                navigate={with_policy_query(item.href, @selected_policy_id)}
                class={employee_nav_class(@active_path == item.href)}
              >
                <span class="employee-nav-icon-wrap">
                  <.icon name={item.icon} class="w-4 h-4" />
                </span>
                
                <div>
                  <p class="employee-nav-title">{item.label}</p>
                  
                  <%= if item.subtitle do %>
                    <p class="employee-nav-subtitle">{item.subtitle}</p>
                  <% end %>
                </div>
              </.link>
            <% end %>
          </div>
          
          <div class="employee-quick-links">
            <%= for item <- @quick_links do %>
              <.link
                navigate={with_policy_query(item.href, @selected_policy_id)}
                class="employee-quick-link"
              >
                <.icon name={item.icon} class="w-4 h-4" /> {item.label}
              </.link>
            <% end %>
          </div>
        </section>
        
        <section class="employee-content">
          {render_slot(@inner_block)}
        </section>
      </main>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :value, :string, default: "-"
  attr :icon, :string, required: true

  def info_card(assigns) do
    ~H"""
    <article class="employee-info-card">
      <div class="employee-info-icon">
        <.icon name={@icon} class="w-6 h-6" />
      </div>
      
      <div>
        <p class="employee-info-label">{@title}</p>
        
        <p class="employee-info-value">{@value}</p>
      </div>
    </article>
    """
  end

  attr :title, :string, required: true
  attr :message, :string, required: true

  def development_notice(assigns) do
    ~H"""
    <div class="employee-empty-state">
      <div class="employee-empty-icon">
        <.icon name="hero-wrench-screwdriver" class="w-8 h-8" />
      </div>
      
      <h3 class="employee-empty-title">{@title}</h3>
      
      <p class="employee-empty-text">{@message}</p>
    </div>
    """
  end

  defp nav_items do
    [
      %{
        label: "Policy Details",
        subtitle: "My Policy",
        href: "/employee/dashboard",
        icon: "hero-document-text"
      },
      %{
        label: "My Coverages",
        subtitle: "Policy Features",
        href: "/employee/my-coverages",
        icon: "hero-shield-check"
      },
      %{
        label: "Members Covered",
        subtitle: "Family Details",
        href: "/employee/members-covered",
        icon: "hero-user-group"
      },
      %{
        label: "Contact Matrix",
        subtitle: "Escalation Contacts",
        href: "/employee/contact-matrix",
        icon: "hero-building-office-2"
      },
      %{
        label: "Claim Submission",
        subtitle: "Track and submit claims",
        href: "/employee/claims-submission",
        icon: "hero-clipboard-document-list"
      }
    ]
  end

  defp quick_links do
    [
      %{
        label: "Network Hospital",
        href: "/employee/network-hospital",
        icon: "hero-building-office"
      },
      %{label: "Download Forms", href: "/employee/download-forms", icon: "hero-arrow-down-tray"},
      %{label: "Claim Status", href: "/employee/claim-status", icon: "hero-clock"},
      %{label: "Intimate Claim", href: "/employee/intimate-claim", icon: "hero-pencil-square"}
    ]
  end

  defp employee_nav_class(true), do: "employee-nav-item employee-nav-item--active"
  defp employee_nav_class(false), do: "employee-nav-item"

  defp display_policy_options([], nil), do: []
  defp display_policy_options([], policy), do: [policy]

  defp display_policy_options(policy_options, _policy) do
    policy_options
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(&policy_type_priority/1)
  end

  defp employee_policy_type_class(policy_option, policy) do
    if String.trim(policy_type_label(policy)) != "" and
         selected_policy_id(policy_option) == selected_policy_id(policy) do
      "employee-policy-pill employee-policy-pill--active"
    else
      "employee-policy-pill"
    end
  end

  defp policy_type_icon(policy_type) do
    case String.downcase(String.trim(to_string(policy_type))) do
      "gmc" -> "hero-heart"
      "gpa" -> "hero-shield-check"
      "gtl" -> "hero-user-group"
      _ -> "hero-sparkles"
    end
  end

  defp policy_type_label(nil), do: ""

  defp policy_type_label(%{policy_type: policy_type}),
    do: String.trim(to_string(policy_type || ""))

  defp policy_type_priority(policy) do
    case policy_type_label(policy) |> String.downcase() do
      "gmc" -> {0, ""}
      "gpa" -> {1, ""}
      "parent policy" -> {2, ""}
      "top up policy" -> {3, ""}
      "gtl" -> {4, ""}
      other -> {5, other}
    end
  end

  defp current_policy_label(nil), do: ""

  defp current_policy_label(policy) do
    [policy_type_label(policy), Map.get(policy, :policy_number)]
    |> Enum.map(&String.trim(to_string(&1 || "")))
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" | ")
  end

  defp selected_policy_id(nil), do: nil
  defp selected_policy_id(%{id: id}) when is_integer(id), do: id
  defp selected_policy_id(%{ref_policy_id: id}) when is_integer(id), do: id
  defp selected_policy_id(_value), do: nil

  defp with_policy_query(path, nil), do: path

  defp with_policy_query(path, policy_id) do
    separator = if String.contains?(path, "?"), do: "&", else: "?"
    "#{path}#{separator}policy_id=#{policy_id}"
  end
end
