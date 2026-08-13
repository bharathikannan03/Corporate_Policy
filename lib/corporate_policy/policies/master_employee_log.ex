defmodule CorporatePolicy.Policies.MasterEmployeeLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_employee_logs" do
    field :employee_id, :string
    field :action, :string
    field :ip_address, :string
    field :user_agent, :string
    field :details, :string
    field :device_type, :string, default: "1"
    field :status, :integer, default: 0
    field :deleted_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(master_employee_log, attrs) do
    master_employee_log
    |> cast(attrs, [
      :employee_id,
      :action,
      :ip_address,
      :user_agent,
      :details,
      :device_type,
      :status,
      :deleted_at
    ])
    |> validate_required([:employee_id, :action])
  end
end
