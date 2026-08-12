defmodule CorporatePolicy.Policies.PolicyFeatures do
  @moduledoc """
  Encapsulates logic for Wizard Step 2 & 4: Policy Feature Templates and Mapping.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField
  alias CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy

  @doc "Fetches all fields for a given template_id, ordered by template_field_id."
  def list_policy_feature_template_fields(template_id) do
    Repo.all(
      from f in MasterPolicyFeatureTemplateField,
        where: f.ref_template_id == ^template_id and f.status >= 0,
        order_by: [asc: f.template_field_id]
    )
  end

  @doc """
  Returns distinct policy_identifier values from mapping_policy_feature_templates_corporates_policies
  or master_policy_feature_templates for the Sum Insured step dropdown.
  """
  def list_policy_identifiers_for_policy(nil), do: [%{template_id: 1, policy_identifier: "GMC"}]

  def list_policy_identifiers_for_policy(policy) do
    policy_id = policy && policy.id

    mapped =
      if policy_id do
        list_mapped_features_by_policy(policy_id)
      else
        []
      end

    if mapped != [] do
      Enum.map(mapped, fn m ->
        %{
          template_id: get_template_id_for_policy(policy),
          policy_identifier: m.feature_identifier
        }
      end)
    else
      template_id = get_template_id_for_policy(policy)

      Repo.all(
        from t in "master_policy_feature_templates",
          where: t.template_id == ^template_id and t.status == 1,
          select: %{template_id: t.template_id, policy_identifier: t.policy_identifier},
          order_by: [asc: t.template_id]
      )
    end
  end

  @doc """
  Returns the feature template_id for the given policy.
  Looks up the policy type name and maps to template_id.
  """
  def get_template_id_for_policy(%{ref_md_policy_types_id: nil}), do: 1

  def get_template_id_for_policy(%{ref_md_policy_types_id: policy_type_id}) do
    policy_type = Repo.get(PolicyType, policy_type_id)
    template_id_from_policy_type(policy_type)
  end

  def get_template_id_for_policy(_), do: 1

  defp template_id_from_policy_type(nil), do: 1
  defp template_id_from_policy_type(%{policy_type_value: "GMC"}), do: 1
  defp template_id_from_policy_type(%{policy_type_value: "GPA"}), do: 2
  defp template_id_from_policy_type(%{policy_type_value: "Parent Policy"}), do: 3
  defp template_id_from_policy_type(%{policy_type_value: "Top up Policy"}), do: 4
  defp template_id_from_policy_type(%{policy_type_value: "GTL"}), do: 5
  defp template_id_from_policy_type(%{policy_type_value: "Marine"}), do: 6
  defp template_id_from_policy_type(%{policy_type_value: "Fire"}), do: 7
  defp template_id_from_policy_type(%{policy_type_value: "Office Package"}), do: 8
  defp template_id_from_policy_type(%{policy_type_value: "Motor Insurance"}), do: 9
  defp template_id_from_policy_type(%{policy_type_value: "Travel Insurance"}), do: 10
  defp template_id_from_policy_type(%{policy_type_value: "Property Insurance"}), do: 11
  defp template_id_from_policy_type(%{policy_type_value: "Commercial Insurance"}), do: 12
  defp template_id_from_policy_type(%{policy_type_value: "Asset Insurance"}), do: 13
  defp template_id_from_policy_type(%{policy_type_value: "Pet Insurance"}), do: 14
  defp template_id_from_policy_type(%{policy_type_value: "Bite-Sized Insurance"}), do: 15
  defp template_id_from_policy_type(%{policy_type_value: "Workmen Compensation"}), do: 16
  defp template_id_from_policy_type(_), do: 1

  @doc "Fetches mapped features for a policy, extracting the distinct Feature Identifiers."
  def list_mapped_features_by_policy(policy_id) do
    Repo.all(
      from m in MappingPolicyFeatureTemplatesCorporatesPolicy,
        where:
          m.ref_policy_id == ^policy_id and
            (m.ref_policy_feature_template_field_name in [
               "Feature Identifier",
               "Policy Identifier"
             ] or
               m.ref_policy_feature_template_field_id == 1) and
            (is_nil(m.status) or m.status >= 0),
        select: %{
          id: m.policy_feature_template_field_value_id,
          feature_identifier: m.policy_feature_template_field_value
        },
        distinct: true
    )
  end

  @doc "Fetches all mapped feature rows for a specific feature entry."
  def get_mapped_feature_details(policy_id, feature_id) do
    Repo.all(
      from m in MappingPolicyFeatureTemplatesCorporatesPolicy,
        where:
          m.ref_policy_id == ^policy_id and
            (m.ref_policyidentifier_id == ^feature_id or
               m.policy_feature_template_field_value_id == ^feature_id) and
            (is_nil(m.status) or m.status >= 0)
    )
  end

  @doc "Creates a new mapping row for a policy feature."
  def create_mapped_feature(attrs) do
    %MappingPolicyFeatureTemplatesCorporatesPolicy{}
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates an existing mapped feature row."
  def update_mapped_feature(%MappingPolicyFeatureTemplatesCorporatesPolicy{} = mapping, attrs) do
    mapping
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes all mapped feature rows for a given feature ID."
  def delete_mapped_feature(policy_id, feature_id) do
    from(m in MappingPolicyFeatureTemplatesCorporatesPolicy,
      where:
        m.ref_policy_id == ^policy_id and
          (m.ref_policyidentifier_id == ^feature_id or
             m.policy_feature_template_field_value_id == ^feature_id)
    )
    |> Repo.delete_all()
  end

  @doc "Lists features associated with a specific feature identifier ID."
  def list_features_by_identifier(policy_id, _feature_identifier_id)
      when policy_id in [nil, "", "nil"], do: []

  def list_features_by_identifier(_policy_id, nil), do: []

  def list_features_by_identifier(policy_id, feature_identifier_id) do
    Repo.all(
      from m in MappingPolicyFeatureTemplatesCorporatesPolicy,
        where:
          m.ref_policy_id == ^policy_id and
            (m.ref_policyidentifier_id == ^feature_identifier_id or
               m.policy_feature_template_field_value_id == ^feature_identifier_id) and
            is_nil(m.deleted_at) and m.status >= 0,
        order_by: [asc: m.ref_policy_feature_template_field_id]
    )
  end
end
