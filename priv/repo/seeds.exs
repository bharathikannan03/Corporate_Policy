alias CorporatePolicy.Repo
alias CorporatePolicy.Accounts.User
alias CorporatePolicy.Policies.LineOfBusiness
alias CorporatePolicy.Policies.PolicyType
alias CorporatePolicy.Policies.SumInsuredType
alias CorporatePolicy.Policies.Insurer
alias CorporatePolicy.Policies.Tpa
alias CorporatePolicy.Policies.FamilyDefinition
alias CorporatePolicy.Policies.IntimateClaimVisibility
alias CorporatePolicy.Policies.Corporate
alias CorporatePolicy.Policies.FinancialYear

# ─── Admin User ───────────────────────────────────────────────────────────────
admin_attrs = %{
  first_name: "Admin",
  last_name: "User",
  email_address: "admin@gmail.com",
  password: "admin@123",
  status: 1
}

case Repo.get_by(User, email_address: admin_attrs.email_address) do
  nil ->
    %User{}
    |> User.changeset(admin_attrs)
    |> Repo.insert!()

    IO.puts("✓ Admin user created: #{admin_attrs.email_address}")

  _existing ->
    IO.puts("→ Admin user already exists: #{admin_attrs.email_address}")
end

# ─── Line of Business ──────────────────────────────────────────────────────────
lobs = [
  %{line_of_business_value: "Health", display_id: 1, status: 1},
  %{line_of_business_value: "Life", display_id: 2, status: 1},
  %{line_of_business_value: "Others", display_id: 3, status: 1}
]

Enum.each(lobs, fn attrs ->
  case Repo.get_by(LineOfBusiness, line_of_business_value: attrs.line_of_business_value) do
    nil ->
      %LineOfBusiness{} |> LineOfBusiness.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ LOB: #{attrs.line_of_business_value}")

    _ ->
      :ok
  end
end)

# Get LOB IDs for reference
health_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Health")
life_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Life")
others_lob = Repo.get_by(LineOfBusiness, line_of_business_value: "Others")

