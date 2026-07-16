defmodule CorporatePolicy.Corporates.State do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:state_id, :id, autogenerate: true}
  schema "md_states" do
    field :state, :string
    field :status, :integer, default: 0
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, [:state, :status, :deleted_at])
    |> validate_required([:state])
  end
end
