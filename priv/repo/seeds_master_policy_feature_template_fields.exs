alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField

# We will seed the template fields for Template ID 1 (Standard Health Policy)
# based on the legacy SQL dump.
fields = [
  %{
    name: "Feature Identifier",
    placeholder: "Please Enter Template Name",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: true,
    description: "",
    field_grouping_id: "0"
  },
  %{
    name: "Room Rent Limit",
    placeholder: "Room Rent Limit",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: true,
    description: "When You get get hospitalized for an ailment the cost of the room allotted to you as per the category you choose is room rent.",
    field_grouping_id: "5"
  },
  %{
    name: "ICU Limit",
    placeholder: "Enter ICU Limit",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: true,
    description: "When a person admitted in the intensive care unit (ICU) the daily charges for the same will be payable",
    field_grouping_id: "5"
  },
  %{
    name: "Maternity Cover",
    placeholder: "",
    field_type_id: 4, # Radio/Checkbox
    template_id: 1,
    status: 0,
    is_mandatory: true,
    description: "Under this benefit a female who is covered under the policy can claim expenses incurred on account of child birth",
    field_grouping_id: "2"
  },
  %{
    name: "Maternity Waiting Period",
    placeholder: "Enter Maternity Waiting Period",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: false,
    description: "",
    field_grouping_id: "2"
  },
  %{
    name: "Normal delivery sum Insured",
    placeholder: "Enter Normal delivery sum Insured",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: false,
    description: "",
    field_grouping_id: "2"
  },
  %{
    name: "C Sec - sum insured",
    placeholder: "Enter C Sec - sum insured",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: false,
    description: "Caesarean section sum insured",
    field_grouping_id: "2"
  },
  %{
    name: "Copay",
    placeholder: "",
    field_type_id: 4,
    template_id: 1,
    status: 0,
    is_mandatory: true,
    description: "When you claim co-pay will be the amount which will be deducted from your admissible claim amount",
    field_grouping_id: "15"
  },
  %{
    name: "Copay Deduction In %",
    placeholder: "Enter Copay Deduction In %",
    field_type_id: 1,
    template_id: 1,
    status: 0,
    is_mandatory: false,
    description: "",
    field_grouping_id: "15"
  }
]

for field_data <- fields do
  case Repo.get_by(MasterPolicyFeatureTemplateField, name: field_data.name, template_id: field_data.template_id) do
    nil ->
      %MasterPolicyFeatureTemplateField{}
      |> MasterPolicyFeatureTemplateField.changeset(field_data)
      |> Repo.insert!()
    _field ->
      :ok
  end
end

IO.puts("Successfully seeded Master Policy Feature Template Fields!")
