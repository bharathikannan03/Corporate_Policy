# priv/repo/seeds/02_policy_features.exs

alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.Policy
alias CorporatePolicy.Policies.MasterSumInsured
alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField
alias CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy
import Ecto.Query

IO.puts("Loading Policy Features and Sum Insured seeds...")

# 1. Clean up existing mappings and sum insureds for clean re-runs
Repo.delete_all(MasterSumInsured)
Repo.delete_all(MappingPolicyFeatureTemplatesCorporatesPolicy)

# Fetch target policies
gmc_policy = Repo.one(from p in Policy, where: p.policy_type == "GMC", limit: 1)
gpa_policy = Repo.one(from p in Policy, where: p.policy_type == "GPA", limit: 1)

if is_nil(gmc_policy) do
  IO.puts("⚠ GMC Policy not found in database. Please run mix setup or mix db seed first.")
else
  IO.puts("Found GMC Policy: #{gmc_policy.policy_number} for #{gmc_policy.corporate_name}")

  # Helper to create feature mapping entry
  create_feature = fn field_name, value, parent_id, template_id, policy ->
    field = Repo.get_by(MasterPolicyFeatureTemplateField, policy_feature_template_field_name: field_name, ref_template_id: template_id)
    if is_nil(field) do
      IO.puts("  ⚠ Field '#{field_name}' not found for template #{template_id}")
      nil
    else
      mapping = %MappingPolicyFeatureTemplatesCorporatesPolicy{}
      |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
        ref_policy_feature_template_field_name: field.policy_feature_template_field_name,
        policy_feature_template_field_value: value,
        ref_template_id: template_id,
        ref_coporate_id: policy.ref_corporate_id,
        ref_policy_id: policy.id,
        ref_policy_feature_template_field_id: field.template_field_id,
        ref_policy_feature_template_field_type_id: field.ref_master_temp_field_Type,
        policy_feature_template_field_visibility_role_ids: "1,2,3",
        ref_policyidentifier_id: parent_id,
        status: 1
      })
      |> Repo.insert!()
      mapping
    end
  end

  # GMC Mappings Setup (300k, 500k, 750k)
  gmc_groups = [
    {300_000, [
      {"Room Rent Limit", "1% SUM INSURED PER DAY"},
      {"ICU Limit", "2% SUM INSURED PER DAY"},
      {"Maternity Cover", "Covered"},
      {"Maternity Waiting Period", "9 Months"},
      {"Normal delivery sum Insured", "35000"},
      {"C Sec - sum insured", "50000"},
      {"Copay", "Yes"},
      {"Copay Deduction In %", "10%"},
      {"Ambulance", "Covered up to 2000 per hospitalization"},
      {"Home Nursing", "Not Covered"},
      {"Maternity", "Pre and Post-natal treatment covered within maternity limits"},
      {"New Born Baby", "Covered from Day 1"},
      {"Vaccination for New Born Baby", "Covered up to 5000"},
      {"OPD", "Not Covered"},
      {"Dental OPD", "Not Covered"},
      {"Vision OPD", "Not Covered"},
      {"Psychiatric Illness", "Covered up to Sum Insured"},
      {"Bariatric Surgery", "Covered after 3 years waiting period"},
      {"Infertility Treatment", "Not Covered"},
      {"Preventive Health Check", "Covered up to 1000 per family"},
      {"Claim Loading", "No claim loading"},
      {"No Claim Discount", "No claim discount"},
      {"Sub Limits", "No sub limits except room rent"},
      {"Co Pay", "10% on all claims"},
      {"Deductible", "Nil"},
      {"Waiting Period", "30 days waiting period (not applicable for accident)"},
      {"Disease Wise Limits", "Not Applicable"},
      {"Exclusions", "Self injury, war, cosmetic treatment"},
      {"Medical Second Opinion", "Covered"}
    ]},
    {500_000, [
      {"Room Rent Limit", "2% SUM INSURED PER DAY"},
      {"ICU Limit", "3% SUM INSURED PER DAY"},
      {"Maternity Cover", "Covered"},
      {"Maternity Waiting Period", "9 Months"},
      {"Normal delivery sum Insured", "50000"},
      {"C Sec - sum insured", "75000"},
      {"Copay", "Yes"},
      {"Copay Deduction In %", "10%"},
      {"Ambulance", "Covered up to 3000 per hospitalization"},
      {"Home Nursing", "Not Covered"},
      {"Maternity", "Pre and Post-natal treatment covered within maternity limits"},
      {"New Born Baby", "Covered from Day 1"},
      {"Vaccination for New Born Baby", "Covered up to 5000"},
      {"OPD", "Not Covered"},
      {"Dental OPD", "Not Covered"},
      {"Vision OPD", "Not Covered"},
      {"Psychiatric Illness", "Covered up to Sum Insured"},
      {"Bariatric Surgery", "Covered after 3 years waiting period"},
      {"Infertility Treatment", "Not Covered"},
      {"Preventive Health Check", "Covered up to 1500 per family"},
      {"Claim Loading", "No claim loading"},
      {"No Claim Discount", "No claim discount"},
      {"Sub Limits", "No sub limits except room rent"},
      {"Co Pay", "10% on all claims"},
      {"Deductible", "Nil"},
      {"Waiting Period", "30 days waiting period (not applicable for accident)"},
      {"Disease Wise Limits", "Not Applicable"},
      {"Exclusions", "Self injury, war, cosmetic treatment"},
      {"Medical Second Opinion", "Covered"}
    ]},
    {750_000, [
      {"Room Rent Limit", "Single Private A/C Room"},
      {"ICU Limit", "No Limit"},
      {"Maternity Cover", "Covered"},
      {"Maternity Waiting Period", "9 Months"},
      {"Normal delivery sum Insured", "75000"},
      {"C Sec - sum insured", "100000"},
      {"Copay", "Yes"},
      {"Copay Deduction In %", "10%"},
      {"Ambulance", "Covered up to 5000 per hospitalization"},
      {"Home Nursing", "Not Covered"},
      {"Maternity", "Pre and Post-natal treatment covered within maternity limits"},
      {"New Born Baby", "Covered from Day 1"},
      {"Vaccination for New Born Baby", "Covered up to 7500"},
      {"OPD", "Not Covered"},
      {"Dental OPD", "Not Covered"},
      {"Vision OPD", "Not Covered"},
      {"Psychiatric Illness", "Covered up to Sum Insured"},
      {"Bariatric Surgery", "Covered after 3 years waiting period"},
      {"Infertility Treatment", "Not Covered"},
      {"Preventive Health Check", "Covered up to 2000 per family"},
      {"Claim Loading", "No claim loading"},
      {"No Claim Discount", "No claim discount"},
      {"Sub Limits", "No sub limits except room rent"},
      {"Co Pay", "10% on all claims"},
      {"Deductible", "Nil"},
      {"Waiting Period", "30 days waiting period (not applicable for accident)"},
      {"Disease Wise Limits", "Not Applicable"},
      {"Exclusions", "Self injury, war, cosmetic treatment"},
      {"Medical Second Opinion", "Covered"}
    ]}
  ]

  for {si_amount, features} <- gmc_groups do
    # Create GMC Feature Identifier parent
    parent_field = Repo.get_by!(MasterPolicyFeatureTemplateField, policy_feature_template_field_name: "Feature Identifier", ref_template_id: 1)
    
    parent_mapping = %MappingPolicyFeatureTemplatesCorporatesPolicy{}
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
      ref_policy_feature_template_field_name: parent_field.policy_feature_template_field_name,
      policy_feature_template_field_value: "GMC",
      ref_template_id: 1,
      ref_coporate_id: gmc_policy.ref_corporate_id,
      ref_policy_id: gmc_policy.id,
      ref_policy_feature_template_field_id: parent_field.template_field_id,
      ref_policy_feature_template_field_type_id: parent_field.ref_master_temp_field_Type,
      policy_feature_template_field_visibility_role_ids: "1,2,3",
      status: 1
    })
    |> Repo.insert!()

    # Set self-ref parent id
    parent_mapping
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{ref_policyidentifier_id: parent_mapping.policy_feature_template_field_value_id})
    |> Repo.update!()

    # Insert rest of features referencing the parent ID
    for {name, val} <- features do
      create_feature.(name, val, parent_mapping.policy_feature_template_field_value_id, 1, gmc_policy)
    end

    # Insert MasterSumInsured
    %MasterSumInsured{}
    |> MasterSumInsured.changeset(%{
      sum_insured: si_amount,
      policy_feature_identifier: "GMC",
      template_id: 1,
      policy_id: gmc_policy.id,
      feature_identifier_id: parent_mapping.policy_feature_template_field_value_id,
      status: 1
    })
    |> Repo.insert!()

    IO.puts("  ✓ Seeded GMC features for Sum Insured: #{si_amount}")
  end
