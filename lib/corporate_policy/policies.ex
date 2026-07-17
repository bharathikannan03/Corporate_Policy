defmodule CorporatePolicy.Policies do
  @moduledoc """
  The Policies context.
  """

  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Policies.FinancialYear
  alias CorporatePolicy.Policies.LineOfBusiness
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.FamilyDefinition
  alias CorporatePolicy.Policies.Tpa
  alias CorporatePolicy.Policies.Corporate
  alias CorporatePolicy.Policies.ClaimVisibility
  alias CorporatePolicy.Policies.Insurer
  alias CorporatePolicy.Policies.MasterPolicyFeatureTemplateField
  alias CorporatePolicy.Policies.MappingPolicyFeatureTemplatesCorporatesPolicy

  # === Policy Listing ===

  def list_policies do
    Repo.all(Policy)
    |> Repo.preload([
      :corporate,
      :financial_year_ref,
      :line_of_business_ref,
      :policy_type_ref,
      :insurer_ref,
      :tpa_ref,
      :family_definition_ref,
      :intimate_claim_visibility_ref
    ])
  end

  def list_policies_by_fy(fy_id) when fy_id == 0 or is_nil(fy_id) do
    list_policies()
  end

  def list_policies_by_fy(fy_id) do
    Repo.all(
      from p in Policy,
        where: p.ref_fy_year_id == ^fy_id,
        preload: [
          :corporate,
          :financial_year_ref,
          :line_of_business_ref,
          :policy_type_ref,
          :insurer_ref,
          :tpa_ref,
          :family_definition_ref,
          :intimate_claim_visibility_ref
        ],
        order_by: [desc: p.id]
    )
  end

  def list_active_policies do
    Repo.all(
      from p in Policy,
        where: p.status == 1 and not is_nil(p.policy_number),
        preload: [
          :corporate,
          :financial_year_ref,
          :line_of_business_ref,
          :policy_type_ref,
          :insurer_ref,
          :tpa_ref,
          :family_definition_ref,
          :intimate_claim_visibility_ref
        ],
        order_by: [desc: p.id]
    )
  end

  def list_inactive_policies do
    Repo.all(
      from p in Policy,
        where: p.status == 2 or is_nil(p.policy_number),
        preload: [
          :corporate,
          :financial_year_ref,
          :line_of_business_ref,
          :policy_type_ref,
          :insurer_ref,
          :tpa_ref,
          :family_definition_ref,
          :intimate_claim_visibility_ref
        ],
        order_by: [desc: p.id]
    )
  end

  def list_expired_policies do
    Repo.all(
      from p in Policy,
        where: p.status == 3 and not is_nil(p.policy_number),
        preload: [
          :corporate,
          :financial_year_ref,
          :line_of_business_ref,
          :policy_type_ref,
          :insurer_ref,
          :tpa_ref,
          :family_definition_ref,
          :intimate_claim_visibility_ref
        ],
        order_by: [desc: p.id]
    )
  end

  # === Policy CRUD ===

  def get_policy(id), do: Repo.get(Policy, id)

  def get_policy!(id), do: Repo.get!(Policy, id)

  def get_policy_with_preloads(id) do
    Repo.get(Policy, id)
    |> Repo.preload([
      :corporate,
      :financial_year_ref,
      :line_of_business_ref,
      :policy_type_ref,
      :insurer_ref,
      :tpa_ref,
      :family_definition_ref,
      :intimate_claim_visibility_ref,
      :creator,
      :updater
    ])
  end

  def create_policy(attrs, user_id \\ nil) do
    attrs = populate_reference_names(attrs)
    attrs_with_fy = calculate_financial_year(attrs)

    attrs_with_status = determine_initial_status(attrs_with_fy)

    attrs_with_user =
      attrs_with_status
      |> Map.put("created_by", user_id)
      |> Map.put("updated_by", user_id)

    case %Policy{}
         |> Policy.create_changeset(attrs_with_user)
         |> Repo.insert() do
      {:ok, policy} ->
        finalize_policy_status(policy.id)
        {:ok, policy}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_or_update_policy(attrs, user_id \\ nil) do
    attrs = populate_reference_names(attrs)
    id = attrs["policy_id"] || attrs["id"] || attrs[:id]

    case id do
      nil -> create_policy(attrs, user_id)
      id -> update_policy_by_id(id, Map.put(attrs, "updated_by", user_id))
    end
  end

  defp populate_reference_names(attrs) do
    attrs =
      if attrs["ref_corporate_id"] && attrs["ref_corporate_id"] != "" do
        corporate = Repo.get(Corporate, attrs["ref_corporate_id"])
        if corporate, do: Map.put(attrs, "corporate_name", corporate.corporate_name), else: attrs
      else
        attrs
      end

    attrs =
      if attrs["ref_md_line_of_businesses_id"] && attrs["ref_md_line_of_businesses_id"] != "" do
        lob = Repo.get(LineOfBusiness, attrs["ref_md_line_of_businesses_id"])
        if lob, do: Map.put(attrs, "line_of_business", lob.line_of_business_value), else: attrs
      else
        attrs
      end

    attrs =
      if attrs["ref_md_policy_types_id"] && attrs["ref_md_policy_types_id"] != "" do
        pt = Repo.get(PolicyType, attrs["ref_md_policy_types_id"])
        if pt, do: Map.put(attrs, "policy_type", pt.policy_type_value), else: attrs
      else
        attrs
      end

    attrs =
      if attrs["ref_select_insurer_id"] && attrs["ref_select_insurer_id"] != "" do
        insurer = Repo.get(Insurer, attrs["ref_select_insurer_id"])
        if insurer, do: Map.put(attrs, "select_insurer", insurer.name), else: attrs
      else
        attrs
      end

    attrs =
      if attrs["ref_md_sum_insured_types_id"] && attrs["ref_md_sum_insured_types_id"] != "" do
        sit =
          Repo.get(CorporatePolicy.Policies.SumInsuredType, attrs["ref_md_sum_insured_types_id"])

        if sit, do: Map.put(attrs, "sum_insured_type", sit.name), else: attrs
      else
        attrs
      end

    attrs
  end

  defp update_policy_by_id(id, attrs) do
    case get_policy(id) do
      nil ->
        {:error, :not_found}

      policy ->
        policy
        |> Policy.update_changeset(attrs)
        |> Repo.update()
    end
  end

  def update_policy(policy, attrs) do
    policy
    |> Policy.update_changeset(attrs)
    |> Repo.update()
  end

  def update_policy_status(policy, status, user_id) when is_integer(policy) do
    case get_policy(policy) do
      nil -> {:error, :not_found}
      policy -> update_policy_status(policy, status, user_id)
    end
  end

  def update_policy_status(%Policy{} = policy, status, user_id) do
    policy
    |> Policy.status_changeset(%{status: status, updated_by: user_id})
    |> Repo.update()
  end

  def delete_policy(policy) do
    Repo.delete(policy)
  end

  # === Financial Year Calculation (April-March cycle) ===

  defp calculate_financial_year(attrs) do
    case attrs["policy_start_date"] do
      nil ->
        attrs

      start_date_str ->
        start_date = Date.from_iso8601!(start_date_str)
        fy_start_year = if start_date.month >= 4, do: start_date.year, else: start_date.year - 1
        fy = get_or_create_financial_year(fy_start_year)
        Map.put(attrs, "ref_fy_year_id", fy.id)
    end
  end

  defp get_or_create_financial_year(start_year) do
    year_name = to_string(start_year)

    case Repo.get_by(FinancialYear, year_name: year_name) do
      nil ->
        fy_start = Date.new!(start_year, 4, 1)
        fy_end = Date.new!(start_year + 1, 3, 31)
        is_default = start_year == Date.utc_today().year

        %FinancialYear{}
        |> FinancialYear.changeset(%{
          year_name: year_name,
          start_date: fy_start,
          end_date: fy_end,
          status: if(is_default, do: 1, else: 0)
        })
        |> Repo.insert!()

      fy ->
        fy
    end
  end

  defp determine_initial_status(attrs) do
    case attrs["policy_end_date"] do
      nil ->
        Map.put(attrs, "status", 2)

      end_date_str ->
        end_date = Date.from_iso8601!(end_date_str)
        today = Date.utc_today()

        if Date.compare(end_date, today) == :lt do
          Map.put(attrs, "status", 3)
        else
          Map.put(attrs, "status", 2)
        end
    end
  end

  def check_policy_completion(policy_id) do
    policy = get_policy_with_preloads(policy_id)

    required_fields = [
      :corporate_name,
      :ref_md_line_of_businesses_id,
      :ref_md_policy_types_id,
      :ref_select_insurer_id,
      :policy_number,
      :policy_start_date,
      :policy_end_date
    ]

    all_present? =
      Enum.all?(required_fields, fn field ->
        value = Map.get(policy, field)
        !is_nil(value) && value != ""
      end)

    if all_present?, do: 1, else: 0
  end

  def finalize_policy_status(policy_id) do
    policy = get_policy_with_preloads(policy_id)

    is_expired =
      case policy.policy_end_date do
        nil ->
          false

        %Date{} = end_date ->
          Date.compare(end_date, Date.utc_today()) == :lt

        date_str when is_binary(date_str) ->
          case Date.from_iso8601(date_str) do
            {:ok, end_date} -> Date.compare(end_date, Date.utc_today()) == :lt
            _ -> false
          end
      end

    is_completed = check_policy_completion(policy_id)

    new_status =
      cond do
        is_expired -> 3
        is_completed == 1 -> 1
        true -> 0
      end

    if new_status != policy.status do
      policy
      |> Ecto.Changeset.change(status: new_status)
      |> Repo.update()
    else
      {:ok, policy}
    end
  end

  # === Reference Data ===

  def list_line_of_businesses do
    Repo.all(
      from lob in LineOfBusiness,
        where: lob.status == 1,
        order_by: [asc: lob.display_id]
    )
  end

  def list_policy_types do
    Repo.all(
      from pt in PolicyType,
        where: pt.status == 1,
        order_by: [asc: pt.display_id]
    )
  end

  def list_insurers do
    Repo.all(
      from i in Insurer,
        where: i.status == 1,
        order_by: [asc: i.name]
    )
  end

  def list_tpas do
    Repo.all(
      from tpa in Tpa,
        where: tpa.status == 1,
        order_by: [asc: tpa.name]
    )
  end

  def list_corporates do
    Repo.all(
      from c in Corporate,
        where: c.corporate_status == 1,
        order_by: [asc: c.corporate_name]
    )
  end

  def list_family_definitions do
    Repo.all(
      from fd in FamilyDefinition,
        where: fd.status == 1,
        order_by: [asc: fd.display_id]
    )
  end

  def list_policy_types_by_lob(lob_id) do
    Repo.all(
      from pt in PolicyType,
        where: pt.ref_md_line_of_businesses_id == ^lob_id and pt.status == 1,
        order_by: [asc: pt.display_id]
    )
  end

  def list_claim_visibilities do
    Repo.all(
      from cv in ClaimVisibility,
        where: cv.status == 1,
        order_by: [asc: cv.display_id]
    )
  end

  def list_financial_years do
    Repo.all(
      from fy in FinancialYear,
        where: fy.status == 1,
        order_by: [desc: fy.year_name]
    )
  end

  def list_sum_insured_types do
    Repo.all(
      from sit in CorporatePolicy.Policies.SumInsuredType,
        where: sit.status == 1,
        order_by: [asc: sit.display_id]
    )
  end

  # === Authorization Helpers ===

  def get_assigned_corporate_ids(_user) do
    # In a real implementation, this would query a user-corporate mapping table
    # For now, return empty list for brokers
    []
  end

  def get_assigned_policy_ids(_user) do
    # Query policies assigned to this broker
    []
  end

  def get_tpas_for_policies(policy_ids) do
    Repo.all(
      from tpa in Tpa,
        join: p in Policy,
        on: p.ref_tpa_id == tpa.id,
        where: p.id in ^policy_ids and not is_nil(p.ref_tpa_id),
        distinct: true,
        select: %{id: tpa.id, name: tpa.name}
    )
  end

  def get_all_tpas do
    list_tpas()
  end

  # === Stats ===

  def get_policy_stats(fy_id \\ 0) do
    base = from(p in Policy)

    base = if fy_id != 0, do: where(base, [p], p.ref_fy_year_id == ^fy_id), else: base

    total = Repo.aggregate(base, :count, :id)
    active = Repo.aggregate(from(p in subquery(base), where: p.status == 1), :count, :id)
    draft = Repo.aggregate(from(p in subquery(base), where: p.status == 0), :count, :id)
    expired = Repo.aggregate(from(p in subquery(base), where: p.status == 3), :count, :id)

    %{total: total || 0, active: active || 0, draft: draft || 0, expired: expired || 0}
  end

  # === Metadata APIs ===

  def get_policy_info_meta_data do
    lobs =
      Repo.all(
        from lob in LineOfBusiness,
          where: lob.status == 1,
          order_by: [asc: lob.display_id]
      )

    policy_types =
      Repo.all(
        from pt in PolicyType,
          where: pt.status == 1,
          order_by: [asc: pt.display_id]
      )

    # Group policy types by line_of_business_id
    policy_types_by_lob = Enum.group_by(policy_types, & &1.ref_md_line_of_businesses_id)

    lobs_with_types =
      Enum.map(lobs, fn lob ->
        %{lob | policy_types: policy_types_by_lob[lob.id] || []}
      end)

    general_metas = %{
      family_definitions: list_family_definitions(),
      intimate_claim_visibilities: list_claim_visibilities()
    }

    %{
      line_of_business_mapping: lobs_with_types,
      general_metas: general_metas
    }
  end

  def get_insurer_lists(lob_id) when is_integer(lob_id) do
    Repo.all(
      from i in Insurer,
        where: i.ref_md_line_of_businesses_id == ^lob_id and i.status == 1,
        order_by: [asc: i.name],
        select: %{id: i.id, name: i.name}
    )
  end

  def get_insurer_lists(_lob_id), do: []

  def get_corporate_name do
    Repo.all(
      from c in Corporate,
        where: c.status == 1,
        order_by: [asc: c.corporate_name],
        select: %{
          corporate_id: c.corporate_id,
          corporate_name: c.corporate_name,
          corporate_group_code: c.corporate_group_code
        }
    )
  end

  # === Policy Features (Step 2) ===

  @doc "Fetches all fields for a given template_id, ordered by id."
  def list_policy_feature_template_fields(template_id) do
    Repo.all(
      from f in MasterPolicyFeatureTemplateField,
        where: f.template_id == ^template_id and f.status >= 0,
        order_by: [asc: f.id]
    )
  end

  @doc """
  Returns distinct policy_identifier values from master_policy_feature_templates
  for the Sum Insured step dropdown. Filters by template_id matching the policy type.
  """
  def list_policy_identifiers_for_policy(nil), do: [%{template_id: 1, policy_identifier: "GMC"}]

  def list_policy_identifiers_for_policy(policy) do
    template_id = get_template_id_for_policy(policy)

    Repo.all(
      from t in "master_policy_feature_templates",
        where: t.template_id == ^template_id and t.status == 1,
        select: %{template_id: t.template_id, policy_identifier: t.policy_identifier},
        order_by: [asc: t.template_id]
    )
  end

  @doc """
  Returns the feature template_id for the given policy.
  Looks up the policy type name and maps to template_id:
  GMC/Parent Policy/Top up Policy -> template_id 1
  GPA -> template_id 2
  GTL -> template_id 3
  etc.
  Falls back to template_id 1 if no specific mapping found.
  """
  def get_template_id_for_policy(%{ref_md_policy_types_id: nil}), do: 1

  def get_template_id_for_policy(%{ref_md_policy_types_id: policy_type_id}) do
    policy_type = Repo.get(PolicyType, policy_type_id)
    template_id_from_policy_type(policy_type)
  end

  def get_template_id_for_policy(_), do: 1

  defp template_id_from_policy_type(nil), do: 1
  defp template_id_from_policy_type(%{policy_type_value: "GPA"}), do: 2
  defp template_id_from_policy_type(%{policy_type_value: "GTL"}), do: 3
  defp template_id_from_policy_type(%{policy_type_value: "Marine"}), do: 4
  defp template_id_from_policy_type(%{policy_type_value: "Fire"}), do: 5
  defp template_id_from_policy_type(%{policy_type_value: "Workmen Compensation"}), do: 6
  # GMC, Parent Policy, Top up Policy, and all others → template 1
  defp template_id_from_policy_type(_), do: 1

  @doc "Fetches mapped features for a policy, extracting the distinct Feature Identifiers."
  def list_mapped_features_by_policy(nil), do: []

  def list_mapped_features_by_policy(policy_id) do
    Repo.all(
      from m in MappingPolicyFeatureTemplatesCorporatesPolicy,
        where:
          m.ref_policy_id == ^policy_id and
            m.ref_policy_feature_template_field_name == "Feature Identifier",
        select: %{
          id: m.policy_feature_template_field_value_id,
          feature_identifier: m.policy_feature_template_field_value
        }
    )
  end

  @doc "Creates a new mapping row for a policy feature."
  def create_mapped_feature(attrs) do
    %MappingPolicyFeatureTemplatesCorporatesPolicy{}
    |> MappingPolicyFeatureTemplatesCorporatesPolicy.changeset(attrs)
    |> Repo.insert()
  end
end
