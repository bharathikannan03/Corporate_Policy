defmodule CorporatePolicyWeb.Employee.PortalComponents do
  use CorporatePolicyWeb, :html

  attr :current_user, :map, required: true
  attr :policy, :map, default: nil
  attr :active_path, :string, default: "/employee/dashboard"
  attr :page_title, :string, required: true
  slot :inner_block, required: true

  def shell(assigns) do
    assigns =
      assigns
      |> assign(:nav_items, nav_items())
      |> assign(:quick_links, quick_links())

    ~H"""
    <div class="employee-shell">
      <header class="employee-topbar">
        <div class="employee-brand">
          <div class="employee-brand-mark">
            <span class="employee-brand-v">V</span> <span class="employee-brand-i">I</span>
            <span class="employee-brand-b">B</span> <span class="employee-brand-e">E</span>
          </div>
          
          <p class="employee-brand-tag">Insurance Broking and Advisory Service</p>
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
          
          <div class="employee-policy-pillset">
            <span class="employee-policy-pill employee-policy-pill--active">
              {policy_label(@policy)}
            </span>
          </div>
        </section>
        
        <section class="employee-nav-card">
          <div class="employee-nav-grid">
            <%= for item <- @nav_items do %>
              <.link navigate={item.href} class={employee_nav_class(@active_path == item.href)}>
                <span class="employee-nav-icon-wrap">
                  <.icon name={item.icon} class="w-4 h-4" />
                </span>
                
                <div>
                  <p class="employee-nav-title">{item.label}</p>
                  
                  <p class="employee-nav-subtitle">{item.subtitle}</p>
                </div>
              </.link>
            <% end %>
          </div>
          
          <div class="employee-quick-links">
            <%= for item <- @quick_links do %>
              <.link navigate={item.href} class="employee-quick-link">
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

  defp policy_label(nil), do: "Policy"

  defp policy_label(policy) do
    [policy.policy_type, policy.policy_number]
    |> Enum.reject(&is_nil_or_blank/1)
    |> Enum.join(" • ")
    |> case do
      "" -> "Policy"
      label -> label
    end
  end

  defp is_nil_or_blank(nil), do: true
  defp is_nil_or_blank(""), do: true
  defp is_nil_or_blank(value) when is_binary(value), do: String.trim(value) == ""
  defp is_nil_or_blank(_value), do: false
end
