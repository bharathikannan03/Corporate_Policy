# Corporate Policy Application Guidelines & Architecture (AGENTS.md)

## 1. Single Source of Truth & Portal Priority Rules

- **Corporate Portal Priority Rule**: Whenever the user mentions **"Corporate Portal"**, all new web features, pages, routes, components, LiveViews, controllers, templates, and web APIs **MUST be implemented strictly within the Corporate Portal** (`lib/corporate_policy_web/corporate/` directory under the `CorporatePolicyWeb.Corporate` module namespace), unless explicitly specified otherwise.
- **Employee Portal Priority Rule**: Whenever the user mentions **"Employee Portal"**, all new web features, pages, routes, components, LiveViews, controllers, templates, and web APIs **MUST be implemented strictly within the Employee Portal** (`lib/corporate_policy_web/employee/` directory under the `CorporatePolicyWeb.Employee` module namespace), unless explicitly specified otherwise.
- **Admin Portal Priority Rule**: Whenever the user mentions **"Admin Portal"**, all new web features **MUST be implemented strictly within the Admin Portal** (`lib/corporate_policy_web/admin/` directory under the `CorporatePolicyWeb.Admin` module namespace).
- **Backend vs. Web Layer Separation**:
  - `lib/corporate_policy_web/<portal>/`: Web Presentation Layer (Frontend, LiveViews, Controllers, Components, Routes, Plugs) - strictly isolated per portal.
  - `lib/corporate_policy/`: Shared Backend Domain Contexts (Ecto Schemas, Queries, Business Logic, Mailers) - shared across all three portals.
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
* **Employee Portal UI Direction**:
  * Prefer a brighter, service-oriented look distinct from Admin/Corporate.
  * Use blue/cyan primary actions with warm accent highlights instead of the Corporate Portal green gradient shell.
  * Keep Employee pages card-based, mobile-first, and dashboard-oriented with rounded navigation blocks.
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

---

## 10. File Uploads & Private File Downloads

- **Private Upload Storage**: User-uploaded files (like CSV templates, cashless hospital listings, claims, or policies) MUST be stored in private subdirectories under `priv/static/uploads/`.
- **Authorized Serving**: To prevent unauthorized access to uploaded files, do NOT include the `uploads/` directory in the `static_paths/0` list in `lib/corporate_policy_web.ex`. Instead:
  - Route all file download requests through a scope (e.g. `/uploads`) matching `UploadController.show/2` inside `router.ex`.
  - Use `UploadController` to verify authentication (checking active admin/corporate `current_user_id` sessions or `current_employee_id` sessions) before sending the file.
  - Public templates/samples (e.g., under `/uploads/samples/`) are allowed to bypass authentication using helper functions (like `excluded_path?/1`).

---

## 11. Employee Portal OTP Authentication, Test Users & Upload Validation

- **Test User Flag**: The `is_testuser` column (integer, `0` or `1`, defaulting to `0`) is supported on `trn_mapping_live_employees`, `master_inception_data_uploads`, and `master_endorsement_data_uploads`.
- **Synchronization**: Syncing `is_testuser = 1` to the live employee table (`trn_mapping_live_employees`) happens automatically during the upload process (handled in `save_trn_mapping_live_employees`). The sync resolves the value from the master upload tables and preserves it for existing live records.
- **Branching Login Flow**:
  - **Test Users (`is_testuser == 1`)**: Bypasses the mailer and uses the default OTP `"123456"`. The OTP is displayed on-screen/in the flash.
  - **Production Employees (`is_testuser == 0`)**: Generates a secure random 6-digit OTP code and dispatches it via email to their registered email address using `CorporatePolicy.Mailer` (Brevo API). The OTP is not exposed in the flash/UI.
- **Email Mailer Integration**: Powered by Swoosh. Requires `BREVO_API_KEY` and `SENDER_EMAIL` configured in the system environment variables. Falls back to a local mailbox in development (`/dev/mailbox`) if no API key is set.
- **Mandatory CSV Email Validation**: In Step 4 Data Upload (for both Inception and Endorsement CSV uploads), the `Email` address field is strictly mandatory for all rows. A missing or blank email address will raise a runtime exception and abort/rollback the entire database transaction.

---

## 12. Oban Background Job Processing, PubSub & Central Sample Documents

### Oban Setup & Configuration
- **PostgreSQL Adapter**: Oban is configured with PostgreSQL and migrations are verified up to version 14.
- **Queues**:
  - `default` (concurrency: 10): Default background processes.
  - `uploads` (concurrency: 5): Processes heavy file and data parsing/validation.
- **Scheduler**: The cron plugin executes `PolicyExpiryWorker` at `0 0 * * *` daily.

### Background Job Workers
- **Policy Expiry (`PolicyExpiryWorker`)**: Identifies expired active policies based on the current date, updating their status to `3` (Expired). Safe for idempotent repeats.
- **CSV Data Imports (`CsvImportWorker`)**: Runs Step 4 imports (Inception/Endorsement data) within Ecto transactions. Gracefully handles errors, truncating descriptions to 99 chars before updating the upload remark.
- **CD Statement Imports (`CdStatementImportWorker`)**: Runs CD Statement ledger imports, logging row-level validation errors into `master_cdstatement_upload_errors`.

### PubSub Progress System
- LiveViews subscribe to their respective portal channels:
  - `"policy_uploads:#{policy_id}"` for Step 4 Wizard updates.
  - `"cd_uploads:#{policy_id}"` for CD Statement ledger uploads.
- The backend workers broadcast progress maps containing `upload_id`, `status` (Processing, Success, Failed), and `progress` (0-100%).

### Central Sample Documents
- Managed in `CorporatePolicy.Policies.SampleDocuments` mapping document types (e.g. GMC, GPA, CD Statement) to templates stored under `priv/static/uploads/samples/`.


