# Corporate Policy Application Guidelines & Architecture (AGENTS.md)

## 1. Single Source of Truth & Portal Priority Rules

- **Corporate Portal Priority Rule**: Whenever the user mentions **"Corporate Portal"**, all new features, pages, routes, components, contexts, LiveViews, APIs, and related functionality **MUST be implemented strictly within the Corporate Portal** (`lib/corporate_policy_web/corporate/` directory under the `CorporatePolicyWeb.Corporate` module namespace), unless the user explicitly specifies a different portal (Admin Portal or Employee Portal).
- Use `mix precommit` alias when you are done with all changes and fix any pending issues.
- Use the already included `:req` (`Req`) library for HTTP requests. **Avoid** `:httpoison`, `:tesla`, and `:httpc`.

---

## 2. Multi-Portal Monorepo Architecture

The application uses a **Multi-Portal Monorepo** pattern within a single Phoenix application. Each portal is isolated into its dedicated module namespace, directory structure, routing scope, and pipeline:

```text
lib/
├── corporate_policy/               # Core Ecto Schemas & Business Logic Contexts
│   ├── accounts/                   # User accounts & credentials context
│   ├── corporates/                 # Corporate profiles, contacts & departments
│   ├── escalation_matrices/        # Master escalation contacts
│   └── policies/                   # Master policies, sum insured & data uploads
│
└── corporate_policy_web/           # Web Interface & Presentation Layer
    ├── admin/                      # 🔴 Admin Portal (CorporatePolicyWeb.Admin.*)
    │   ├── controllers/            # SessionController, export controllers & session_html/
    │   ├── live/                   # Admin LiveViews (Dashboard, Corporate, Policy, Users, etc.)
    │   │   └── add_policy_components/ # Wizard LiveComponents (Steps 1-7)
    │   └── plugs/                  # AuthPlug & LiveAuth authentication guards
    │
    ├── corporate/                  # 🔵 Corporate Portal (CorporatePolicyWeb.Corporate.*)
    │   ├── controllers/            # Corporate Portal controllers & views
    │   ├── live/                   # Corporate Portal LiveViews
    │   └── plugs/                  # Corporate AuthPlugs & LiveAuth
    │
    ├── employee/                   # 🟢 Employee Portal (CorporatePolicyWeb.Employee.*)
    │   ├── controllers/            # Employee Portal controllers
    │   └── live/                   # Employee Portal LiveViews
    │
    ├── components/                 # Shared UI Components & Layouts
    │   ├── core_components.ex      # Button, input, table, modal, icon components
    │   └── layouts.ex              # Root, App, and Admin Layout definitions
    │
    ├── endpoint.ex                 # Dynamic PORT endpoint configuration
    └── router.ex                   # Dynamic PORTAL environment-scoped router
```

---

## 3. Project Setup, Build & Multi-Portal Launch Commands

### Development Setup & Quality Tasks
* **Install dependencies & setup database**: `mix setup`
* **Run pre-commit validation**: `mix precommit`
* **Run test suite**: `mix test`

### Multi-Portal Launch Commands (Configured in `mix.exs`)
These OS-independent Elixir task aliases set `PORTAL` and `PORT` environment variables natively:

| Command | Target Portal | Port | Default URL |
| :--- | :--- | :--- | :--- |
| `mix phx.server.admin` | Admin Portal | `4001` | `http://localhost:4001/admin/dashboard` |
| `mix phx.server.corp` | Corporate Portal | `4002` | `http://localhost:4002/corporate` |
| `mix phx.server.emp` | Employee Portal | `4003` | `http://localhost:4003/employee` |
| `mix phx.server` *(or `.all`)* | All Portals | `4000` | `http://localhost:4000/admin/dashboard` |
| `mix phx.server.end` | Terminate Servers | 4000–4003 | *Stops background server processes* |

---

## 4. Routing & Portal Organization Guidelines

- **Scope Aliasing**: Router `scope` blocks must specify the portal alias (e.g. `scope "/admin", CorporatePolicyWeb.Admin, as: :admin`). Routes within the scope automatically infer the module prefix.
- **Environment Scoping**: `router.ex` checks `System.get_env("PORTAL", "all")` to conditionally mount individual portal scopes or all portals simultaneously.
- **Verified Routes**: Always use verified route sigils matching the target portal scope: `~p"/admin/dashboard"`, `~p"/admin/login"`, `~p"/admin/logout"`.

---

## 5. Layout & Phoenix v1.8 Guidelines

