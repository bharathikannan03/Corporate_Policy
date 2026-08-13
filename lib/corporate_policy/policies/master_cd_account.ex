defmodule CorporatePolicy.Policies.MasterCdAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_cd_accounts" do
    field :cd_name, :string
    field :cd_number, :string
    field :corporate_id, :integer, source: :ref_corporate_id
    field :corporate_name, :string
    field :policy_id, :integer, source: :ref_policy_id
    field :policy_number, :string
    field :insurer_id, :integer, source: :ref_insurer_id
    field :insurer_name, :string
    field :status, :integer, default: 1
    field :deleted_at, :utc_datetime_usec

    belongs_to :creator, CorporatePolicy.Accounts.User, foreign_key: :created_by
    belongs_to :updater, CorporatePolicy.Accounts.User, foreign_key: :updated_by

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(cd_account, attrs) do
    cd_account
    |> cast(attrs, [
      :cd_name,
      :cd_number,
      :corporate_id,
      :corporate_name,
      :policy_id,
      :policy_number,
      :insurer_id,
      :insurer_name,
      :status,
      :deleted_at,
      :created_by,
      :updated_by
    ])
    |> validate_required([
      :cd_number,
      :corporate_id,
      :corporate_name,
      :insurer_id,
      :insurer_name
    ])
    |> validate_length(:cd_number, max: 100)
    |> validate_inclusion(:status, [0, 1])
    |> unique_constraint(:cd_number,
      name: :master_cd_accounts_ref_corporate_id_ref_policy_id_cd_number_index,
      message: "CD number already exists for this policy"
    )
  end
end