end

if is_nil(gpa_policy) do
  IO.puts("⚠ GPA Policy not found in database. Skipping GPA seeding.")
else
  IO.puts("Found GPA Policy: #{gpa_policy.policy_number} for #{gpa_policy.corporate_name}")

  # Create GPA Feature Identifier parent
  parent_field = Repo.get_by!(MasterPolicyFeatureTemplateField, policy_feature_template_field_name: "Feature Identifier", ref_template_id: 2)
  
  parent_mapping = %MappingPolicyFeatureTemplatesCorporatesPolicy{}
  |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
    ref_policy_feature_template_field_name: parent_field.policy_feature_template_field_name,
    policy_feature_template_field_value: "GPA",
    ref_template_id: 2,
    ref_coporate_id: gpa_policy.ref_corporate_id,
    ref_policy_id: gpa_policy.id,
    ref_policy_feature_template_field_id: parent_field.template_field_id,
    ref_policy_feature_template_field_type_id: parent_field.ref_master_temp_field_Type,
    policy_feature_template_field_visibility_role_ids: "1,2,3",
    status: 1
  })
  |> Repo.insert!()

  parent_mapping
  |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{ref_policyidentifier_id: parent_mapping.policy_feature_template_field_value_id})
  |> Repo.update!()

  # Helper to create feature mapping entry for GPA
  create_feature = fn field_name, value, parent_id, template_id, policy ->
    field = Repo.get_by(MasterPolicyFeatureTemplateField, policy_feature_template_field_name: field_name, ref_template_id: template_id)
    if is_nil(field) do
      IO.puts("  ⚠ Field '#{field_name}' not found for template #{template_id}")
      nil
    else
      mapping = %MappingPolicyFeatureTemplatesCorporatesPolicy{}
      |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(%{
        ref_policy_feature_template_field_name: field.policy_feature_template_field_name,
        policy_feature_template_field_value: value,
        ref_template_id: template_id,
        ref_coporate_id: policy.ref_corporate_id,
        ref_policy_id: policy.id,
        ref_policy_feature_template_field_id: field.template_field_id,
        ref_policy_feature_template_field_type_id: field.ref_master_temp_field_Type,
        policy_feature_template_field_visibility_role_ids: "1,2,3",
        ref_policyidentifier_id: parent_id,
        status: 1
      })
      |> Repo.insert!()
      mapping
    end
  end

  gpa_features = [
    {"Age Limit", "18 to 65 Years"},
    {"Per person Sum Insured", "500000"},
    {"Accidental Death", "Covered (100% of Sum Insured)"},
    {"Permanent Total Disablement", "Covered"},
    {"Permanent Partial Disablement", "Covered"},
    {"Temporary Total Disablement", "Covered"},
    {"Medical Expenses", "Covered up to 25% of valid claim or 10% of Sum Insured"},
    {"Child Education Benefit", "Covered"},
    {"Terrorism Cover", "Covered"},
    {"Exclusions", "Self injury, war, active participation in riots"}
  ]

  for {name, val} <- gpa_features do
    create_feature.(name, val, parent_mapping.policy_feature_template_field_value_id, 2, gpa_policy)
  end

  # Insert MasterSumInsured for GPA
  %MasterSumInsured{}
  |> MasterSumInsured.changeset(%{
    sum_insured: 500_000,
    policy_feature_identifier: "GPA",
    template_id: 2,
    policy_id: gpa_policy.id,
    feature_identifier_id: parent_mapping.policy_feature_template_field_value_id,
    status: 1
  })
  |> Repo.insert!()

  IO.puts("  ✓ Seeded GPA features for Sum Insured: 500000")
end

IO.puts("Seeding completed successfully!")
