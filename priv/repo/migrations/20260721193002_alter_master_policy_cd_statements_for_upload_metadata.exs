defmodule CorporatePolicy.Repo.Migrations.AlterMasterPolicyCdStatementsForUploadMetadata do
  use Ecto.Migration

  def change do
    alter table(:master_policy_cd_statements) do
      add_if_not_exists :original_file_name, :string, size: 200
      add_if_not_exists :status, :integer, default: 0, null: false
    end
  end
end
