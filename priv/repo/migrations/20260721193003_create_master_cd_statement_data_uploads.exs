defmodule CorporatePolicy.Repo.Migrations.CreateMasterCdStatementDataUploads do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_cd_statement_data_uploads) do
      add :ref_policy_cd_statement_id, :bigint, null: false
      add :particular, :string, size: 100
      add :transaction_type, :string, size: 50
      add :employee_count, :integer
      add :dependant_count, :integer
      add :policy_endorsement_no, :string, size: 150
      add :endorsement_issued_date, :string, size: 30
      add :debit_amount, :decimal, precision: 15, scale: 2
      add :credit_amount, :decimal, precision: 15, scale: 2
      add :bank_name, :string, size: 150
      add :cheque_no, :string, size: 30
      add :policy_number, :string, size: 100
      add :remark, :text
      add :corporate_name, :string, size: 150
      add :corporate_id, :bigint
      add :policy_id, :bigint
      add :cd_number, :string, size: 255
      add :status, :integer, default: 0, null: false
      add :deleted_at, :utc_datetime_usec
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_cd_statement_data_uploads, [:ref_policy_cd_statement_id])
    create_if_not_exists index(:master_cd_statement_data_uploads, [:policy_id])
    create_if_not_exists index(:master_cd_statement_data_uploads, [:cd_number])
  end
end
