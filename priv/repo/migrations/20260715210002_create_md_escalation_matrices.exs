defmodule CorporatePolicy.Repo.Migrations.CreateMdEscalationMatrices do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:md_escalation_matrices) do
      add :level, :string, size: 255
      add :status, :integer, default: 0

      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :naive_datetime

      timestamps()
    end
  end
end
