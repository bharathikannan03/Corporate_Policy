defmodule CorporatePolicy.Policies.MasterSumInsured do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_sum_insureds" do
    field :sum_insured, :integer
    field :policy_feature_identifier, :string
    field :template_id, :integer
    field :policy_id, :integer
    field :feature_identifier_id, :integer
    field :status, :integer, default: 0
    field :deleted_at, :naive_datetime

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
  end

  @doc false
  def changeset(master_sum_insured, attrs) do
    master_sum_insured
    |> cast(attrs, [
      :sum_insured,
      :policy_feature_identifier,
      :template_id,
      :policy_id,
      :feature_identifier_id,
      :status,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :sum_insured,
      :policy_feature_identifier,
      :template_id,
      :policy_id,
      :feature_identifier_id,
      :status
    ])
    |> validate_number(:sum_insured, greater_than: 0)
  end
end
