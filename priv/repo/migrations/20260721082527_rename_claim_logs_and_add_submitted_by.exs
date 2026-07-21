defmodule CorporatePolicy.Repo.Migrations.RenameClaimLogsAndAddSubmittedBy do
  use Ecto.Migration

  def up do
    execute("""
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = current_schema()
          AND table_name = 'master_claim_logs'
      ) THEN
        ALTER TABLE master_claim_logs RENAME TO trp_claim_submission_logs;
      END IF;
    END $$;
    """)

    execute("""
    ALTER TABLE master_claim_submission
    ADD COLUMN IF NOT EXISTS submitted_by BIGINT;
    """)

    execute("""
    ALTER TABLE trp_claim_submission_logs
    ADD COLUMN IF NOT EXISTS submitted_by BIGINT;
    """)

    execute("""
    ALTER INDEX IF EXISTS master_claim_logs_claim_id_index
    RENAME TO trp_claim_submission_logs_claim_id_index;
    """)

    execute("""
    ALTER INDEX IF EXISTS master_claim_logs_policy_id_index
    RENAME TO trp_claim_submission_logs_policy_id_index;
    """)

    execute("""
    ALTER INDEX IF EXISTS master_claim_logs_portal_id_index
    RENAME TO trp_claim_submission_logs_portal_id_index;
    """)
  end

  def down do
    execute("""
    ALTER TABLE master_claim_submission
    DROP COLUMN IF EXISTS submitted_by;
    """)

    execute("""
    ALTER TABLE trp_claim_submission_logs
    DROP COLUMN IF EXISTS submitted_by;
    """)

    execute("""
    ALTER INDEX IF EXISTS trp_claim_submission_logs_claim_id_index
    RENAME TO master_claim_logs_claim_id_index;
    """)

    execute("""
    ALTER INDEX IF EXISTS trp_claim_submission_logs_policy_id_index
    RENAME TO master_claim_logs_policy_id_index;
    """)

    execute("""
    ALTER INDEX IF EXISTS trp_claim_submission_logs_portal_id_index
    RENAME TO master_claim_logs_portal_id_index;
    """)

    execute("""
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = current_schema()
          AND table_name = 'trp_claim_submission_logs'
      ) THEN
        ALTER TABLE trp_claim_submission_logs RENAME TO master_claim_logs;
      END IF;
    END $$;
    """)
  end
end
