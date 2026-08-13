defmodule CorporatePolicy.Policies do
  @moduledoc """
  The Policies context.
  """

  import Ecto.Query, warn: false
  alias CorporatePolicy.StringUtils

  alias CorporatePolicy.Repo
  alias CorporatePolicy.Policies.Policy
  alias CorporatePolicy.Policies.FinancialYear
  alias CorporatePolicy.Policies.LineOfBusiness
  alias CorporatePolicy.Policies.PolicyType
  alias CorporatePolicy.Policies.FamilyDefinition
  alias CorporatePolicy.Policies.Tpa
  alias CorporatePolicy.Corporates.Corporate
  alias CorporatePolicy.Policies.ClaimVisibility
  alias CorporatePolicy.Policies.Insurer
  alias CorporatePolicy.Policies.TrnMappingLiveEmployee
  alias CorporatePolicy.Policies.MasterInceptionDataUpload
  alias CorporatePolicy.Policies.MasterEndorsementDataUpload
  alias CorporatePolicy.Policies.MasterTotalClaimReport

  # Submodules
  alias CorporatePolicy.Policies.PolicyFeatures
  alias CorporatePolicy.Policies.PolicySumInsured
  alias CorporatePolicy.Policies.PolicyEscalation
  alias CorporatePolicy.Policies.PolicyDocuments
  alias CorporatePolicy.Policies.PolicyDataUploads
  alias CorporatePolicy.Claims.MasterClaimSubmission
  alias CorporatePolicy.Policies.CashlessHospital
  alias CorporatePolicy.Policies.CashlessHospitalUpload
  alias CorporatePolicy.Policies.MasterEmployeeLog

  @page_size 15

  # === Policy Listing ===

  def page_size, do: @page_size

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

  def list_policies_paginated(opts \\ []) do
    page = opts |> Keyword.get(:page, 1) |> normalize_page()

    base_query =
      from p in Policy,
        order_by: [desc: p.id]

    total_entries = Repo.aggregate(base_query, :count, :id)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = min(page, total_pages)

    entries =
      base_query
      |> offset(^((page - 1) * @page_size))
      |> limit(^@page_size)
      |> preload([
        :corporate,
        :financial_year_ref,
        :line_of_business_ref,
        :policy_type_ref,
        :insurer_ref,
        :tpa_ref,
        :family_definition_ref,
        :intimate_claim_visibility_ref
      ])
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: @page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
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

  def count_policies_by_status(status) do
    Repo.aggregate(
      from(p in Policy, where: p.status == ^status),
      :count,
      :id
    )
  end

  def count_policies_by_statuses(statuses) when is_list(statuses) do
    Repo.aggregate(
      from(p in Policy, where: p.status in ^statuses),
      :count,
      :id
    )
  end

  def count_total_claim_reports do
    Repo.aggregate(
      from(r in MasterTotalClaimReport, where: is_nil(r.deleted_at)),
      :count,
      :id
    ) || 0
  end

  @doc """
  Lists all claim submissions (from the Claims Intimation form) for the Total Claim Reported admin view.
  """
  def list_total_claim_reports(params \\ %{}) do
    page = params |> Map.get("page", 1) |> normalize_page()
    search = StringUtils.normalize(Map.get(params, "search", ""))
    status = StringUtils.normalize(Map.get(params, "status", ""))
    sort_by = Map.get(params, "sort_by", "inserted_at")
    sort_dir = if Map.get(params, "sort_dir", "desc") == "asc", do: :asc, else: :desc

    base_query =
      from c in MasterClaimSubmission,
        where: is_nil(c.deleted_at),
        preload: [:policy]

    base_query =
      if search != "" do
        like = "%#{search}%"

        where(
          base_query,
          [c],
          ilike(c.employee_code, ^like) or
            ilike(c.employee_name, ^like) or
            ilike(c.patient_name, ^like) or
            ilike(c.claim_number, ^like) or
            ilike(c.hospital_name, ^like) or
            ilike(c.intimation_number, ^like)
        )
      else
        base_query
      end

    base_query =
      if status != "" do
        where(
          base_query,
          [c],
          fragment("lower(trim(?))", c.claim_status) == ^StringUtils.downcase(status)
        )
      else
        base_query
      end

    sort_field =
      case sort_by do
        "employee_code" -> :employee_code
        "employee_name" -> :employee_name
        "patient_name" -> :patient_name
        "claim_number" -> :claim_number
        "claim_status" -> :claim_status
        "estimated_amount" -> :estimated_amount
        "hospitalization_date" -> :hospitalization_date
        "discharge_date" -> :discharge_date
        _ -> :inserted_at
      end

    total_entries = Repo.aggregate(base_query, :count, :id)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = min(page, total_pages)

    entries =
      base_query
      |> order_by(^[{sort_dir, sort_field}])
      |> offset(^((page - 1) * @page_size))
      |> limit(^@page_size)
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: @page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      search: search,
      status: status,
      sort_by: sort_by,
      sort_dir: if(sort_dir == :asc, do: "asc", else: "desc")
    }
  end

  def list_total_claim_reports_for_export do
    from(c in MasterClaimSubmission,
      where: is_nil(c.deleted_at),
      order_by: [desc: c.id],
      preload: [:policy]
    )
    |> Repo.all()
  end

  def total_claim_report_statuses do
    ["Draft", "Submitted", "Under Review", "Approved", "Rejected"]
  end

  @doc """
  Counts employees in trn_mapping_live_employees filtered by relationship and status.
  Useful for dashboard stats showing, e.g., active Employee-relationship members.
  """
  def count_live_employees_by_relationship_and_status(relationship, status) do
    Repo.aggregate(
      from(e in TrnMappingLiveEmployee,
        where: e.relationship == ^relationship and e.status == ^status and is_nil(e.deleted_at)
      ),
      :count,
      :id
    ) || 0
  end

  def get_global_claims_corner_summary do
    claims =
      from(r in MasterTotalClaimReport, where: is_nil(r.deleted_at))
      |> Repo.all()

    Enum.reduce(
      claims,
      %{
        closed_amount: 0.0,
        paid_amount: 0.0,
        rejected_amount: 0.0,
        process_amount: 0.0
      },
      fn claim, acc ->
        status = (claim.claim_status || "") |> String.trim() |> String.downcase()
        claimed = claim.amount_claimed || 0.0
        paid = claim.claim_paid_amount || claim.amount_sanctioned || claimed

        cond do
          status == "closed" or String.contains?(status, "close") ->
            %{acc | closed_amount: acc.closed_amount + claimed}

          status in ["paid", "settled", "claim paid"] or String.contains?(status, "paid") or
              String.contains?(status, "settle") ->
            %{acc | paid_amount: acc.paid_amount + paid}

          status == "rejected" or String.contains?(status, "reject") ->
            %{acc | rejected_amount: acc.rejected_amount + claimed}

          status in ["under process", "in process", "processing", "pending"] or
            String.contains?(status, "process") or String.contains?(status, "pending") ->
            %{acc | process_amount: acc.process_amount + claimed}

          true ->
            acc
        end
      end
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

  def list_active_policies_by_corporate(corporate_id, fy_id \\ nil) do
    corporate = Repo.get(Corporate, corporate_id)
    corporate_name = corporate && corporate.corporate_name
    normalized_corporate_name = StringUtils.downcase(corporate_name)

    query =
      if is_binary(corporate_name) and corporate_name != "" do
        from p in Policy,
          where:
            (p.ref_corporate_id == ^corporate_id or
               fragment("lower(trim(?))", p.corporate_name) == ^normalized_corporate_name) and
              p.status in [0, 1, 2] and not is_nil(p.policy_number) and
              fragment("trim(?) <> ''", p.policy_number)
      else
        from p in Policy,
          where:
            p.ref_corporate_id == ^corporate_id and p.status in [0, 1, 2] and
              not is_nil(p.policy_number) and
              fragment("trim(?) <> ''", p.policy_number)
      end

    query =
      from p in query,
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

    query =
      if fy_id && fy_id != 0 do
        where(query, [p], p.ref_fy_year_id == ^fy_id)
      else
        query
      end

    Repo.all(query)
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

  def get_policy_with_wizard_preloads!(id) do
    get_policy!(id)
    |> Repo.preload([:escalation_matrices, :documents, :sum_insureds])
  end

  def get_policy_with_cd_preloads!(id) do
    get_policy!(id)
    |> Repo.preload([:corporate, :insurer_ref])
  end

  def get_total_claim_report!(id) do
    Repo.get!(MasterTotalClaimReport, id)
  end

  def get_live_employee(id) do
    Repo.get(TrnMappingLiveEmployee, id)
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

  # === Policy Features (Step 2 & 4) ===

  defdelegate list_policy_feature_template_fields(template_id), to: PolicyFeatures
  defdelegate list_policy_identifiers_for_policy(policy), to: PolicyFeatures
  defdelegate get_template_id_for_policy(policy), to: PolicyFeatures
  defdelegate list_mapped_features_by_policy(policy_id), to: PolicyFeatures
  defdelegate get_mapped_feature_details(policy_id, feature_id), to: PolicyFeatures
  defdelegate create_mapped_feature(attrs), to: PolicyFeatures
  defdelegate update_mapped_feature(mapping, attrs), to: PolicyFeatures
  defdelegate delete_mapped_feature(policy_id, feature_id), to: PolicyFeatures
  defdelegate list_features_by_identifier(policy_id, feature_identifier_id), to: PolicyFeatures

  # === Policy Sum Insured (Step 3) ===

  defdelegate list_sum_insureds_for_policy(policy_id), to: PolicySumInsured

  defdelegate save_policy_sum_insureds(policy_id, sum_insured_list, user_id \\ nil),
    to: PolicySumInsured

  defdelegate create_sum_insured(policy_id, attrs, user_id \\ nil), to: PolicySumInsured
  defdelegate delete_sum_insured(id, user_id \\ nil), to: PolicySumInsured

  # === Policy Data Uploads (Step 4) ===

  defdelegate list_data_uploads_for_policy(policy_id), to: PolicyDataUploads

  defp normalize_page(value) when is_integer(value) and value > 0, do: value

  defp normalize_page(value) when is_binary(value) do
    case Integer.parse(value) do
      {page, ""} when page > 0 -> page
      _ -> 1
    end
  end

  defp normalize_page(_value), do: 1

  # === TrnMappingLiveEmployee & Enrollment Queries ===

  @doc """
  Returns member counts (%{employees_count: integer, dependents_count: integer, lives_count: integer})
  for a policy ID. Defaults to 0 if no policy ID or no records exist.
  """
  def get_policy_member_counts(nil),
    do: %{employees_count: 0, dependents_count: 0, lives_count: 0}

  def get_policy_member_counts(policy_id) do
    base =
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and is_nil(e.deleted_at) and
            (e.status == "active" or is_nil(e.status))

    emp_query =
      from e in base,
        where: fragment("LOWER(?)", e.relationship) in ["employee", "self"]

    dep_query =
      from e in base,
        where: fragment("LOWER(?)", e.relationship) not in ["employee", "self"]

    emp_count = Repo.aggregate(emp_query, :count, :id) || 0
    dep_count = Repo.aggregate(dep_query, :count, :id) || 0

    %{
      employees_count: emp_count,
      dependents_count: dep_count,
      lives_count: emp_count + dep_count
    }
  end

  @doc """
  Returns a paginated map of primary employees for a given policy_id.
  Page size is 15. Supports filtering by params: employee_name, employee_code, sum_insured, mobile_number, email.
  """
  def list_policy_employees_paginated(policy_id, params \\ %{})

  def list_policy_employees_paginated(nil, _params) do
    %{
      entries: [],
      page: 1,
      page_size: 15,
      total_entries: 0,
      total_pages: 1
    }
  end

  def list_policy_employees_paginated(policy_id, params) do
    page = normalize_page(Map.get(params, "page", 1))
    page_size = 15

    base_query =
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and
            is_nil(e.deleted_at) and
            (e.status == "active" or is_nil(e.status)) and
            fragment("LOWER(?)", e.relationship) in ["employee", "self"]

    base_query =
      base_query
      |> me_filter_search(:employee_name, params["employee_name"])
      |> me_filter_search(:employee_code, params["employee_code"])
      |> me_filter_search(:sum_insured, params["sum_insured"])
      |> me_filter_search(:mobile_number, params["mobile_number"])
      |> me_filter_search(:email, params["email"])

    total_entries = Repo.aggregate(base_query, :count, :id)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = min(page, total_pages)

    entries =
      base_query
      |> order_by([e], asc: e.id)
      |> offset(^((page - 1) * page_size))
      |> limit(^page_size)
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  @doc """
  Returns a paginated list of dependents for a given employee_code and policy_id.
  Page size is 10. Supports search term filtering across name, relationship, mobile, email.
  """
  def list_employee_dependents_paginated(policy_id, employee_code, params \\ %{})

  def list_employee_dependents_paginated(nil, _code, _params) do
    %{
      entries: [],
      page: 1,
      page_size: 10,
      total_entries: 0,
      total_pages: 1
    }
  end

  def list_employee_dependents_paginated(policy_id, employee_code, params) do
    page = normalize_page(Map.get(params, "page", 1))
    page_size = 10
    search = String.trim(Map.get(params, "search", ""))

    base_query =
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and
            e.employee_code == ^employee_code and
            is_nil(e.deleted_at) and
            (e.status == "active" or is_nil(e.status)) and
            fragment("LOWER(?)", e.relationship) not in ["employee", "self"]

    base_query =
      if search != "" do
        pattern = "%#{search}%"

        from e in base_query,
          where:
            ilike(e.employee_name, ^pattern) or
              ilike(e.relationship, ^pattern) or
              ilike(e.mobile_number, ^pattern) or
              ilike(e.email, ^pattern)
      else
        base_query
      end

    total_entries = Repo.aggregate(base_query, :count, :id)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = min(page, total_pages)

    entries =
      base_query
      |> order_by([e], asc: e.id)
      |> offset(^((page - 1) * page_size))
      |> limit(^page_size)
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  @doc """
  Generates a CSV string for all primary active employees of a policy.
  """
  def export_policy_employees_csv(nil), do: ""

  def export_policy_employees_csv(policy_id) do
    query =
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and
            is_nil(e.deleted_at) and
            (e.status == "active" or is_nil(e.status)) and
            fragment("LOWER(?)", e.relationship) in ["employee", "self"],
        order_by: [asc: e.id]

    employees = Repo.all(query)

    headers = [
      "SI NO",
      "EMPLOYEE NAME",
      "EMPLOYEE CODE",
      "GENDER",
      "MEMBER ID",
      "SUM INSURED",
      "EMPLOYEE MOBILE NUMBER",
      "EMPLOYEE EMAIL"
    ]

    rows =
      employees
      |> Enum.with_index(1)
      |> Enum.map(fn {emp, idx} ->
        [
          idx,
          emp.employee_name || "",
          emp.employee_code || "",
          emp.gender || "",
          emp.member_card_number || "",
          emp.sum_insured || "",
          emp.mobile_number || "",
          emp.email || ""
        ]
      end)

    [headers | rows]
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> IO.iodata_to_binary()
  end

  defp me_filter_search(query, _field, nil), do: query
  defp me_filter_search(query, _field, ""), do: query

  defp me_filter_search(query, :employee_name, val) do
    pattern = "%#{String.trim(val)}%"
    from e in query, where: ilike(e.employee_name, ^pattern)
  end

  defp me_filter_search(query, :employee_code, val) do
    pattern = "%#{String.trim(val)}%"
    from e in query, where: ilike(e.employee_code, ^pattern)
  end

  defp me_filter_search(query, :sum_insured, val) do
    pattern = "%#{String.trim(val)}%"
    from e in query, where: fragment("CAST(? AS TEXT)", e.sum_insured) |> ilike(^pattern)
  end

  defp me_filter_search(query, :mobile_number, val) do
    pattern = "%#{String.trim(val)}%"
    from e in query, where: ilike(e.mobile_number, ^pattern)
  end

  defp me_filter_search(query, :email, val) do
    pattern = "%#{String.trim(val)}%"
    from e in query, where: ilike(e.email, ^pattern)
  end

  # === List View Queries (Active, Inception, Addition, Deletion) ===

  @doc """
  Returns counts for List View tabs (%{active_count: integer, inception_count: integer, addition_count: integer, deletion_count: integer}).
  """
  def get_policy_list_counts(nil) do
    %{active_count: 0, inception_count: 0, addition_count: 0, deletion_count: 0}
  end

  def get_policy_list_counts(policy_id) do
    active_count =
      Repo.aggregate(
        from(e in TrnMappingLiveEmployee,
          where:
            e.ref_policy_id == ^policy_id and is_nil(e.deleted_at) and
              (e.status == "active" or is_nil(e.status))
        ),
        :count,
        :id
      ) || 0

    inception_count =
      Repo.aggregate(
        from(m in MasterInceptionDataUpload,
          where: m.ref_policy_id == ^policy_id and is_nil(m.deleted_at)
        ),
        :count,
        :id
      ) || 0

    endorsement_data = get_deduplicated_endorsement_records(policy_id)
    addition_count = length(endorsement_data.addition)
    deletion_count = length(endorsement_data.deletion)

    %{
      active_count: active_count,
      inception_count: inception_count,
      addition_count: addition_count,
      deletion_count: deletion_count
    }
  end

  @doc """
  Returns statistics for the Corporate Portal dashboard (claim analysis in amount/ratio/count, enrollment list counts).
  """
  def get_dashboard_claim_stats(nil) do
    %{
      claim_analysis_in_amount: %{
        claims_paid: 0.0,
        claims_underprocess: 0.0,
        claims_closed: 0.0,
        claims_rejected: 0.0,
        reported_claims: 0.0
      },
      claim_analysis_in_ratio: %{
        claims_paid_ratio: 0.0,
        claims_underprocess_ratio: 0.0
      },
      claim_analysis_in_count: %{
        claims_paid_count: 0,
        claims_underprocess_count: 0,
        claims_closed_count: 0,
        claims_rejected_count: 0,
        reported_claims_count: 0
      },
      enrollment_list: %{
        active_list: 0,
        inception_list: 0,
        addition_list: 0,
        deletion_list: 0
      }
    }
  end

  def get_dashboard_claim_stats(policy_id) do
    # 1. claim_analysis_in_amount
    claims_paid =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "paid"
        ),
        :sum,
        :claim_paid_amount
      ) || 0.0

    claims_underprocess =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "under process"
        ),
        :sum,
        :amount_sanctioned
      ) || 0.0

    claims_closed =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "closed"
        ),
        :sum,
        :amount_claimed
      ) || 0.0

    claims_rejected =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "rejected"
        ),
        :sum,
        :amount_claimed
      ) || 0.0

    reported_claims =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where: c.ref_policy_id == ^policy_id and is_nil(c.deleted_at)
        ),
        :sum,
        :amount_claimed
      ) || 0.0

    # 2. claim_analysis_in_ratio
    total_paid_amount =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where: c.ref_policy_id == ^policy_id and is_nil(c.deleted_at)
        ),
        :sum,
        :claim_paid_amount
      ) || 0.0

    total_amount_sanctioned =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where: c.ref_policy_id == ^policy_id and is_nil(c.deleted_at)
        ),
        :sum,
        :amount_sanctioned
      ) || 0.0

    ratio_denominator = total_paid_amount + total_amount_sanctioned

    claims_underprocess_ratio_numerator =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) in [
                "under process",
                "closed",
                "rejected"
              ]
        ),
        :sum,
        :amount_sanctioned
      ) || 0.0

    claims_paid_ratio = calculate_ratio(claims_paid, ratio_denominator)

    claims_underprocess_ratio =
      calculate_ratio(claims_underprocess_ratio_numerator, ratio_denominator)

    # 3. claim_analysis_in_count
    claims_paid_count =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "paid"
        ),
        :count,
        :id
      ) || 0

    claims_underprocess_count =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "under process"
        ),
        :count,
        :id
      ) || 0

    claims_closed_count =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "closed"
        ),
        :count,
        :id
      ) || 0

    claims_rejected_count =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where:
            c.ref_policy_id == ^policy_id and is_nil(c.deleted_at) and
              fragment("lower(trim(?))", c.claim_status) == "rejected"
        ),
        :count,
        :id
      ) || 0

    reported_claims_count =
      Repo.aggregate(
        from(c in MasterTotalClaimReport,
          where: c.ref_policy_id == ^policy_id and is_nil(c.deleted_at)
        ),
        :count,
        :id
      ) || 0

    # 4. enrollment_list
    inception_list =
      Repo.aggregate(
        from(m in MasterInceptionDataUpload,
          where:
            m.ref_policy_id == ^policy_id and is_nil(m.deleted_at) and
              fragment("lower(trim(?))", m.relationship) == "employee"
        ),
        :count,
        :id
      ) || 0

    addition_list =
      Repo.aggregate(
        from(e in MasterEndorsementDataUpload,
          where:
            e.ref_policy_id == ^policy_id and is_nil(e.deleted_at) and
              fragment("lower(trim(?))", e.endorsement_type) in [
                "employee_addition",
                "employee addition"
              ]
        ),
        :count,
        :id
      ) || 0

    deletion_list =
      Repo.aggregate(
        from(e in MasterEndorsementDataUpload,
          where:
            e.ref_policy_id == ^policy_id and is_nil(e.deleted_at) and
              fragment("lower(trim(?))", e.endorsement_type) in [
                "employee_deletion",
                "employee deletion"
              ]
        ),
        :count,
        :id
      ) || 0

    active_list = inception_list + addition_list - deletion_list

    %{
      claim_analysis_in_amount: %{
        claims_paid: claims_paid,
        claims_underprocess: claims_underprocess,
        claims_closed: claims_closed,
        claims_rejected: claims_rejected,
        reported_claims: reported_claims
      },
      claim_analysis_in_ratio: %{
        claims_paid_ratio: claims_paid_ratio,
        claims_underprocess_ratio: claims_underprocess_ratio
      },
      claim_analysis_in_count: %{
        claims_paid_count: claims_paid_count,
        claims_underprocess_count: claims_underprocess_count,
        claims_closed_count: claims_closed_count,
        claims_rejected_count: claims_rejected_count,
        reported_claims_count: reported_claims_count
      },
      enrollment_list: %{
        active_list: active_list,
        inception_list: inception_list,
        addition_list: addition_list,
        deletion_list: deletion_list
      }
    }
  end

  defp calculate_ratio(_numerator, denominator) when denominator == 0 or denominator == 0.0 do
    0.0
  end

  defp calculate_ratio(numerator, denominator) do
    Float.round(numerator / denominator * 100.0, 2)
  end

  @doc """
  Returns paginated list view entries (page size 10) for a given list_type ("active", "inception", "addition", "deletion").
  """
  def list_policy_list_view_paginated(nil, _list_type, _params) do
    %{
      entries: [],
      page: 1,
      page_size: 10,
      total_entries: 0,
      total_pages: 1
    }
  end

  def list_policy_list_view_paginated(policy_id, list_type, params) do
    page = normalize_page(Map.get(params, "page", 1))
    page_size = 10

    all_records =
      case list_type do
        "active" ->
          get_active_live_employee_records(policy_id)

        "inception" ->
          get_inception_records(policy_id)

        "addition" ->
          get_deduplicated_endorsement_records(policy_id).addition

        "deletion" ->
          get_deduplicated_endorsement_records(policy_id).deletion

        _ ->
          get_active_live_employee_records(policy_id)
      end

    filtered_records = filter_list_records(all_records, params)

    total_entries = length(filtered_records)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = min(page, total_pages)

    entries =
      filtered_records
      |> Enum.slice((page - 1) * page_size, page_size)

    %{
      entries: entries,
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  @doc """
  Generates CSV binary for List View export.
  """
  def export_policy_list_view_csv(nil, _list_type), do: ""

  def export_policy_list_view_csv(policy_id, list_type) do
    policy = Repo.get(Policy, policy_id)
    policy_number = (policy && policy.policy_number) || ""

    records =
      case list_type do
        "active" -> get_active_live_employee_records(policy_id)
        "inception" -> get_inception_records(policy_id)
        "addition" -> get_deduplicated_endorsement_records(policy_id).addition
        "deletion" -> get_deduplicated_endorsement_records(policy_id).deletion
        _ -> get_active_live_employee_records(policy_id)
      end

    headers = [
      "SI NO",
      "EMPLOYEE NAME",
      "EMPLOYEE ID",
      "MEMBER ID",
      "AGE",
      "DOB",
      "GENDER",
      "RELATION",
      "DATE OF JOINING",
      "ENDORSEMENT NO",
      "ENDORSEMENT DATE",
      "SUMINSURED",
      "POLICY NUMBER",
      "EMPLOYEE MOBILE",
      "EMPLOYEE EMAIL"
    ]

    rows =
      records
      |> Enum.with_index(1)
      |> Enum.map(fn {rec, idx} ->
        [
          idx,
          rec.employee_name || "",
          rec.employee_code || "",
          rec.member_card_number || "",
          rec.age || "",
          rec.dob || "",
          rec.gender || "",
          rec.relationship || "",
          rec.doj || "",
          rec.endorsement_number || "",
          rec.endorsement_date || "",
          rec.sum_insured || "",
          policy_number,
          rec.mobile_number || "",
          rec.email || ""
        ]
      end)

    [headers | rows]
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> IO.iodata_to_binary()
  end

  defp get_active_live_employee_records(policy_id) do
    Repo.all(
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and is_nil(e.deleted_at) and
            (e.status == "active" or is_nil(e.status)),
        order_by: [asc: e.id]
    )
  end

  defp get_inception_records(policy_id) do
    Repo.all(
      from m in MasterInceptionDataUpload,
        where: m.ref_policy_id == ^policy_id and is_nil(m.deleted_at),
        order_by: [asc: m.id]
    )
  end

  defp get_deduplicated_endorsement_records(policy_id) do
    records =
      Repo.all(
        from m in MasterEndorsementDataUpload,
          where: m.ref_policy_id == ^policy_id and is_nil(m.deleted_at),
          order_by: [asc: m.id]
      )

    classified =
      Enum.map(records, fn rec ->
        type = rec.endorsement_type |> to_string() |> String.downcase()

        category =
          cond do
            type in ["employee_addition", "dependent_addition", "addition", "add"] or
                String.contains?(type, "add") ->
              :addition

            type in ["employee_deletion", "dependent_deletion", "deletion", "del"] or
                String.contains?(type, "del") ->
              :deletion

            true ->
              :other
          end

        {rec, category}
      end)

    additions = Enum.filter(classified, fn {_r, cat} -> cat == :addition end)
    deletions = Enum.filter(classified, fn {_r, cat} -> cat == :deletion end)

    member_key = fn rec ->
      code = (rec.employee_code || "") |> String.trim() |> String.downcase()
      rel = (rec.relationship || "") |> String.trim() |> String.downcase()
      {code, rel}
    end

    addition_keys = additions |> Enum.map(fn {r, _} -> member_key.(r) end) |> MapSet.new()
    deletion_keys = deletions |> Enum.map(fn {r, _} -> member_key.(r) end) |> MapSet.new()

    cancelled_keys = MapSet.intersection(addition_keys, deletion_keys)

    valid_additions =
      additions
      |> Enum.map(fn {r, _} -> r end)
      |> Enum.reject(fn r -> member_key.(r) in cancelled_keys end)
      |> Enum.uniq_by(member_key)

    valid_deletions =
      deletions
      |> Enum.map(fn {r, _} -> r end)
      |> Enum.reject(fn r -> member_key.(r) in cancelled_keys end)
      |> Enum.uniq_by(member_key)

    %{addition: valid_additions, deletion: valid_deletions}
  end

  defp filter_list_records(records, params) do
    emp_name = (params["employee_name"] || "") |> String.trim() |> String.downcase()
    emp_code = (params["employee_code"] || "") |> String.trim() |> String.downcase()
    sum_ins = (params["sum_insured"] || "") |> String.trim() |> String.downcase()
    mobile = (params["mobile_number"] || "") |> String.trim() |> String.downcase()
    email = (params["email"] || "") |> String.trim() |> String.downcase()
    search = (params["search"] || "") |> String.trim() |> String.downcase()

    Enum.filter(records, fn rec ->
      r_name = (rec.employee_name || "") |> String.downcase()
      r_code = (rec.employee_code || "") |> String.downcase()
      r_sum = (rec.sum_insured || "") |> to_string() |> String.downcase()
      r_mob = (rec.mobile_number || "") |> String.downcase()
      r_email = (rec.email || "") |> String.downcase()
      r_rel = (rec.relationship || "") |> String.downcase()

      match_name = emp_name == "" or String.contains?(r_name, emp_name)
      match_code = emp_code == "" or String.contains?(r_code, emp_code)
      match_sum = sum_ins == "" or String.contains?(r_sum, sum_ins)
      match_mob = mobile == "" or String.contains?(r_mob, mobile)
      match_email = email == "" or String.contains?(r_email, email)

      match_search =
        search == "" or String.contains?(r_name, search) or String.contains?(r_code, search) or
          String.contains?(r_mob, search) or String.contains?(r_email, search) or
          String.contains?(r_rel, search)

      match_name and match_code and match_sum and match_mob and match_email and match_search
    end)
  end

  # === Total Claim Report Functions ===

  @total_claim_page_size 10

  def list_total_claim_reports_paginated(policy_id, params \\ %{})

  def list_total_claim_reports_paginated(policy_id, _params) when policy_id in [nil, "", "nil"] do
    %{
      entries: [],
      page: 1,
      page_size: @total_claim_page_size,
      total_entries: 0,
      total_pages: 1,
      search: ""
    }
  end

  def list_total_claim_reports_paginated(policy_id, params) do
    page = positive_int(Map.get(params, "page", 1), 1)
    search = StringUtils.normalize(Map.get(params, "search", ""))

    base_query =
      from r in MasterTotalClaimReport,
        where: r.ref_policy_id == ^policy_id and is_nil(r.deleted_at)

    query =
      if search != "" do
        search_pattern = "%#{search}%"

        from r in base_query,
          where:
            ilike(r.employee_code, ^search_pattern) or
              ilike(r.employee_name, ^search_pattern) or
              ilike(r.patient_name, ^search_pattern) or
              ilike(r.insurance_claim_no, ^search_pattern) or
              ilike(r.tpa_claim_no, ^search_pattern) or
              ilike(r.hospital_name, ^search_pattern) or
              ilike(r.claim_status, ^search_pattern) or
              ilike(r.claim_type, ^search_pattern)
      else
        base_query
      end

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = max(div(max(total_entries, 1), @total_claim_page_size), 1)
    page = min(page, total_pages)

    entries =
      query
      |> order_by([r], desc: r.id)
      |> offset(^((page - 1) * @total_claim_page_size))
      |> limit(^@total_claim_page_size)
      |> Repo.all()

    %{
      entries: entries,
      page: page,
      page_size: @total_claim_page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      search: search
    }
  end

  def list_total_claim_reports_for_export(policy_id) when policy_id in [nil, "", "nil"], do: []

  def list_total_claim_reports_for_export(policy_id) do
    from(r in MasterTotalClaimReport,
      where: r.ref_policy_id == ^policy_id and is_nil(r.deleted_at),
      order_by: [desc: r.id]
    )
    |> Repo.all()
  end

  def export_total_claims_csv(policy_id) do
    claims = list_total_claim_reports_for_export(policy_id)

    headers = [
      "EMPLOYEE CODE",
      "EMPLOYEE NAME",
      "BENEFICIARY NAME",
      "RELATION",
      "CLAIM TYPE",
      "CLAIM STATUS",
      "CLAIM NO",
      "TPA CLAIM NO",
      "HOSPITALIZATION DATE",
      "HOSPITAL NAME",
      "DISCHARGE DATE",
      "AMOUNT CLAIMED",
      "AMOUNT SANCTIONED",
      "CLAIM PAID AMOUNT",
      "PATIENT GENDER",
      "HOSPITAL STATE",
      "NETWORK STATUS",
      "TREATMENT TYPE",
      "LEVEL OF CARE",
      "CAUSE",
      "CITY",
      "AGE",
      "CLAIM FILE SUBMITTED DT",
      "CLAIM SETTLED DATE",
      "DISEASE CATEGORY",
      "CLAIM REGISTERED DATE",
      "INTIMATION METHOD",
      "SUM INSURED",
      "TDS AMOUNT",
      "DEDUCTION AMOUNT",
      "DEDUCTION REASON",
      "DEFICIENCY INTIMATED DATE",
      "DEFICIENCY SUBMISSION DATE",
      "ICD CODE",
      "CLOSE REASONS",
      "DEFICIENCY REASON",
      "CLAIM SUB STATUS"
    ]

    rows =
      Enum.map(claims, fn c ->
        [
          c.employee_code || "",
          c.employee_name || "",
          c.patient_name || "",
          c.relationship || "",
          c.claim_type || "",
          c.claim_status || "",
          c.insurance_claim_no || "",
          c.tpa_claim_no || "",
          c.date_of_hospitalization || "",
          c.hospital_name || "",
          c.date_of_discharge || "",
          to_string(c.amount_claimed || ""),
          to_string(c.amount_sanctioned || ""),
          to_string(c.claim_paid_amount || ""),
          c.patient_gender || "",
          c.hospital_state || "",
          c.network_status || "",
          c.treatment_type || "",
          c.level_of_care || "",
          c.cause || "",
          c.city || "",
          to_string(c.age || ""),
          c.claim_file_submitted_dt || "",
          c.claim_settled_date || "",
          c.disease_category || "",
          c.claim_registered_date || "",
          c.intimation_method || "",
          to_string(c.sum_insured || ""),
          to_string(c.tds_amount || ""),
          to_string(c.deduction_amount || ""),
          c.deduction_reason || "",
          c.deficiency_intimated_date || "",
          c.deficiency_submission_date || "",
          c.icd_code || "",
          c.close_reasons || "",
          c.deficiency_reason || "",
          c.claim_sub_status || ""
        ]
      end)

    NimbleCSV.RFC4180.dump_to_iodata([headers | rows]) |> IO.iodata_to_binary()
  end

  def get_total_claim_summary(nil), do: default_claim_summary()

  def get_total_claim_summary(policy_id) do
    claims =
      from(r in MasterTotalClaimReport,
        where: r.ref_policy_id == ^policy_id and is_nil(r.deleted_at)
      )
      |> Repo.all()

    Enum.reduce(
      claims,
      %{
        paid_amount: 0.0,
        paid_count: 0,
        process_amount: 0.0,
        process_count: 0,
        rejected_amount: 0.0,
        rejected_count: 0,
        reported_amount: 0.0,
        reported_count: 0
      },
      fn claim, acc ->
        status = (claim.claim_status || "") |> String.trim() |> String.downcase()
        claimed = claim.amount_claimed || 0.0
        paid = claim.claim_paid_amount || claim.amount_sanctioned || claimed

        acc = %{
          acc
          | reported_amount: acc.reported_amount + claimed,
            reported_count: acc.reported_count + 1
        }

        cond do
          status in ["paid", "settled", "claim paid"] or String.contains?(status, "paid") or
              String.contains?(status, "settle") ->
            %{
              acc
              | paid_amount: acc.paid_amount + paid,
                paid_count: acc.paid_count + 1
            }

          status in ["under process", "in process", "processing", "pending"] or
            String.contains?(status, "process") or String.contains?(status, "pending") ->
            %{
              acc
              | process_amount: acc.process_amount + claimed,
                process_count: acc.process_count + 1
            }

          status in ["closed", "rejected", "close", "reject"] or String.contains?(status, "close") or
              String.contains?(status, "reject") ->
            %{
              acc
              | rejected_amount: acc.rejected_amount + claimed,
                rejected_count: acc.rejected_count + 1
            }

          true ->
            acc
        end
      end
    )
  end

  defp default_claim_summary do
    %{
      paid_amount: 0.0,
      paid_count: 0,
      process_amount: 0.0,
      process_count: 0,
      rejected_amount: 0.0,
      rejected_count: 0,
      reported_amount: 0.0,
      reported_count: 0
    }
  end

  defp positive_int(val, _default) when is_integer(val) and val > 0, do: val

  defp positive_int(val, default) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} when int > 0 -> int
      _ -> default
    end
  end

  defp positive_int(_val, default), do: default

  # === Escalation Matrices for Policy (Step 5) ===

  defdelegate list_escalation_matrices_for_policy(policy_id), to: PolicyEscalation

  defdelegate save_policy_escalation_matrices(policy_id, matrices_list, user_id \\ nil),
    to: PolicyEscalation

  defdelegate create_policy_escalation_matrix(policy_id, attrs, user_id \\ nil),
    to: PolicyEscalation

  defdelegate delete_policy_escalation_matrix(id, user_id \\ nil), to: PolicyEscalation

  # === Master Policy Documents (Step 6) ===

  defdelegate list_documents_for_policy(policy_id, doc_type), to: PolicyDocuments
  defdelegate get_master_policy_document(id), to: PolicyDocuments
  defdelegate create_policy_document(attrs, user_id \\ nil), to: PolicyDocuments
  defdelegate delete_policy_document(id, user_id \\ nil), to: PolicyDocuments

  @doc """
  Returns line chart data showing count of policies expiring per calendar month.
  Queries the database for policies where policy_end_date >= NOW(), groups by month of policy_end_date,
  and maps them to a list corresponding to Jan-Dec.
  """
  def get_expiring_policies_chart_data do
    query =
      from p in Policy,
        where: p.policy_end_date >= fragment("NOW()"),
        group_by: fragment("extract(month from ?)", p.policy_end_date),
        select: {
          fragment("extract(month from ?)::integer", p.policy_end_date),
          count(p.id)
        }

    results = Repo.all(query) |> Map.new()

    labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    values = Enum.map(1..12, fn m -> Map.get(results, m, 0) end)

    %{
      labels: labels,
      values: values
    }
  end

  # === Cashless Hospitals ===

  def search_insurers_by_name(query) do
    search_pattern = "%#{query}%"

    Repo.all(
      from i in Insurer,
        where: i.status == 1 and ilike(i.name, ^search_pattern),
        order_by: [asc: i.name],
        limit: 10
    )
  end

  def search_tpas_by_name(query) do
    search_pattern = "%#{query}%"

    Repo.all(
      from t in Tpa,
        where: t.status == 1 and ilike(t.name, ^search_pattern),
        order_by: [asc: t.name],
        limit: 10
    )
  end

  def list_cashless_hospitals_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1) |> normalize_page()
    limit = 15
    offset = (page - 1) * limit

    query = from ch in CashlessHospital, order_by: [desc: ch.id]

    query =
      if search = opts[:search] do
        if search != "" do
          search_pattern = "%#{search}%"

          from ch in query,
            where: ilike(ch.insurer_name, ^search_pattern) or ilike(ch.tpa_name, ^search_pattern)
        else
          query
        end
      else
        query
      end

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = max(div(max(total_entries, 1) + limit - 1, limit), 1)
    page = min(page, total_pages)

    entries =
      query
      |> offset(^((page - 1) * limit))
      |> limit(^limit)
      |> Repo.all()

    entries_with_nums =
      entries
      |> Enum.with_index()
      |> Enum.map(fn {item, idx} ->
        row_num = offset + idx + 1
        Map.put(item, :row_num, row_num)
      end)

    %{
      entries: entries_with_nums,
      page: page,
      page_size: limit,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  def create_cashless_hospital_import(attrs) do
    Repo.transaction(fn ->
      ch_attrs = %{
        ref_insurer_id: attrs.ref_insurer_id,
        insurer_name: attrs.insurer_name,
        ref_tpa_id: attrs.ref_tpa_id,
        tpa_name: attrs.tpa_name,
        ch_upload_data: attrs.ch_upload_data,
        original_file_name: attrs.original_file_name,
        status: 1,
        is_dataupload: 1
      }

      case %CashlessHospital{} |> CashlessHospital.changeset(ch_attrs) |> Repo.insert() do
        {:ok, cashless_hospital} ->
          content = File.read!(attrs.ch_upload_data) |> sanitize_utf8()
          rows = NimbleCSV.RFC4180.parse_string(content, skip_headers: true)

          Enum.each(rows, fn row ->
            row_attrs = %{
              hospital_name: clean_string(Enum.at(row, 0)),
              hospital_address: clean_string(Enum.at(row, 1)),
              location: clean_string(Enum.at(row, 2)),
              landmark: clean_string(Enum.at(row, 3)),
              city: clean_string(Enum.at(row, 4)),
              state: clean_string(Enum.at(row, 5)),
              pincode: parse_integer(Enum.at(row, 6)),
              email: clean_string(Enum.at(row, 7)),
              stdcode: clean_string(Enum.at(row, 8)),
              phone: clean_string(Enum.at(row, 9)),
              insurer_name: attrs.insurer_name,
              ref_insurer_id: attrs.ref_insurer_id,
              tpa_name: attrs.tpa_name,
              ref_tpa_id: if(attrs.ref_tpa_id, do: to_string(attrs.ref_tpa_id), else: nil),
              status: "1",
              latitude: parse_decimal(Enum.at(row, 10)),
              longitude: parse_decimal(Enum.at(row, 11))
            }

            if row_attrs.hospital_name && row_attrs.hospital_name != "" do
              %CashlessHospitalUpload{}
              |> CashlessHospitalUpload.changeset(row_attrs)
              |> Repo.insert!()
            end
          end)

          cashless_hospital

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp parse_integer(nil), do: nil
  defp parse_integer(""), do: nil

  defp parse_integer(val) when is_binary(val) do
    case Integer.parse(String.trim(val)) do
      {num, _} -> num
      _ -> nil
    end
  end

  defp parse_integer(val) when is_integer(val), do: val
  defp parse_integer(_), do: nil

  defp parse_decimal(nil), do: nil
  defp parse_decimal(""), do: nil

  defp parse_decimal(val) when is_binary(val) do
    case Decimal.cast(String.trim(val)) do
      {:ok, dec} -> dec
      _ -> nil
    end
  end

  defp parse_decimal(val) when is_float(val), do: Decimal.from_float(val)
  defp parse_decimal(val) when is_integer(val), do: Decimal.new(val)
  defp parse_decimal(_), do: nil

  defp clean_string(nil), do: ""

  defp clean_string(val) when is_binary(val) do
    val
    |> sanitize_utf8()
    |> String.replace(~r/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\xA0]/, " ")
    |> String.replace("\u00A0", " ")
    |> String.trim()
  end

  defp clean_string(val), do: val |> to_string() |> clean_string()

  defp sanitize_utf8(binary) when is_binary(binary) do
    if String.valid?(binary) do
      binary
      |> String.replace(<<160>>, " ")
      |> String.replace("\u00A0", " ")
    else
      binary
      |> :binary.bin_to_list()
      |> Enum.map(fn
        b when b in 0..127 -> b
        _ -> ?\s
      end)
      |> List.to_string()
    end
  end

  # === Corporate Cashless Hospitals ===

  def list_cashless_hospitals_by_tpa_paginated(ref_tpa_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1) |> normalize_page()
    limit = 15
    offset = (page - 1) * limit
    tpa_id_str = if is_integer(ref_tpa_id), do: to_string(ref_tpa_id), else: ref_tpa_id

    if is_nil(tpa_id_str) or tpa_id_str == "" do
      %{
        entries: [],
        page: 1,
        page_size: limit,
        total_entries: 0,
        total_pages: 1
      }
    else
      query =
        from chu in CashlessHospitalUpload,
          where: chu.ref_tpa_id == ^tpa_id_str and is_nil(chu.deleted_at),
          order_by: [asc: chu.hospital_name]

      query =
        if search = opts[:search] do
          if search != "" do
            search_pattern = "%#{search}%"

            from chu in query,
              where:
                ilike(chu.hospital_name, ^search_pattern) or
                  ilike(chu.city, ^search_pattern) or
                  ilike(chu.state, ^search_pattern) or
                  ilike(chu.hospital_address, ^search_pattern)
          else
            query
          end
        else
          query
        end

      total_entries = Repo.aggregate(query, :count, :id)
      total_pages = max(div(max(total_entries, 1) + limit - 1, limit), 1)
      page = min(page, total_pages)

      entries =
        query
        |> offset(^((page - 1) * limit))
        |> limit(^limit)
        |> Repo.all()

      entries_with_nums =
        entries
        |> Enum.with_index()
        |> Enum.map(fn {item, idx} ->
          row_num = offset + idx + 1
          Map.put(item, :row_num, row_num)
        end)

      %{
        entries: entries_with_nums,
        page: page,
        page_size: limit,
        total_entries: total_entries,
        total_pages: total_pages
      }
    end
  end

  def export_cashless_hospitals_csv(ref_tpa_id, search \\ "") do
    tpa_id_str = if is_integer(ref_tpa_id), do: to_string(ref_tpa_id), else: ref_tpa_id

    if is_nil(tpa_id_str) or tpa_id_str == "" do
      ""
    else
      query =
        from chu in CashlessHospitalUpload,
          where: chu.ref_tpa_id == ^tpa_id_str and is_nil(chu.deleted_at),
          order_by: [asc: chu.hospital_name]

      query =
        if search != "" do
          search_pattern = "%#{search}%"

          from chu in query,
            where:
              ilike(chu.hospital_name, ^search_pattern) or
                ilike(chu.city, ^search_pattern) or
                ilike(chu.state, ^search_pattern) or
                ilike(chu.hospital_address, ^search_pattern)
        else
          query
        end

      hospitals = Repo.all(query)

      headers = [
        "SI NO",
        "HOSPITAL NAME",
        "ADDRESS",
        "LOCATION",
        "CITY",
        "STATE",
        "PINCODE",
        "PHONE",
        "EMAIL"
      ]

      rows =
        hospitals
        |> Enum.with_index(1)
        |> Enum.map(fn {chu, idx} ->
          [
            idx,
            chu.hospital_name || "",
            chu.hospital_address || "",
            chu.location || "",
            chu.city || "",
            chu.state || "",
            chu.pincode || "",
            chu.phone || "",
            chu.email || ""
          ]
        end)

      [headers]
      |> Enum.concat(rows)
      |> NimbleCSV.RFC4180.dump_to_iodata()
      |> IO.iodata_to_binary()
    end
  end

  def list_employee_logs_by_corporate(corporate_id) do
    Repo.all(
      from l in MasterEmployeeLog,
        join: e in TrnMappingLiveEmployee,
        on:
          fragment(
            "CASE WHEN ? ~ '^[0-9]+$' THEN ?::integer ELSE NULL END",
            l.employee_id,
            l.employee_id
          ) == e.id,
        join: p in Policy,
        on: e.ref_policy_id == p.id,
        where: e.ref_corporate_id == ^corporate_id,
        order_by: [desc: l.id],
        select: %{
          id: l.id,
          policy_number: p.policy_number,
          employee_name: e.employee_name,
          employee_code: e.employee_code,
          mobile_number: e.mobile_number,
          email: e.email,
          action: l.action,
          device_type: l.device_type,
          created_at: l.inserted_at
        }
    )
  end

  def export_employee_activity_csv(corporate_id) do
    logs = list_employee_logs_by_corporate(corporate_id)

    headers = [
      "SI NO",
      "POLICY NUMBER",
      "EMPLOYEE NAME",
      "EMPLOYEE CODE",
      "MOBILE NUMBER",
      "EMAIL ID",
      "ACTION",
      "DEVICE TYPE",
      "CREATED AT"
    ]

    rows =
      logs
      |> Enum.with_index(1)
      |> Enum.map(fn {log, idx} ->
        [
          idx,
          log.policy_number || "",
          log.employee_name || "",
          log.employee_code || "",
          log.mobile_number || "",
          log.email || "",
          log.action || "",
          log.device_type || "",
          NaiveDateTime.to_string(log.created_at) <> "Z"
        ]
      end)

    [headers]
    |> Enum.concat(rows)
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> IO.iodata_to_binary()
  end
end
