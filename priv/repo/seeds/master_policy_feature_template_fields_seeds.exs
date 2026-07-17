alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField
import Ecto.Query

# All fields from master_policy_feature_template_fields.csv
# {field_id, name, placeholder, field_type_id, template_id, status}
fields = [
  # GMC template (template_id = 1)
  {1,  "Feature Identifier",                              "Please Enter Template Name",               1, 1, 0},
  {2,  "Room Rent Limit",                                 "Room Rent Limit",                          1, 1, 0},
  {3,  "ICU Limit",                                       "Enter ICU Limit",                          1, 1, 0},
  {4,  "Proportionate deduction on exceeding room rent",  "Enter Proportionate deduction",            1, 1, 0},
  {5,  "Pre Hospitalization",                             "Enter Pre Hospitalization",                1, 1, 0},
  {6,  "Post Hospitalization",                            "Enter Post Hospitalization",               1, 1, 0},
  {7,  "Day Care",                                        "Enter Day Care",                           1, 1, 0},
  {8,  "Domiciliary Hospitalization",                     "Enter Domiciliary Hospitalization",        1, 1, 0},
  {9,  "Organ Donor Expenses",                            "Enter Organ Donor Expenses",               1, 1, 0},
  {10, "Ambulance",                                       "Enter Ambulance",                          1, 1, 0},
  {11, "Home Nursing",                                    "Enter Home Nursing",                       1, 1, 0},
  {12, "Maternity",                                       "Enter Maternity",                          1, 1, 0},
  {13, "New Born Baby",                                   "Enter New Born Baby",                      1, 1, 0},
  {14, "Vaccination for New Born Baby",                   "Enter Vaccination for New Born Baby",      1, 1, 0},
  {15, "OPD",                                             "Enter OPD",                               1, 1, 0},
  {16, "Dental OPD",                                      "Enter Dental OPD",                         1, 1, 0},
  {17, "Vision OPD",                                      "Enter Vision OPD",                         1, 1, 0},
  {18, "Psychiatric Illness",                             "Enter Psychiatric Illness",                1, 1, 0},
  {19, "Bariatric Surgery",                               "Enter Bariatric Surgery",                  1, 1, 0},
  {20, "Infertility Treatment",                           "Enter Infertility Treatment",              1, 1, 0},
  {21, "Preventive Health Check",                         "Enter Preventive Health Check",            1, 1, 0},
  {22, "Claim Loading",                                   "Enter Claim Loading",                      1, 1, 0},
  {23, "No Claim Discount",                               "Enter No Claim Discount",                  1, 1, 0},
  {24, "Sub Limits",                                      "Enter Sub Limits",                         1, 1, 0},
  {25, "Co Pay",                                          "Enter Co Pay",                             1, 1, 0},
  {26, "Deductible",                                      "Enter Deductible",                         1, 1, 0},
  {27, "Waiting Period",                                  "Enter Waiting Period",                     1, 1, 0},
  {28, "Disease Wise Limits",                             "Enter Disease Wise Limits",                1, 1, 0},
  {29, "Exclusions",                                      "Enter Exclusions",                         1, 1, 0},
  {30, "Medical Second Opinion",                          "Enter Medical Second Opinion",             1, 1, 0},
  # GPA template (template_id = 2)
  {51, "Feature Identifier",                              "Please Enter Template Name",               1, 2, 0},
  {52, "Age Limit",                                       "Enter Age Limit",                          1, 2, 0},
  {53, "Per person Sum Insured",                          "Enter Per person Sum Insured",             1, 2, 0},
  {54, "Accidental Death",                                "Enter Accidental Death",                   1, 2, 0},
  {55, "Permanent Total Disablement",                     "Enter Permanent Total Disablement",        1, 2, 0},
  {56, "Permanent Partial Disablement",                   "Enter Permanent Partial Disablement",      1, 2, 0},
  {57, "Temporary Total Disablement",                     "Enter Temporary Total Disablement",        1, 2, 0},
  {58, "Medical Expenses",                                "Enter Medical Expenses",                   1, 2, 0},
  {59, "Child Education Benefit",                         "Enter Child Education Benefit",            1, 2, 0},
  {60, "Terrorism Cover",                                 "Enter Terrorism Cover",                    1, 2, 0},
  {61, "Exclusions",                                      "Enter Exclusions",                         1, 2, 0},
]

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

Enum.each(fields, fn {field_id, name, placeholder, field_type_id, template_id, status} ->
  existing = Repo.one(from f in MasterPolicyFeatureTemplateField, where: f.id == ^field_id)

  if is_nil(existing) do
    Repo.insert_all(
      "master_policy_feature_template_fields",
      [%{
        id: field_id,
        name: name,
        placeholder: placeholder,
        field_type_id: field_type_id,
        template_id: template_id,
        status: status,
        is_mandatory: true,
        inserted_at: now,
        updated_at: now
      }],
      on_conflict: :nothing,
      conflict_target: :id
    )
    IO.puts("✓ Inserted: [template_id=#{template_id}] #{name}")
  else
    IO.puts("- Skipped (exists): #{name}")
  end
end)

IO.puts("\nDone! Total fields processed: #{length(fields)}")