- **Layout Module**: `CorporatePolicyWeb.Layouts` inside `lib/corporate_policy_web/components/layouts.ex`.
- **Layout Dual-Rendering**: Both `Layouts.app` and `Layouts.admin` support rendering `@inner_content` (when used as LiveView root layouts) and `render_slot(@inner_block)` (when used as HEEx component slots).
- **Flash Group Rules**: `<.flash_group>` is defined and called **only** in `layouts.ex`. You are **forbidden** from calling `<.flash_group>` outside of `layouts.ex` to prevent duplicate DOM IDs (`server-error` / `client-error`).
- **Icons & Inputs**:
  - Always use `<.icon name="hero-name" class="w-5 h-5" />` imported from `core_components.ex` for icons. Never use `Heroicons` modules directly.
  - Always use imported `<.input>` component for form fields.

---

## 6. Project Stack & UI/UX Guidelines

### 1. Color Palette & Themes
The project utilizes Tailwind CSS v4 alongside daisyUI plugins for system-wide variables inside `assets/css/app.css`:
* **Light Theme (Default)**:
  * Primary: `oklch(70% 0.213 47.604)` (Warm brown/gold tone)
  * Secondary: `oklch(55% 0.027 264.364)` (Muted slate/indigo tone)
  * Base background: `oklch(98% 0 0)` (Soft off-white)
* **Dark Theme**:
  * Primary/Secondary: `oklch(58% 0.233 277.117)` (Purple/blue tone)
  * Base background: `oklch(30.33% 0.016 252.42)` (Deep dark slate)

### 2. Core CSS Utility Classes
* **Layout Structure**: `.admin-layout`, `.admin-sidebar`, `.admin-main`, `.admin-topbar`, `.admin-content`.
* **Buttons**:
  * `.btn-primary`: Blue gradient background (`linear-gradient(135deg, #3b82f6, #1d4ed8)`).
  * `.btn-secondary`: Light gray background (`#f1f5f9`).
  * Submit buttons (`button[type="submit"]` / `input[type="submit"]`): Always use green color palette for submit actions.
  * `.corp-action-btn-text`: Inline action button (`--edit` blue, `--delete` red).
* **Table Layout**:
  * Always wrap listing tables with `<div class="overflow-x-auto">` inside `.corp-table-card` containers to ensure horizontal scrolling without clipping.
  * Core table classes: `.corp-table-card`, `.corp-table`, `.corp-th`, `.corp-tr`, `.corp-td`, `.corp-td--name`.
* **Datatable Requirements**:
  * **Confirmation Modals**: Always ask confirmation from the user using a modal popup before deleting any data/resource.
  * **Export Option**: Always include a CSV/Excel export button on data tables.

---

## 7. Database Migrations & Seeder Conventions

- **Migrations**: Always generate migrations with `mix ecto.gen.migration migration_name_in_snake_case`.
- **Seeders**: Always create separate seeder files inside `priv/repo/seeds/` (e.g., `priv/repo/seeds/01_users.exs`).
- **Pagination**: Always implement pagination with a limit of 15 records per page when creating workflows that fetch all data from a table.
- **Preloading**: Always preload Ecto associations in queries when they will be accessed in templates.
- **Security**: Fields set programmatically (such as `user_id` or `corporate_id`) must not be listed in changeset `cast` calls.

---

## 8. Dependencies & Packages ([mix.exs](file:///f:/Vibe%20elixir/Corporate_Policy/mix.exs))

- **Web Framework & Real-Time**: `phoenix` (~> 1.8.8), `phoenix_live_view` (~> 1.2.0), `bandit` (~> 1.5).
- **Database & Ecto**: `ecto_sql` (~> 3.13), `phoenix_ecto` (~> 4.5), `postgrex`.
- **Assets & Front-End**: `tailwind` (~> 0.3), `esbuild` (~> 0.10), `heroicons` (v2.2.0).
- **Utilities & Services**: `req` (~> 0.5), `nimble_csv` (~> 1.2), `swoosh` (~> 1.16), `jason` (~> 1.2), `gettext` (~> 1.0).
- **Testing**: `lazy_html` (>= 0.1.0).

---

## 9. Elixir & LiveView Coding Standards

### Elixir Lists
- Elixir lists **do not support index-based access via `mylist[i]` syntax**. Always use `Enum.at`, pattern matching, or `List`.

### Block Expressions
- Rebind the result of `if`, `case`, `cond` expressions to a variable (e.g. `socket = if ... do assign(socket, ...) end`).

### LiveView Streams
- Always use LiveView streams for collections (`stream(socket, :items, items)`) to prevent memory ballooning.
- Set `phx-update="stream"` on parent elements with unique DOM IDs.
- For filtering, re-fetch data and re-stream with `reset: true`.

### Form Handling
- Always create forms using `assign(socket, form: to_form(changeset_or_params))` in LiveView.
- Access form fields in HEEx using `@form[:field]`.
- Always assign a unique DOM ID to forms (`id="my-form"`).
- Never access changeset directly in HEEx templates.