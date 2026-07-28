-- =============================================================================
-- Stored Procedure: truncate_master_and_mapping_tables
-- Scope         : 2 mapping + 21 master + 6 trn/trp = 29 tables total
-- Description   : Truncates the specified tables in FK-safe dependency order.
--                 Uses CASCADE + RESTART IDENTITY so sequences reset cleanly.
--
-- Usage         :
--   -- Dry run (no data deleted, only prints statements)
--   CALL truncate_master_and_mapping_tables(dry_run => true);
--
--   -- Safe execution inside a transaction
--   BEGIN;
--     CALL truncate_master_and_mapping_tables();
--   COMMIT;   -- ROLLBACK to undo
--
-- ⚠  WARNING: This is a DESTRUCTIVE operation. Back up data before running!
-- =============================================================================

CREATE OR REPLACE PROCEDURE truncate_master_and_mapping_tables(
    dry_run BOOLEAN DEFAULT FALSE
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- -------------------------------------------------------------------------
    -- 29 tables ordered by FK dependency (children before parents):
    --   Layer 1  – trn/trp log tables            (6 tables)
    --   Layer 2  – mapping tables                 (2 tables)
    --   Layer 3  – child master tables            (14 tables)
    --   Layer 4  – parent master tables           (7 tables)
    -- -------------------------------------------------------------------------
    tables_to_truncate TEXT[] := ARRAY[

        -- --------------------------------------------------------------------
        -- Layer 1 – TRN / TRP log & transaction tables  (6)
        -- --------------------------------------------------------------------
        'trp_claim_submission_logs',
        'trn_endorsement_deletion_logs',
        'trn_mapping_corporate_contact_email_logs',
        'trn_mapping_corporateid_corporatecontactsids',
        'trn_mapping_live_employees',
        'trn_mapping_roleid_roleaccessdetails',

        -- --------------------------------------------------------------------
        -- Layer 2 – Mapping tables  (2)
        -- --------------------------------------------------------------------
        'mapping_policy_completions',
        'mapping_policy_feature_templates_corporates_policies',

        -- --------------------------------------------------------------------
        -- Layer 3 – Child / dependent master tables  (14)
        -- --------------------------------------------------------------------
        'master_claim_submission_documents',
        'master_claim_submission',
        'master_cdstatement_upload_errors',
        'master_cd_statement_data_uploads',
        'master_policy_cd_statements',
        'master_cd_accounts',
        'master_ecards_data_uploads',
        'master_endorsement_data_uploads',
        'master_inception_data_uploads',
        'master_total_claim_reports',
        'master_policy_data_uploads',
        'master_policy_documents',
        'master_policy_escalation_matrices',
        'master_escalation_matrices',
        'master_policy_corporate_buffer_transactions',
        'master_policy_corporate_buffer_amounts',
        'master_policy_feature_templates',
        'master_sum_insureds',

        -- --------------------------------------------------------------------
        -- Layer 4 – Parent / root master tables  (7)
        -- --------------------------------------------------------------------
        'master_add_policies',
        'master_logos',
        'master_corporates'
    ];

    tbl           TEXT;
    sql_statement TEXT;
    truncated_cnt INT := 0;
    skipped_cnt   INT := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================================';
    RAISE NOTICE '  truncate_master_and_mapping_tables  |  dry_run = %', dry_run;
    RAISE NOTICE '================================================================';

    FOREACH tbl IN ARRAY tables_to_truncate LOOP
        sql_statement := format(
            'TRUNCATE TABLE %I RESTART IDENTITY CASCADE',
            tbl
        );

        IF dry_run THEN
            -- Just print – do nothing
            RAISE NOTICE '[DRY RUN] %', sql_statement;
        ELSE
            IF EXISTS (
                SELECT 1
                FROM information_schema.tables
                WHERE table_schema = current_schema()
                  AND table_name   = tbl
            ) THEN
                EXECUTE sql_statement;
                RAISE NOTICE '[OK] Truncated  →  %', tbl;
                truncated_cnt := truncated_cnt + 1;
            ELSE
                RAISE WARNING '[SKIP] Table not found in schema  →  %', tbl;
                skipped_cnt := skipped_cnt + 1;
            END IF;
        END IF;
    END LOOP;

    RAISE NOTICE '----------------------------------------------------------------';
    IF dry_run THEN
        RAISE NOTICE 'DRY RUN complete — % table(s) listed, 0 rows deleted.',
            array_length(tables_to_truncate, 1);
    ELSE
        RAISE NOTICE 'Done — % truncated, % skipped.', truncated_cnt, skipped_cnt;
    END IF;
    RAISE NOTICE '================================================================';
END;
$$;

-- =============================================================================
-- HOW TO USE
-- =============================================================================

-- Step 1: Create the procedure (run this file once)
--   psql -U postgres -d corporate_policy_dev -f priv/repo/scripts/truncate_master_and_mapping_tables.sql

-- Step 2: Dry run – preview only, zero data deleted
--   CALL truncate_master_and_mapping_tables(dry_run => true);

-- Step 3: Execute safely inside a transaction
--   BEGIN;
--     CALL truncate_master_and_mapping_tables();
--   COMMIT;
--   -- Use ROLLBACK instead of COMMIT to undo if anything looks wrong.

-- Step 4: (Optional) Drop the procedure after use
--   DROP PROCEDURE IF EXISTS truncate_master_and_mapping_tables(BOOLEAN);
