# priv/repo/seeds/master_policy_documents_seeds.exs

alias CorporatePolicy.Repo
alias CorporatePolicy.Policies.Policy
alias CorporatePolicy.Policies.MasterPolicyDocument

now = NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second)

policies = Repo.all(Policy)

sample_docs = [
  %{
    document_type_id: 1,
    document_type: "Policy Document",
    document_name_id: 1,
    document_name: "PDF Copy",
    note: "Master Policy Copy",
    file_path: "/uploads/sample_policy.pdf",
    original_file_name: "Policy_Schedule.pdf",
    status: 1,
    inserted_at: now,
    updated_at: now
  },
  %{
    document_type_id: 2,
    document_type: "Service Document",
    document_name_id: 2,
    document_name: "Claim form",
    note: "Standard Claim Form",
    file_path: "/uploads/sample_claim_form.pdf",
    original_file_name: "Claim_Form.pdf",
    status: 1,
    inserted_at: now,
    updated_at: now
  },
  %{
    document_type_id: 2,
    document_type: "Service Document",
    document_name_id: 3,
    document_name: "Non Payable list",
    note: "Non-payable items list",
    file_path: "/uploads/sample_non_payable_list.pdf",
    original_file_name: "Non_Payable_List.pdf",
    status: 1,
    inserted_at: now,
    updated_at: now
  },
  %{
    document_type_id: 2,
    document_type: "Service Document",
    document_name_id: 4,
    document_name: "Day care list",
    note: "Day care procedures list",
    file_path: "/uploads/sample_day_care_list.pdf",
    original_file_name: "Day_Care_List.pdf",
    status: 1,
    inserted_at: now,
    updated_at: now
  },
  %{
    document_type_id: 2,
    document_type: "Service Document",
    document_name_id: 5,
    document_name: "Check list",
    note: "Claim document checklist",
    file_path: "/uploads/sample_check_list.pdf",
    original_file_name: "Check_List.pdf",
    status: 1,
    inserted_at: now,
    updated_at: now
  }
]

Enum.each(policies, fn policy ->
  Enum.each(sample_docs, fn doc ->
    doc_attrs = Map.put(doc, :policy_id, policy.id)

    case Repo.get_by(MasterPolicyDocument, policy_id: policy.id, document_name: doc.document_name) do
      nil ->
        Repo.insert_all(MasterPolicyDocument, [doc_attrs])
        IO.puts("✓ Added #{doc.document_name} for Policy ID #{policy.id}")

      _ ->
        :ok
    end
  end)
end)
