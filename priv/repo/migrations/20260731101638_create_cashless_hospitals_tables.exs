defmodule CorporatePolicy.Repo.Migrations.CreateCashlessHospitalsTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_cashless_hospitals, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :ref_insurer_id, :bigint, null: false
      add :insurer_name, :string, size: 255, null: false
      add :ref_tpa_id, :bigint
      add :tpa_name, :string, size: 255
      add :ch_upload_data, :string, size: 255, null: false
      add :ref_corporate_id, :bigint
      add :status, :integer, default: 0, null: false
      add :is_dataupload, :integer, default: 0, null: false
      add :original_file_name, :string, size: 200
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists index(:master_cashless_hospitals, [:ref_insurer_id])
    create_if_not_exists index(:master_cashless_hospitals, [:ref_tpa_id])
    create_if_not_exists index(:master_cashless_hospitals, [:status])

    create_if_not_exists table(:master_cashless_hospital_uploads, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :hospital_name, :string, size: 255
      add :hospital_address, :text
      add :location, :string, size: 255
      add :landmark, :string, size: 255
      add :city, :string, size: 150
      add :state, :string, size: 150
      add :pincode, :integer
      add :email, :string, size: 150
      add :stdcode, :string, size: 150
      add :phone, :string, size: 15
      add :insurer_name, :string, size: 150
      add :ref_insurer_id, :bigint
      add :tpa_name, :string, size: 255
      # matching laravel varchar(255)
      add :ref_tpa_id, :string, size: 255
      add :status, :string, size: 255, default: "0", null: false
      add :latitude, :decimal, precision: 10, scale: 7
      add :longitude, :decimal, precision: 10, scale: 7
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    # Create index for TPA ID on hospital uploads (requested by user)
    create_if_not_exists index(:master_cashless_hospital_uploads, [:ref_tpa_id])
    create_if_not_exists index(:master_cashless_hospital_uploads, [:ref_insurer_id])
    create_if_not_exists index(:master_cashless_hospital_uploads, [:latitude])
    create_if_not_exists index(:master_cashless_hospital_uploads, [:longitude])
  end
end
