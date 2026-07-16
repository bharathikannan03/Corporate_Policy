defmodule DropOrphanedTables do
  def run do
    tables = [
      "master_policy_feature_template_fields",
      "master_sum_insureds",
      "master_policy_data_uploads",
      "master_policy_escalation_matrices",
      "master_policy_documents",
      "master_policy_cd_statements",
      "md_document_types",
      "md_document_names",
      "md_escalation_matrices"
    ]

    Enum.each(tables, fn table ->
      IO.puts("Dropping table #{table}...")
      Ecto.Adapters.SQL.query!(CorporatePolicy.Repo, "DROP TABLE IF EXISTS #{table} CASCADE")
    end)
    
    IO.puts("All orphaned tables dropped successfully!")
  end
end

DropOrphanedTables.run()
