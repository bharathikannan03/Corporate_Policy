defmodule CorporatePolicy.Repo.Migrations.CreateMasterCdAccounts do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:master_cd_accounts) do
      add :cd_name, :string, size: 100
      add :cd_number, :string, size: 100, null: false
      add :ref_corporate_id, :bigint, null: false
      add :corporate_name, :string, size: 100, null: false
      add :ref_policy_id, :bigint
      add :policy_number, :string, size: 100
      add :ref_insurer_id, :bigint, null: false
      add :insurer_name, :string, size: 100, null: false
      add :status, :integer, default: 1, null: false
      add :created_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    ensure_optional_columns()

    create_if_not_exists index(:master_cd_accounts, [:ref_corporate_id])
    create_if_not_exists index(:master_cd_accounts, [:ref_policy_id])
    create_if_not_exists index(:master_cd_accounts, [:cd_number])

    create_if_not_exists unique_index(:master_cd_accounts, [
                           :ref_corporate_id,
                           :ref_policy_id,
                           :cd_number
                         ])
  end

  def down do
    drop_if_exists unique_index(:master_cd_accounts, [
                     :ref_corporate_id,
                     :ref_policy_id,
                     :cd_number
                   ])

    drop_if_exists index(:master_cd_accounts, [:cd_number])
    drop_if_exists index(:master_cd_accounts, [:ref_policy_id])
    drop_if_exists index(:master_cd_accounts, [:ref_corporate_id])
    drop_if_exists table(:master_cd_accounts)
  end

  defp ensure_optional_columns do
    execute("""
    ALTER TABLE master_cd_accounts
    ADD COLUMN IF NOT EXISTS ref_policy_id BIGINT,
    ADD COLUMN IF NOT EXISTS policy_number VARCHAR(100),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP(6) WITH TIME ZONE
    """)

    execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'master_cd_accounts'
          AND column_name = 'created_by'
      ) THEN
        ALTER TABLE master_cd_accounts
        ADD COLUMN created_by BIGINT;
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'master_cd_accounts_created_by_fkey'
      ) THEN
        ALTER TABLE master_cd_accounts
        ADD CONSTRAINT master_cd_accounts_created_by_fkey
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE NO ACTION;
      END IF;
    END $$;
    """)

    execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = current_schema()
          AND table_name = 'master_cd_accounts'
          AND column_name = 'updated_by'
      ) THEN
        ALTER TABLE master_cd_accounts
        ADD COLUMN updated_by BIGINT;
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'master_cd_accounts_updated_by_fkey'
      ) THEN
        ALTER TABLE master_cd_accounts
        ADD CONSTRAINT master_cd_accounts_updated_by_fkey
        FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE NO ACTION;
      END IF;
    END $$;
    """)
  end
end