# ─── Policy Types ──────────────────────────────────────────────────────────────
policy_types = [
  # Health (LOB ID 1)
  %{
    policy_type_value: "GMC",
    display_id: 1,
    status: 1,
    ref_md_line_of_businesses_id: health_lob.id
  },
  %{
    policy_type_value: "GPA",
    display_id: 2,
    status: 1,
    ref_md_line_of_businesses_id: health_lob.id
  },
  %{
    policy_type_value: "Parent Policy",
    display_id: 3,
    status: 1,
    ref_md_line_of_businesses_id: health_lob.id
  },
  %{
    policy_type_value: "Top up Policy",
    display_id: 4,
    status: 1,
    ref_md_line_of_businesses_id: health_lob.id
  },

  # Life (LOB ID 2)
  %{
    policy_type_value: "GTL",
    display_id: 5,
    status: 1,
    ref_md_line_of_businesses_id: life_lob.id
  },

  # Others (LOB ID 3)
  %{
    policy_type_value: "Marine",
    display_id: 6,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Fire",
    display_id: 7,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Office Package",
    display_id: 8,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Motor Insurance",
    display_id: 9,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Travel Insurance",
    display_id: 10,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Property Insurance",
    display_id: 11,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Commercial Insurance",
    display_id: 12,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Asset Insurance",
    display_id: 13,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Pet Insurance",
    display_id: 14,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Bite-Sized Insurance",
    display_id: 15,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  },
  %{
    policy_type_value: "Workmen Compensation",
    display_id: 16,
    status: 1,
    ref_md_line_of_businesses_id: others_lob.id
  }
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

# ─── Sum Insured Types ─────────────────────────────────────────────────────────
sum_insured_types = [
  %{name: "Slab wise", display_id: 1, status: 1},
  %{name: "Grade wise", display_id: 2, status: 1}
]

Enum.each(sum_insured_types, fn attrs ->
  case Repo.get_by(SumInsuredType, name: attrs.name) do
    nil ->
      %SumInsuredType{} |> SumInsuredType.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Sum Insured Type: #{attrs.name}")

    _ ->
      :ok
  end
end)

# ─── Insurers ──────────────────────────────────────────────────────────────────
# Health insurers (LOB 1)
health_insurers = [
  "Acko General Insurance Limited",
  "Aditya Birla Health Insurance Co. Limited",
  "Agriculture Insurance Co. of India Ltd.",
  "Apollo Munich Health Insurance Company Limited",
  "Bajaj Allianz General Insurance Co. Ltd.",
  "Bharti AXA General Insurance Company Limited",
  "Cholamandalam MS General Insurance Co. Ltd.",
  "Cigna TTK Health Insurance Company Ltd.",
  "DHFL General Insurance Limited",
  "Edelweiss General Insurance",
  "Export Credit Guarantee Corporation of India Ltd.",
  "Future Generali India Insurance Company Limited",
  "Go Digit General Insurance Limited",
  "HDFC ERGO General Insurance Co. Ltd.",
  "ICICI Lombard General Insurance Co. Ltd.",
  "IFFCO Tokio General Insurance Co. Ltd.",
  "Kotak Mahindra General Insurance Company Limited",
  "Liberty Videocon General Insurance Company Limited",
  "Magma HDI General Insurance Company Limited",
  "Max Bupa Health Insurance Company Ltd.",
  "National Insurance Co. Ltd.",
  "Others Not available",
  "Raheja QBE General Insurance Company Limited",
  "Reliance General Insurance Co. Ltd.",
  "Religare Health Insurance Company Limited",
  "Royal Sundaram General Insurance Co. Limited",
  "SBI General Insurance Company Limited",
  "Shriram General Insurance Company Limited",
  "Star Health and Allied Insurance Company Limited",
  "Tata AIG General Insurance Co. Ltd.",
  "The New India Assurance Co. Ltd.",
  "The Oriental Insurance Co. Ltd.",
  "United India Insurance Co. Ltd.",
  "Universal Sompo General Insurance Co. Ltd.",
  "Galaxy Health Insurance Company Limited"
]

Enum.each(health_insurers, fn name ->
  attrs = %{name: name, status: 1, ref_md_line_of_businesses_id: health_lob.id}

  case Repo.get_by(Insurer, name: name, ref_md_line_of_businesses_id: health_lob.id) do
    nil ->
      %Insurer{} |> Insurer.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Health Insurer: #{name}")

    _ ->
      :ok
  end
end)

# Life insurers (LOB 2) - using some common life insurers
life_insurers = [
  "HDFC Life Insurance Company Limited",
  "ICICI Prudential Life Insurance Company Limited",
  "SBI Life Insurance Company Limited",
  "Max Life Insurance Company Limited",
  "Bajaj Allianz Life Insurance Company Limited",
  "Aditya Birla Sun Life Insurance Company Limited",
  "Tata AIA Life Insurance Company Limited",
  "PNB MetLife India Insurance Company Limited",
  "Reliance Nippon Life Insurance Company Limited",
  "Kotak Mahindra Life Insurance Company Limited"
]

Enum.each(life_insurers, fn name ->
  attrs = %{name: name, status: 1, ref_md_line_of_businesses_id: life_lob.id}

  case Repo.get_by(Insurer, name: name, ref_md_line_of_businesses_id: life_lob.id) do
    nil ->
      %Insurer{} |> Insurer.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Life Insurer: #{name}")

    _ ->
      :ok
  end
end)

# Others insurers (LOB 3) - general insurance companies
others_insurers = [
  "New India Assurance",
  "United India Insurance",
  "Oriental Insurance",
  "National Insurance",
  "ICICI Lombard General",
  "Bajaj Allianz General",
  "HDFC ERGO General",
  "Tata AIG General",
  "Reliance General",
  "Royal Sundaram General",
  "SBI General",
  "Future Generali",
  "Universal Sompo",
  "IFFCO Tokio",
  "Cholamandalam MS",
  "Go Digit",
  "Kotak Mahindra General",
  "Liberty General",
  "Magma HDI",
  "Raheja QBE",
  "Shriram General"
]

Enum.each(others_insurers, fn name ->
  attrs = %{name: name, status: 1, ref_md_line_of_businesses_id: others_lob.id}

  case Repo.get_by(Insurer, name: name, ref_md_line_of_businesses_id: others_lob.id) do
    nil ->
      %Insurer{} |> Insurer.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Others Insurer: #{name}")

    _ ->
      :ok
  end
end)

# ─── TPAs ──────────────────────────────────────────────────────────────────────
tpas = [
  %{name: "Medi Assist India", status: 1},
  %{name: "Raksha Health Insurance TPA", status: 1},
  %{name: "Park Mediclaim TPA", status: 1},
  %{name: "FHPL - Family Health Plan", status: 1}
]

Enum.each(tpas, fn attrs ->
  case Repo.get_by(Tpa, name: attrs.name) do
    nil ->
      %Tpa{} |> Tpa.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ TPA: #{attrs.name}")

    _ ->
      :ok
  end
end)

# ─── Family Definitions ────────────────────────────────────────────────────────
family_definitions = [
  %{name: "Self Only", display_id: 1, status: 1},
  %{name: "Self + Spouse + 2 Children", display_id: 2, status: 1},
  %{name: "Self + Spouse + 2 Children + 2 Parents or 2 In Laws", display_id: 3, status: 1},
  %{name: "Self + Spouse + 2 Children + 2 Parents + 2 Siblings", display_id: 4, status: 1},
  %{name: "Self + Spouse + 4 Children", display_id: 5, status: 1},
  %{name: "Parents Only", display_id: 6, status: 1}
]

Enum.each(family_definitions, fn attrs ->
  case Repo.get_by(FamilyDefinition, name: attrs.name) do
    nil ->
      %FamilyDefinition{} |> FamilyDefinition.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Family Definition: #{attrs.name}")

    _ ->
      :ok
  end
end)

# ─── Claim Intimation Visibilities ─────────────────────────────────────────────
claim_visibilities = [
  %{name: "Both", display_id: 1, status: 1},
  %{name: "IPD only", display_id: 2, status: 1},
  %{name: "OPD only", display_id: 3, status: 1}
]

Enum.each(claim_visibilities, fn attrs ->
  case Repo.get_by(IntimateClaimVisibility, name: attrs.name) do
    nil ->
      %IntimateClaimVisibility{} |> IntimateClaimVisibility.changeset(attrs) |> Repo.insert!()
      IO.puts("✓ Claim Visibility: #{attrs.name}")

    _ ->
      :ok
  end
end)

# ─── Sample Corporate ──────────────────────────────────────────────────────────
sample_corporate_attrs = %{
  corporate_name: "Sample Corp Ltd",
  corporate_address: "123 Business Park",
  coporate_contact_email: "info@samplecorp.com",
  corporate_landline: "022-12345678",
  status: 1,
  corporate_status: 1
}

case Repo.get_by(Corporate, corporate_name: sample_corporate_attrs.corporate_name) do
  nil ->
    %Corporate{} |> Corporate.changeset(sample_corporate_attrs) |> Repo.insert!()
    IO.puts("✓ Corporate: #{sample_corporate_attrs.corporate_name}")

  _ ->
    :ok
end

# ─── Financial Years (Current + Previous) ────────────────────────────────────
today = Date.utc_today()
current_year = today.year

Enum.each([current_year - 1, current_year, current_year + 1], fn year ->
  year_name = to_string(year)

  case Repo.get_by(FinancialYear, year_name: year_name) do
    nil ->
      %FinancialYear{}
      |> FinancialYear.changeset(%{
        year_name: year_name,
        start_date: Date.new!(year, 4, 1),
        end_date: Date.new!(year + 1, 3, 31),
        status: if(year == current_year, do: 1, else: 0)
      })
      |> Repo.insert!()

      IO.puts("✓ Financial Year: #{year_name}")

    _ ->
      :ok
  end
end)

IO.puts("\n✔ Seed data loaded successfully!")
