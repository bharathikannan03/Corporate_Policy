defmodule CorporatePolicy.Repo.Migrations.CreateMasterCorporates do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_corporates, primary_key: false) do
      add :corporate_id, :bigserial, primary_key: true
      add :corporate_name, :string, null: false
      add :ref_master_corporate_logos_id, :integer
      add :coporate_contact_email, :string, size: 255
      add :corporate_landline, :string, size: 255
      add :ref_master_pincode_pincode_id, :integer, null: false, default: 0
      add :ref_master_city_city_id, :integer, null: false, default: 0
      add :ref_master_state_state_id, :integer, null: false, default: 0
      add :corporate_address, :string, null: false
      add :corporate_group_code, :string, size: 255
      add :industry_type, :string, size: 255
      add :corporate_buffer_visibility, :integer, default: 0, null: false
      add :corporate_status, :integer, default: 0, null: false
      add :pincode, :string, size: 10, null: false, default: ""
      add :city, :string, size: 25, null: false, default: ""
      add :state, :string, size: 25, null: false, default: ""
      add :helpline_no, :string, size: 255
      add :pan_number, :string, size: 15
      add :branch_name, :string, size: 255
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end
  end
end
