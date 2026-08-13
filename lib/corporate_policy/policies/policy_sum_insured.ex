defmodule CorporatePolicy.Policies.PolicySumInsured do
  @moduledoc """
  Encapsulates logic for Wizard Step 3: Sum Insured.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Policies.MasterSumInsured
  alias CorporatePolicy.Policies.PolicyFeatures

  @doc "Lists all active sum insured values for a policy."
  def list_sum_insureds_for_policy(policy_id) when policy_id in [nil, "", "nil"], do: []

  def list_sum_insureds_for_policy(policy_id) do
    Repo.all(
      from s in MasterSumInsured,
        where: s.policy_id == ^policy_id and s.status == 1 and is_nil(s.deleted_at),
        order_by: [asc: s.sum_insured]
    )
  end

  @doc """
  Saves the list of sum insured values for a policy by soft-deleting existing ones
  and inserting new ones.
  """
  def save_policy_sum_insureds(policy_id, sum_insured_list, user_id \\ nil) do
    Repo.transaction(fn ->
      # Soft-delete all existing non-deleted sum insureds for this policy
      from(s in MasterSumInsured,
        where: s.policy_id == ^policy_id and is_nil(s.deleted_at)
      )
      |> Repo.update_all(set: [deleted_at: NaiveDateTime.utc_now(), updated_by: user_id])

      policy = Repo.get(Policy, policy_id)
      template_id = PolicyFeatures.get_template_id_for_policy(policy)
      mapped_features = PolicyFeatures.list_mapped_features_by_policy(policy_id)

      Enum.each(sum_insured_list, fn si ->
        selected_ident =
          Map.get(si, :policy_feature_identifier) || Map.get(si, "policy_feature_identifier")

        feature_identifier_id =
          case Enum.find(mapped_features, &(&1.feature_identifier == selected_ident)) do
            nil -> 1
            mf -> mf.id
          end

        si_amount_str = to_string(Map.get(si, :sum_insured) || Map.get(si, "sum_insured"))
        si_amount = parse_sum_insured_amount(si_amount_str)

        params = %{
          policy_id: policy_id,
          sum_insured: si_amount,
          policy_feature_identifier: selected_ident,
          template_id: template_id,
          feature_identifier_id: feature_identifier_id,
          status: 1,
          created_by: user_id,
          updated_by: user_id
        }

        %MasterSumInsured{}
        |> MasterSumInsured.changeset(params)
        |> Repo.insert!()
      end)
    end)
  end

  @doc """
  Creates a single sum insured row for a policy immediately.
  Used by the wizard Step 3 "Add" button so data is persisted right away.
  """
  def create_sum_insured(policy_id, attrs, user_id \\ nil) do
    policy = Repo.get(Policy, policy_id)
    template_id = PolicyFeatures.get_template_id_for_policy(policy)
    mapped_features = PolicyFeatures.list_mapped_features_by_policy(policy_id)

    selected_ident =
      Map.get(attrs, :policy_feature_identifier) ||
        Map.get(attrs, "policy_feature_identifier")

    feature_identifier_id =
      case Enum.find(mapped_features, &(&1.feature_identifier == selected_ident)) do
        nil -> 1
        mf -> mf.id
      end

    si_amount_str = to_string(Map.get(attrs, :sum_insured) || Map.get(attrs, "sum_insured"))
    si_amount = parse_sum_insured_amount(si_amount_str)

    params = %{
      policy_id: policy_id,
      sum_insured: si_amount,
      policy_feature_identifier: selected_ident,
      template_id: template_id,
      feature_identifier_id: feature_identifier_id,
      status: 1,
      created_by: user_id,
      updated_by: user_id
    }

    %MasterSumInsured{}
    |> MasterSumInsured.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Soft-deletes a single sum insured row by its DB id.
  Used by the wizard Step 3 "Remove" button.
  """
  def delete_sum_insured(id, user_id \\ nil) do
    case Repo.get(MasterSumInsured, id) do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> MasterSumInsured.changeset(%{
          deleted_at: NaiveDateTime.utc_now(),
          updated_by: user_id
        })
        |> Repo.update()
    end
  end

  defp parse_sum_insured_amount(str) do
    str = str |> to_string() |> String.replace(~r/[\s,]/, "") |> String.downcase()

    cond do
      str =~ ~r/^(\d+)l$/ ->
        [_, num_str] = Regex.run(~r/^(\d+)l$/, str)
        String.to_integer(num_str) * 100_000

      str =~ ~r/^(\d+)lakh$/ ->
        [_, num_str] = Regex.run(~r/^(\d+)lakh$/, str)
        String.to_integer(num_str) * 100_000

      true ->
        case Integer.parse(str) do
          {val, _} -> val
          _ -> 0
        end
    end
  end
end
