# CorporatePolicy

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix


### Phoenix Framework Project Setup Commands
Beginner-friendly command guide for installing Phoenix and creating a new project
This document contains the main commands needed to install Phoenix Framework, create a Phoenix project, configure PostgreSQL, create the database, and start the development server.

1. Prerequisites

* Elixir and Erlang/OTP installed
* PostgreSQL installed and running
* PowerShell or Command Prompt available
* Internet connection for downloading dependencies

2. Verify Elixir and Mix Installation

Run these commands in PowerShell:
elixir -v
mix -v
If both commands show version numbers, Elixir and Mix are installed correctly.

3. Install Hex and Rebar

Hex is the package manager used by Elixir. Rebar is used for Erlang dependencies.
mix local.hex
mix local.rebar
When PowerShell asks for confirmation, type Y and press Enter.

4. Install Phoenix Project Generator

mix archive.install hex phx_new
Verify Phoenix installer:
mix phx.new --version

5. Create a New Phoenix Project

Go to the folder where you want to create your project:
cd C:\Users\Admin\Documents
Create a new Phoenix project:
mix phx.new hello_phoenix
When it asks “Fetch and install dependencies?”, type Y and press Enter.

6. Optional: Create Phoenix Project Without Database

Use this command if you only want to learn Phoenix basics without PostgreSQL:
mix phx.new hello_phoenix --no-ecto

7. Enter Project Folder and Install Dependencies

cd hello_phoenix
mix deps.get

8. Configure PostgreSQL Database

Open this file:
config/dev.exs
Find the Repo configuration and update username, password, database, and hostname:
config :hello_phoenix, HelloPhoenix.Repo,
  username: "postgres",
  password: "your_postgres_password",
  hostname: "localhost",
  database: "hello_phoenix_dev"
username: usually postgres
password: the password you set during PostgreSQL installation
hostname: usually localhost
database: Phoenix project database name

9. Create the Database

mix ecto.create
Expected result: Phoenix creates the development database successfully.

10. Start Phoenix Server

mix phx.server
Or start with interactive Elixir shell:
iex -S mix phx.server
Open this URL in your browser:
http://localhost:4000

11. Useful Phoenix Commands

Purpose	Command
Create project	mix phx.new my_app
Create project without database	mix phx.new my_app --no-ecto
Get dependencies	mix deps.get
Create database	mix ecto.create
Run migrations	mix ecto.migrate
Start server	mix phx.server
Start server with IEx	iex -S mix phx.server
Run tests	mix test
Format code	mix format
Check Phoenix version	mix phx.new --version

12. Common Errors and Fixes

Error	Fix
phx.new not found	Run: mix archive.install hex phx_new
Hex not installed	Run: mix local.hex
PostgreSQL connection refused	Check PostgreSQL service is running and config/dev.exs credentials are correct.
expected :hostname error	Add hostname: "localhost" inside Repo config in config/dev.exs.
database does not exist	Run: mix ecto.create
port 4000 already in use	Stop the existing server or run on another port.

13. Complete Command Sequence

Use this full sequence for a normal Phoenix project with PostgreSQL:
elixir -v
mix -v
mix local.hex
mix local.rebar
mix archive.install hex phx_new
mix phx.new hello_phoenix
cd hello_phoenix
mix deps.get
mix ecto.create
mix phx.server

## 14. 2Factor SMS OTP Configuration & Employee Test Users

To enable SMS sending for production employees on the Employee Portal, you must define the following environment variables:

```bash
# Required: Your 2Factor API Key
TWO_FACTOR_API_KEY=your_api_key_here

# Optional: Custom DLT template name configured in 2Factor portal
TWO_FACTOR_TEMPLATE_NAME=your_dlt_template_name
```

These variables can be defined in a `.env` file in the project root. In development, the application loads `.env` variables automatically during boot.

### Test User OTP Bypass
Employees configured with `is_testuser = 1` in `trn_mapping_live_employees` will bypass 2Factor API calls and can authenticate using the default OTP `"123456"`. This value is shown on-screen/in the flash during local testing.

### Running Tests
To run the OTP client and authentication tests:
```bash
mix test test/corporate_policy/two_factor_client_test.exs
mix test test/corporate_policy_web/employee_session_controller_test.exs
```