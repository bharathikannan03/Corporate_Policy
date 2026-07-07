defmodule CorporatePolicy.Repo do
  use Ecto.Repo,
    otp_app: :corporate_policy,
    adapter: Ecto.Adapters.Postgres
end
