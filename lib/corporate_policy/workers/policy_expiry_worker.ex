defmodule CorporatePolicy.Workers.PolicyExpiryWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.Policy
  import Ecto.Query

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    today = Date.utc_today()
    Logger.info("Starting PolicyExpiryWorker to check policy expiration status as of #{today}.")

    query =
      from p in Policy,
        where: p.status != 3 and not is_nil(p.policy_end_date) and p.policy_end_date < ^today

    expired_policies = Repo.all(query)

    Enum.each(expired_policies, fn policy ->
      case Repo.update(Policy.status_changeset(policy, %{status: 3})) do
        {:ok, updated_policy} ->
          Logger.info(
            "Policy #{updated_policy.policy_number || updated_policy.id} successfully marked as Expired (status 3)."
          )

        {:error, changeset} ->
          Logger.error(
            "Failed to mark policy #{policy.id} as Expired: #{inspect(changeset.errors)}"
          )
      end
    end)

    {:ok, length(expired_policies)}
  end
end
