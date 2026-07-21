# priv/repo/seeds/md_escalation_matrices.exs

alias CorporatePolicy.Repo
alias CorporatePolicy.EscalationMatrices.EscalationMatrix
alias CorporatePolicy.Policies.MasterPolicyEscalationMatrix
alias CorporatePolicy.Policies.Policy

now = NaiveDateTime.local_now()
utc_now = DateTime.utc_now()

md_matrices = [
  %{id: 1, level: "Level 1", status: 1, inserted_at: now, updated_at: now},
  %{id: 2, level: "Level 2", status: 1, inserted_at: now, updated_at: now},
  %{id: 3, level: "Level 3", status: 1, inserted_at: now, updated_at: now},
  %{id: 4, level: "Level 4", status: 1, inserted_at: now, updated_at: now},
  %{id: 5, level: "Level 5", status: 1, inserted_at: now, updated_at: now}
]

Repo.insert_all("md_escalation_matrices", md_matrices, on_conflict: :nothing, conflict_target: [:id])

# ─── Master Escalation Contacts ───────────────────────────────────────────────
contacts = [
  %{
    id: 1,
    fullname: "Ramesh",
    mobile_number: "9600516455",
    phone_number: "044-22334455",
    email_id: "ramesh@vibeins.com",
    alt_email_id: "ramesh.support@vibeins.com",
    send_mail_alt_email: false,
    company_fulladdress: "NO.33/54, Mount Poonamallee Road, Near Kathipara Flyover, St. Thomas Mount, Chennai - 600016",
    type: "Relationship Manager",
    type_id: 1,
    status: 1,
    created_at: utc_now,
    updated_at: utc_now
  },
  %{
    id: 2,
    fullname: "Suresh Kumar",
    mobile_number: "9840123456",
    phone_number: "044-22334456",
    email_id: "suresh@vibeins.com",
    alt_email_id: "suresh.esc@vibeins.com",
    send_mail_alt_email: false,
    company_fulladdress: "NO.33/54, Mount Poonamallee Road, Near Kathipara Flyover, St. Thomas Mount, Chennai - 600016",
    type: "Senior Executive",
    type_id: 2,
    status: 1,
    created_at: utc_now,
    updated_at: utc_now
  },
  %{
    id: 3,
    fullname: "Priya Sharma",
    mobile_number: "9940987654",
    phone_number: "044-44556677",
    email_id: "priya.sharma@vibeins.com",
    alt_email_id: "priya.ops@vibeins.com",
    send_mail_alt_email: false,
    company_fulladdress: "4th Floor, Vibe Towers, Anna Salai, Chennai - 600002",
    type: "Operations Head",
    type_id: 3,
    status: 1,
    created_at: utc_now,
    updated_at: utc_now
  },
  %{
    id: 4,
    fullname: "Vikram Malhotra",
    mobile_number: "9820112233",
    phone_number: "022-66778899",
    email_id: "vikram.m@vibeins.com",
    alt_email_id: "vikram.vp@vibeins.com",
    send_mail_alt_email: false,
    company_fulladdress: "Corporate Office, BKC Road, Bandra East, Mumbai - 400051",
    type: "VP - Corporate Services",
    type_id: 4,
    status: 1,
    created_at: utc_now,
    updated_at: utc_now
  },
  %{
    id: 5,
    fullname: "Ananya Roy",
    mobile_number: "9740556677",
    phone_number: "080-33445566",
    email_id: "ananya.roy@vibeins.com",
    alt_email_id: "ananya.cco@vibeins.com",
    send_mail_alt_email: false,
    company_fulladdress: "Global Executive Hub, MG Road, Bengaluru - 560001",
    type: "Chief Customer Officer",
    type_id: 5,
    status: 1,
    created_at: utc_now,
    updated_at: utc_now
  }
]

Enum.each(contacts, fn contact_attrs ->
  case Repo.get(EscalationMatrix, contact_attrs.id) do
    nil ->
      %EscalationMatrix{}
      |> EscalationMatrix.changeset(contact_attrs)
      |> Repo.insert!()

    _ ->
      :ok
  end
end)

# ─── Master Policy Escalation Matrices (Link to all active policies) ──────────
policies = Repo.all(Policy)

Enum.each(policies, fn policy ->
  # Link 5 levels of escalation to each policy
  levels = [
    {1, "Level 1", 1, "Ramesh"},
    {2, "Level 2", 2, "Suresh Kumar"},
    {3, "Level 3", 3, "Priya Sharma"},
    {4, "Level 4", 4, "Vikram Malhotra"},
    {5, "Level 5", 5, "Ananya Roy"}
  ]

  Enum.each(levels, fn {level_id, level_name, user_id, user_fullname} ->
    existing = Repo.get_by(MasterPolicyEscalationMatrix, policy_id: policy.id, escalation_level_id: level_id)

    if is_nil(existing) do
      %MasterPolicyEscalationMatrix{}
      |> MasterPolicyEscalationMatrix.changeset(%{
        policy_id: policy.id,
        escalation_level_id: level_id,
        level: level_name,
        user_id: user_id,
        user_fullname: user_fullname,
        status: 1
      })
      |> Repo.insert!()
    end
  end)
end)
