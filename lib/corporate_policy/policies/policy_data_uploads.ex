defmodule CorporatePolicy.Policies.PolicyDataUploads do
  @moduledoc """
  Encapsulates logic for Wizard Step 4: Data Uploads listing and management.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyDataUpload

  @doc "Lists all data uploads associated with a policy, ordered by most recent first."
  def list_data_uploads_for_policy(nil), do: []

  def list_data_uploads_for_policy(policy_id) do
    Repo.all(
      from u in MasterPolicyDataUpload,
        where: u.policy_id == ^policy_id,
        order_by: [desc: u.inserted_at]
    )
  end
end
