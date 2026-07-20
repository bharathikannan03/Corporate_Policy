defmodule CorporatePolicy.Repo.Migrations.CreateTrnMappingLiveEmployees do
  use Ecto.Migration

  def change do
    drop_if_exists table(:master_employee_data)

    create_if_not_exists table(:trn_mapping_live_employees) do
      add :ref_policy_id, references(:master_add_policies, on_delete: :nothing), null: false
      add :ref_corporate_id, references(:master_corporates, column: :corporate_id, on_delete: :nothing)
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
      add :status, :string, default: "active"
      add :source_type, :string

      add :created_by, :integer
      add :updated_by, :integer
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create_if_not_exists index(:trn_mapping_live_employees, [:ref_policy_id])
    create_if_not_exists index(:trn_mapping_live_employees, [:ref_corporate_id])

    create_if_not_exists unique_index(
                           :trn_mapping_live_employees,
                           [:ref_policy_id, :employee_code, :relationship],
                           name: :unique_policy_live_employee_relationship_index
                         )
  end
end
