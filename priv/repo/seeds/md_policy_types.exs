# priv/repo/seeds/md_policy_types.exs
alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.LineOfBusiness
alias CorporatePolicy.Policies.PolicyType

# Get LOB IDs for reference
health_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Health")
life_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Life")
others_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Others")

policy_types = [
  # Health (LOB ID 1)
  %{policy_type_value: "GMC", display_id: 1, status: 1, ref_md_line_of_businesses_id: health_lob.id},
  %{policy_type_value: "GPA", display_id: 2, status: 1, ref_md_line_of_businesses_id: health_lob.id},
  %{policy_type_value: "Parent Policy", display_id: 3, status: 1, ref_md_line_of_businesses_id: health_lob.id},
  %{policy_type_value: "Top up Policy", display_id: 4, status: 1, ref_md_line_of_businesses_id: health_lob.id},

  # Life (LOB ID 2)
  %{policy_type_value: "GTL", display_id: 5, status: 1, ref_md_line_of_businesses_id: life_lob.id},

  # Others (LOB ID 3)
  %{policy_type_value: "Marine", display_id: 6, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Fire", display_id: 7, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Office Package", display_id: 8, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Motor Insurance", display_id: 9, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Travel Insurance", display_id: 10, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Property Insurance", display_id: 11, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Commercial Insurance", display_id: 12, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Asset Insurance", display_id: 13, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Pet Insurance", display_id: 14, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Bite-Sized Insurance", display_id: 15, status: 1, ref_md_line_of_businesses_id: others_lob.id},
  %{policy_type_value: "Workmen Compensation", display_id: 16, status: 1, ref_md_line_of_businesses_id: others_lob.id}
]

Enum.each(policy_types, fn attrs ->
  case Repo.get_by(PolicyType, policy_type_value: attrs.policy_type_value) do
    nil ->
      %PolicyType{} |> PolicyType.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Policy Type: #{attrs.policy_type_value}")

    _ ->
      :ok
  end
end)
