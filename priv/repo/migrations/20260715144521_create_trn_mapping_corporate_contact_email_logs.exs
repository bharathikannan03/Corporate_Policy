defmodule CorporatePolicy.Repo.Migrations.CreateTrnMappingCorporateContactEmailLogs do
  use Ecto.Migration

  def change do
    create table(:trn_mapping_corporate_contact_email_logs) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :sent_status, :string, null: false
      add :error_message, :text

      timestamps(type: :utc_datetime_usec)
    end

    create index(:trn_mapping_corporate_contact_email_logs, [:user_id])
  end
end
