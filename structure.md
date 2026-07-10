# Project Structure

This file outlines the main Phoenix project structure for controllers, migrations, and model/context files.

## Main folders

```text
lib/
├── corporate_policy/           # Business logic and schemas/contexts
│   └── accounts/               # Example domain module
├── corporate_policy_web/       # Web layer
│   ├── controllers/            # Request handlers
│   ├── live/                  # LiveViews (if used)
│   └── router.ex               # Routes
priv/
└── repo/
    ├── migrations/             # Database migration files
    └── seeds.exs               # Seed data
```

## Key files

- Controllers: `lib/corporate_policy_web/controllers/`
- Contexts / models: `lib/corporate_policy/`
- Migrations: `priv/repo/migrations/`
- Router: `lib/corporate_policy_web/router.ex`

## Mermaid diagram

```mermaid
flowchart TD
    A[Client Request] --> B[Controller]
    B --> C[Context / Model Logic]
    C --> D[(Database)]
    D --> E[Migrations]
    E --> D
    C --> F[Views / Templates]
    F --> G[Response to Client]
```

## Example structure

```text
lib/
  corporate_policy_web/
    controllers/
      session_controller.ex
  corporate_policy/
    accounts.ex
    accounts/
      user.ex
priv/
  repo/
    migrations/
      20260709010101_create_users.exs
```
