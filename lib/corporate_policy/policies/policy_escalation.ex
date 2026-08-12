defmodule CorporatePolicy.Policies.PolicyEscalation do
  @moduledoc """
  Encapsulates logic for Wizard Step 5: Escalation Matrix assignment.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.MasterPolicyEscalationMatrix
  alias CorporatePolicy.EscalationMatrices.EscalationMatrix, as: MasterEscalationMatrix

  @doc """
  Returns all active escalation matrix records for a policy, joined with master_escalation_matrices details.
  Returns [] if policy_id is nil or if no records exist for the policy.
  """
  def list_escalation_matrices_for_policy(nil), do: []

  def list_escalation_matrices_for_policy(policy_id) do
    from(p in MasterPolicyEscalationMatrix,
      left_join: m in MasterEscalationMatrix,
      on: p.user_id == m.id,
      where: p.policy_id == ^policy_id and is_nil(p.deleted_at),
      order_by: [asc: p.escalation_level_id, asc: p.id],
      select: %{
        id: p.id,
        policy_id: p.policy_id,
        escalation_level_id: p.escalation_level_id,
        level: p.level,
        user_id: p.user_id,
        fullname: coalesce(m.fullname, p.user_fullname),
        user_fullname: coalesce(m.fullname, p.user_fullname),
        phone_number: m.phone_number,
        mobile_number: m.mobile_number,
        email_id: m.email_id,
        alt_email_id: m.alt_email_id,
        company_fulladdress: m.company_fulladdress,
        type: m.type,
        user_type: m.type,
        status: p.status
      }
    )
    |> Repo.all()
  end

  @doc """
  Saves the list of escalation matrices for a policy by soft-deleting existing ones
  and inserting new ones.
  """
  def save_policy_escalation_matrices(policy_id, matrices_list, user_id \\ nil) do
    Repo.transaction(fn ->
      # Soft-delete all existing non-deleted escalation matrices for this policy
      from(p in MasterPolicyEscalationMatrix,
        where: p.policy_id == ^policy_id and is_nil(p.deleted_at)
      )
      |> Repo.update_all(set: [deleted_at: NaiveDateTime.utc_now(), updated_by: user_id])

      # Insert new entries
      Enum.each(matrices_list, fn matrix ->
        params = %{
          policy_id: policy_id,
          escalation_level_id:
            Map.get(matrix, :escalation_level_id) || Map.get(matrix, "escalation_level_id"),
          level: Map.get(matrix, :level) || Map.get(matrix, "level"),
          user_id: Map.get(matrix, :user_id) || Map.get(matrix, "user_id"),
          user_fullname:
            Map.get(matrix, :user_fullname) || Map.get(matrix, "user_fullname") ||
              Map.get(matrix, :fullname) || Map.get(matrix, "fullname"),
          status: Map.get(matrix, :status) || Map.get(matrix, "status") || 1,
          created_by: user_id,
          updated_by: user_id
        }

        %MasterPolicyEscalationMatrix{}
        |> MasterPolicyEscalationMatrix.changeset(params)
        |> Repo.insert!()
      end)
    end)
  end

  @doc """
  Creates a single escalation matrix row for a policy immediately.
  Used by the wizard Step 5 "Assign" button so data is persisted right away.
  """
  def create_policy_escalation_matrix(policy_id, attrs, user_id \\ nil) do
    params = %{
      policy_id: policy_id,
      escalation_level_id:
        Map.get(attrs, :escalation_level_id) || Map.get(attrs, "escalation_level_id"),
      level: Map.get(attrs, :level) || Map.get(attrs, "level"),
      user_id: Map.get(attrs, :user_id) || Map.get(attrs, "user_id"),
      user_fullname: Map.get(attrs, :user_fullname) || Map.get(attrs, "user_fullname"),
      status: 1,
      created_by: user_id,
      updated_by: user_id
    }

    %MasterPolicyEscalationMatrix{}
    |> MasterPolicyEscalationMatrix.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Soft-deletes a single escalation matrix row by its DB id.
  Used by the wizard Step 5 "Remove" button.
  """
  def delete_policy_escalation_matrix(id, user_id \\ nil) do
    case Repo.get(MasterPolicyEscalationMatrix, id) do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> MasterPolicyEscalationMatrix.changeset(%{
          deleted_at: NaiveDateTime.utc_now(),
          updated_by: user_id
        })
        |> Repo.update()
    end
  end
end
