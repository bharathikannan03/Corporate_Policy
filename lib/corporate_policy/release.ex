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

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
