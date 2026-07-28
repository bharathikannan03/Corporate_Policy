defmodule CorporatePolicy.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :corporate_policy

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @seeds_path "priv/repo/seeds/seeds.exs"

  @doc """
  Runs the application seeds when invoked from a compiled release.

  IMPORTANT: Mix releases do not include the project's `priv` source files
  (such as `priv/repo/seeds/seeds.exs` and the modular files under
  `priv/repo/seeds/`) by default. Only `priv` directories that are copied in
  as part of the build (e.g. static assets referenced via
  `Application.app_dir/2`) ship with the release. As a result, calling this
  function against a deployed release will currently log a warning and skip
  seeding rather than raising `enoent`.

  ## Running seeds in production

  Until seed files are packaged with the release (see "Future work" below),
  seed data should be applied using one of the following approaches:

    1. Run seeds locally/from CI against the production database using
       `MIX_ENV=prod mix run priv/repo/seeds/seeds.exs`, with `DATABASE_URL`
       (and any other required env vars) pointed at the target environment.
       This works because `mix run` has access to the full source tree,
       unlike a compiled release.
    2. Use a one-off Railway service/job (or `railway run`) that checks out
       the repository and runs the command above, rather than relying on
       the release's `bin/corporate_policy eval "CorporatePolicy.Release.seed()"`.
    3. For CSV-based imports (states, cities, pincodes, etc.), consider
       running the import as a dedicated Mix task or a separate seeding
       service that has access to the CSV assets, then trigger it manually
       or via a scheduled job outside of the release boot process.

  ## Future work (Option B)

  To make `seed/0` work directly from within a release, the seed files
  would need to be copied into `priv/` as part of the build so they are
  bundled by `mix release` (Mix copies the whole `priv/` directory for the
  app by default, but Railpack/Docker-based builds may prune source files
  first). A custom release step (e.g. a `Mix.Release` step in `mix.exs` or a
  post-build script in the Railpack config) could copy `priv/repo/seeds/seeds.exs`
  and `priv/repo/seeds/` into the release's `priv` directory before
  packaging, after which `Code.eval_file/1` (resolved via
  `Application.app_dir(:corporate_policy, "priv/repo/seeds/seeds.exs")`) would
  succeed at runtime.
  """
  def seed do
    load_app()

    seeds_file = Application.app_dir(@app, @seeds_path)

    if File.exists?(seeds_file) do
      for repo <- repos() do
        {:ok, _, _} =
          Ecto.Migrator.with_repo(repo, fn _repo ->
            Code.eval_file(seeds_file)
          end)
      end
    else
      IO.warn("""
      Skipping CorporatePolicy.Release.seed/0: could not find #{seeds_file}.

      Seed source files (priv/repo/seeds/seeds.exs and priv/repo/seeds/*.exs) are \
      not included in this compiled release. Run seeds with \
      `MIX_ENV=prod mix run priv/repo/seeds/seeds.exs` from the source tree \
      (e.g. via Railway CLI or CI) instead, or package the seed files into \
      the release. See the @doc for CorporatePolicy.Release.seed/0 for details.
      """)

      :ok
    end
  end

  @doc """
  Creates and executes the `truncate_master_and_mapping_tables` stored procedure
  against the primary repo. Safe to run multiple times (uses CREATE OR REPLACE).

  ## Options
    - `dry_run` (boolean, default: `false`) – when `true`, prints the TRUNCATE
      statements without deleting any data.

  ## Usage from a Railway one-off command / release eval

      # Dry run (preview only – no data deleted)
      bin/corporate_policy eval "CorporatePolicy.Release.truncate_master_and_mapping_tables(true)"

      # Actual truncate
      bin/corporate_policy eval "CorporatePolicy.Release.truncate_master_and_mapping_tables()"

  ## Usage via Railway CLI (from source tree)

      railway run mix run -e "CorporatePolicy.Release.truncate_master_and_mapping_tables()"
  """
  def truncate_master_and_mapping_tables(dry_run \\ false) do
    load_app()

    create_procedure_sql = """
    CREATE OR REPLACE PROCEDURE truncate_master_and_mapping_tables(
        dry_run BOOLEAN DEFAULT FALSE
    )
    LANGUAGE plpgsql
    AS $$
    DECLARE
        tables_to_truncate TEXT[] := ARRAY[
            'trp_claim_submission_logs',
            'trn_endorsement_deletion_logs',
            'trn_mapping_corporate_contact_email_logs',
            'trn_mapping_corporateid_corporatecontactsids',
            'trn_mapping_live_employees',
            'trn_mapping_roleid_roleaccessdetails',
            'mapping_policy_completions',
            'mapping_policy_feature_templates_corporates_policies',
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
            'master_add_policies',
            'master_logos',
            'master_corporates'
        ];
        tbl           TEXT;
        sql_statement TEXT;
        truncated_cnt INT := 0;
        skipped_cnt   INT := 0;
    BEGIN
        RAISE NOTICE '================================================';
        RAISE NOTICE '  truncate_master_and_mapping_tables dry_run=%', dry_run;
        RAISE NOTICE '================================================';

        FOREACH tbl IN ARRAY tables_to_truncate LOOP
            sql_statement := format('TRUNCATE TABLE %I RESTART IDENTITY CASCADE', tbl);
            IF dry_run THEN
                RAISE NOTICE '[DRY RUN] %', sql_statement;
            ELSE
                IF EXISTS (
                    SELECT 1 FROM information_schema.tables
                    WHERE table_schema = current_schema() AND table_name = tbl
                ) THEN
                    EXECUTE sql_statement;
                    RAISE NOTICE '[OK] Truncated -> %', tbl;
                    truncated_cnt := truncated_cnt + 1;
                ELSE
                    RAISE WARNING '[SKIP] Not found -> %', tbl;
                    skipped_cnt := skipped_cnt + 1;
                END IF;
            END IF;
        END LOOP;

        IF dry_run THEN
            RAISE NOTICE 'DRY RUN complete — % tables listed, 0 rows deleted.', array_length(tables_to_truncate, 1);
        ELSE
            RAISE NOTICE 'Done — % truncated, % skipped.', truncated_cnt, skipped_cnt;
        END IF;
        RAISE NOTICE '================================================';
    END;
    $$;
    """

    call_procedure_sql = "CALL truncate_master_and_mapping_tables($1)"

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          IO.puts("==> [Release] Creating stored procedure...")
          Ecto.Adapters.SQL.query!(repo, create_procedure_sql, [])

          IO.puts("==> [Release] Calling procedure (dry_run=#{dry_run})...")
          Ecto.Adapters.SQL.query!(repo, call_procedure_sql, [dry_run])

          IO.puts("==> [Release] truncate_master_and_mapping_tables complete.")
        end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
