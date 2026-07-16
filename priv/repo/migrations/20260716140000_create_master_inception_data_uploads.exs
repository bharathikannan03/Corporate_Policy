defmodule CorporatePolicy.Repo.Migrations.CreateMasterInceptionDataUploads do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:master_inception_data_uploads) do
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing), null: false
      add :employee_code, :string
      add :employee_name, :string
      add :gender, :string
      add :relationship, :string
      add :dob, :string
      add :age, :integer
      add :mobile_number, :string
      add :email, :string
      add :sum_insured, :float
      add :doj, :string
      add :endorsement_number, :string
      add :endorsement_date, :string
      add :endorsement_type, :string
      add :dol, :string
      add :member_card_number, :string
      add :designation, :string
      add :status, :string, default: "0"

      add :otp, :integer
      add :otp_expires_at, :utc_datetime
      add :is_register, :integer, default: 0
      add :is_mail_send, :integer, default: 0
      add :is_testuser, :integer, default: 0
      add :created_by, :integer
      add :updated_by, :integer
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create_if_not_exists index(:master_inception_data_uploads, [:ref_policy_id])
  end
end
