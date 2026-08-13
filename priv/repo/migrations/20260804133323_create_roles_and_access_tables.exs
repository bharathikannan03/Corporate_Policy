defmodule CorporatePolicy.Repo.Migrations.CreateRolesAndAccessTables do
  use Ecto.Migration

  def up do
    # 1. Drop existing tables if they exist
    drop_if_exists table(:trn_mapping_roleid_roleaccessdetails)
    drop_if_exists table(:md_role_accessdetails)
    drop_if_exists table(:md_visibility_role_id_feature_tmps)

    # 2. Recreate md_visibility_role_id_feature_tmps
    create table(:md_visibility_role_id_feature_tmps, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: true
      add :role, :string, size: 50, null: false
      add :status, :integer, null: false, default: 0
      add :is_visible, :integer, null: false, default: 2
      add :ref_feature_template_field_id, :bigint, null: true
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end

    # Create sequence for auto-generating role_id starting at 5
    execute "CREATE SEQUENCE md_visibility_role_id_feature_tmps_role_id_seq START WITH 5"

    execute "ALTER TABLE md_visibility_role_id_feature_tmps ALTER COLUMN role_id SET DEFAULT nextval('md_visibility_role_id_feature_tmps_role_id_seq')"

    create index(:md_visibility_role_id_feature_tmps, [:role_id])
    create unique_index(:md_visibility_role_id_feature_tmps, [:role], where: "deleted_at IS NULL")

    # 3. Create md_role_accessdetail_modules
    create table(:md_role_accessdetail_modules, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :module_id, :integer, null: false
      add :module_name, :string, size: 50, null: false
      add :status, :integer, null: false, default: 0
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end

    create index(:md_role_accessdetail_modules, [:module_id])

    create unique_index(:md_role_accessdetail_modules, [:module_name],
             where: "deleted_at IS NULL"
           )

    # 4. Create md_role_accessdetail_module_options
    create table(:md_role_accessdetail_module_options, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :module_option_id, :integer, null: false
      add :module_option_name, :string, size: 50, null: false
      add :status, :integer, null: false, default: 0
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end

    create index(:md_role_accessdetail_module_options, [:module_option_id])

    create unique_index(:md_role_accessdetail_module_options, [:module_option_name],
             where: "deleted_at IS NULL"
           )

    # 5. Recreate trn_mapping_roleid_roleaccessdetails
    create table(:trn_mapping_roleid_roleaccessdetails, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :role_id, :integer, null: false
      add :module_id, :integer, null: false
      add :module_option_id, :integer, null: false
      add :selection_status, :boolean, null: false, default: false
      add :status, :integer, null: false, default: 0
      add :deleted_at, :utc_datetime_usec, null: true

      timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime_usec)
    end

    create index(:trn_mapping_roleid_roleaccessdetails, [:role_id])
    create index(:trn_mapping_roleid_roleaccessdetails, [:module_id])
    create index(:trn_mapping_roleid_roleaccessdetails, [:module_option_id])

    create unique_index(
             :trn_mapping_roleid_roleaccessdetails,
             [:role_id, :module_id, :module_option_id],
             name: :trn_mapping_role_module_option_idx,
             where: "deleted_at IS NULL"
           )
  end

  def down do
    drop_if_exists table(:trn_mapping_roleid_roleaccessdetails)
    drop_if_exists table(:md_role_accessdetail_module_options)
    drop_if_exists table(:md_role_accessdetail_modules)
    execute "DROP SEQUENCE IF EXISTS md_visibility_role_id_feature_tmps_role_id_seq"
    drop_if_exists table(:md_visibility_role_id_feature_tmps)
  end
end
