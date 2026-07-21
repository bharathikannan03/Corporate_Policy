defmodule CorporatePolicy.Repo.Migrations.UpdateSelfToEmployeeInTables do
  use Ecto.Migration

  def change do
    execute "UPDATE trn_mapping_live_employees SET relationship = 'Employee' WHERE LOWER(relationship) = 'self';"

    execute "UPDATE master_inception_data_uploads SET relationship = 'Employee' WHERE LOWER(relationship) = 'self';"

    execute "UPDATE master_endorsement_data_uploads SET relationship = 'Employee' WHERE LOWER(relationship) = 'self';"
  end
end
