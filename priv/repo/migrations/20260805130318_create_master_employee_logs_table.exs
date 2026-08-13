defmodule CorporatePolicy.Repo.Migrations.CreateMasterEmployeeLogsTable do
  use Ecto.Migration

  def change do
    create table(:master_employee_logs) do
      add :employee_id, :string, size: 255
      add :action, :string, size: 255
      add :ip_address, :string, size: 255
      add :user_agent, :string, size: 255
      add :details, :string, size: 255
      add :device_type, :string, size: 255, null: false, default: "1"
      add :status, :integer, null: false, default: 0
      add :deleted_at, :naive_datetime

      timestamps()
    end
  end
end
