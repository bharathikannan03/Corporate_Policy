defmodule CorporatePolicy.Policies.MasterPolicyFeatureTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:template_id, :id, autogenerate: true}
  schema "master_policy_feature_templates" do
    field :policy_identifier, :string
    field :set_default, :integer, default: 2
    field :status, :integer, default: 1

    belongs_to :policy_ref, CorporatePolicy.Policies.Policy, foreign_key: :ref_policy_id
    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps()
  end

  @doc false
  def changeset(master_policy_feature_template, attrs) do
    master_policy_feature_template
    |> cast(attrs, [
      :policy_identifier,
      :set_default,
      :status,
      :deleted_at,
      :ref_policy_id,
      :created_by,
      :updated_by
    ])
    |> validate_required([:policy_identifier, :set_default, :status])
  end
end
