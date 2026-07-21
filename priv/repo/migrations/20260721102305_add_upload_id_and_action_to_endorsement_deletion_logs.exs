defmodule CorporatePolicy.Repo.Migrations.AddUploadIdAndActionToEndorsementDeletionLogs do
  use Ecto.Migration

  def change do
    alter table(:trn_endorsement_deletion_logs) do
      add :upload_id, references(:master_policy_data_uploads, on_delete: :nothing)
      add :action, :string
    end

    create index(:trn_endorsement_deletion_logs, [:upload_id])
  end
end
