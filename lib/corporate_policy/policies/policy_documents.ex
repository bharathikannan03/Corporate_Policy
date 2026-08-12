defmodule CorporatePolicy.Policies.PolicyDocuments do
  @moduledoc """
  Encapsulates logic for Wizard Step 6: Policy Documents.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyDocument

  @doc """
  Lists documents for a policy, optionally filtered by doc_type ("policy" or "service").
  """
  def list_documents_for_policy(nil, _doc_type), do: []

  def list_documents_for_policy(policy_id, doc_type) do
    base_query =
      from d in MasterPolicyDocument,
        where: d.policy_id == ^policy_id and is_nil(d.deleted_at),
        order_by: [asc: d.document_name_id, asc: d.id]

    query =
      case doc_type do
        "policy" ->
          from d in base_query,
            where: d.document_type_id == 1 or d.document_type == "Policy Document"

        "service" ->
          from d in base_query,
            where: d.document_type_id == 2 or d.document_type == "Service Document"

        _ ->
          base_query
      end

    Repo.all(query)
  end

  @doc """
  Gets a single master policy document by ID.
  """
  def get_master_policy_document(id), do: Repo.get(MasterPolicyDocument, id)

  @doc """
  Creates a new policy document.
  """
  def create_policy_document(attrs, user_id \\ nil) do
    %MasterPolicyDocument{}
    |> MasterPolicyDocument.changeset(
      attrs
      |> Map.put("created_by", user_id)
      |> Map.put("updated_by", user_id)
    )
    |> Repo.insert()
  end

  @doc """
  Soft-deletes a policy document by ID.
  """
  def delete_policy_document(id, user_id \\ nil) do
    case Repo.get(MasterPolicyDocument, id) do
      nil ->
        {:error, :not_found}

      doc ->
        doc
        |> MasterPolicyDocument.changeset(%{
          deleted_at: NaiveDateTime.utc_now(),
          updated_by: user_id
        })
        |> Repo.update()
    end
  end
end
