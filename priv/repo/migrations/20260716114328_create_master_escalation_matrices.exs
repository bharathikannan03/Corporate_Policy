defmodule CorporatePolicy.Repo.Migrations.CreateMasterEscalationMatrices do
  use Ecto.Migration

  def change do
    create table(:master_escalation_matrices) do
      add :fullname, :string, size: 150
      add :phone_number, :string, size: 15
      add :mobile_number, :string, size: 15
      add :email_id, :string, size: 50
      add :alt_email_id, :string, size: 50
      add :send_mail_alt_email, :boolean
      add :company_fulladdress, :text
      add :type, :string, size: 30
      add :type_id, :integer
      add :status, :integer, default: 1, null: false
      add :deleted_at, :utc_datetime_usec

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end
  end
end
