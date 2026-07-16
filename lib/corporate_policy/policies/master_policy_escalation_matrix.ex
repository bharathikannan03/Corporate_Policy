defmodule CorporatePolicy.Policies.MasterPolicyEscalationMatrix do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_policy_escalation_matrices" do
    field :escalation_level_id, :integer
    field :level, :string
    field :user_id, :integer
    field :user_fullname, :string
    field :policy_id, :integer
    field :status, :integer, default: 0
    field :deleted_at, :naive_datetime

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
  end

  @doc false
  def changeset(master_policy_escalation_matrix, attrs) do
    master_policy_escalation_matrix
    |> cast(attrs, [
      :escalation_level_id,
      :level,
      :user_id,
      :user_fullname,
      :policy_id,
      :status,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :escalation_level_id,
      :level,
      :user_id,
      :user_fullname,
      :policy_id,
      :status
    ])
  end
end
