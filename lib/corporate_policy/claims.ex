defmodule CorporatePolicy.Claims do
  import Ecto.Query, warn: false

  alias CorporatePolicy.Claims.{ClaimLog, ClaimSubmissionDocument, MasterClaimSubmission}
  alias CorporatePolicy.Policies.TrnMappingLiveEmployee
  alias CorporatePolicy.Repo

  @page_size 15
  @min_documents 3
  @max_upload_size 8_000_000
  @allowed_extensions ~w(.pdf .png .jpg .jpeg)
  @claim_statuses ["Draft", "Submitted", "Under Review", "Approved", "Rejected"]
  @document_requirements [
    "Medicine Bills",
    "Doctor Consultation/Prescription/Advise Letter",
    "Lab Report",
    "Paid Receipt",
    "Discharge Card",
    "Indoor Case Papers",
    "Reports",
    "Hospital Bills and Receipts",
    "Other Documents"
  ]

  def page_size, do: @page_size
  def min_documents, do: @min_documents
  def max_upload_size, do: @max_upload_size
  def allowed_extensions, do: @allowed_extensions
  def claim_statuses, do: @claim_statuses
  def document_requirements, do: @document_requirements

  def portal_id_for(:admin), do: 1
  def portal_id_for(:corporate), do: 2
  def portal_id_for(:employee), do: 3

  def list_claims(user, portal, params \\ %{}) do
    page = positive_int(Map.get(params, "page", 1), 1)
    search = String.trim(Map.get(params, "search", ""))
    status = Map.get(params, "status", "")
    sort_by = Map.get(params, "sort_by", "inserted_at")
    sort_dir = Map.get(params, "sort_dir", "desc")

    query =
      MasterClaimSubmission
      |> where([c], is_nil(c.deleted_at))
      |> accessible_to(user, portal)
      |> maybe_filter_search(search)
      |> maybe_filter_status(status)

    total_entries = Repo.aggregate(query, :count, :id)
    total_pages = max(Integer.ceil_div(max(total_entries, 1), @page_size), 1)
    page = min(page, total_pages)

    entries =
      query
      |> order_by(^sort_expression(sort_by, sort_dir))
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
      sort_dir: sort_dir
    }
  end

  def list_claims_for_export(user, portal) do
    MasterClaimSubmission
    |> where([c], is_nil(c.deleted_at))
    |> accessible_to(user, portal)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  def get_claim!(id), do: Repo.get!(MasterClaimSubmission, id)

  def get_claim_with_details!(id) do
    MasterClaimSubmission
    |> Repo.get!(id)
    |> Repo.preload([:policy, :documents, :logs])
  end

  def change_claim(%MasterClaimSubmission{} = claim, attrs \\ %{}) do
    if Ecto.get_meta(claim, :state) == :built do
      MasterClaimSubmission.create_changeset(claim, attrs)
    else
      MasterClaimSubmission.update_changeset(claim, attrs)
    end
  end

  def create_claim(attrs, user, portal) do
    attrs =
      attrs
      |> normalize_reference_fields()
      |> enrich_claim_metadata()
      |> Map.put("portal_id", portal_id_for(portal))
      |> Map.put_new("claim_status", "Draft")
      |> Map.put_new("claim_number", generate_reference("CLM"))
      |> Map.put_new("intimation_number", generate_reference("INT"))
      |> Map.put("created_by", user.id)
      |> Map.put("updated_by", user.id)

    Repo.transaction(fn ->
      case %MasterClaimSubmission{}
           |> MasterClaimSubmission.create_changeset(attrs)
           |> Repo.insert() do
        {:ok, claim} ->
          create_log!(claim, user.id, portal_id_for(portal), "Created", attrs["remarks"])
          Repo.preload(claim, [:documents, :logs])

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
    |> unwrap_transaction()
  end

  def update_claim(%MasterClaimSubmission{} = claim, attrs, user, portal) do
    attrs =
      attrs
      |> normalize_reference_fields()
      |> enrich_claim_metadata()
      |> Map.put("updated_by", user.id)

    Repo.transaction(fn ->
      case claim
           |> MasterClaimSubmission.update_changeset(attrs)
           |> Repo.update() do
        {:ok, updated_claim} ->
          create_log!(updated_claim, user.id, portal_id_for(portal), "Updated", attrs["remarks"])
          Repo.preload(updated_claim, [:documents, :logs])

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
    |> unwrap_transaction()
  end

  def submit_claim(%MasterClaimSubmission{} = claim, user, portal) do
    document_count = count_claim_documents(claim.id)

    if document_count < @min_documents do
      {:error, :minimum_documents_not_met}
    else
      Repo.transaction(fn ->
        case claim
             |> MasterClaimSubmission.update_changeset(%{
               "claim_status" => "Submitted",
               "submitted_at" => DateTime.utc_now(),
               "updated_by" => user.id
             })
             |> Repo.update() do
          {:ok, submitted_claim} ->
            create_log!(
              submitted_claim,
              user.id,
              portal_id_for(portal),
              "Submitted",
              "Claim submitted"
            )

            Repo.preload(submitted_claim, [:documents, :logs])

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
      |> unwrap_transaction()
    end
  end

  def list_claim_documents(claim_id) do
    Repo.all(
      from d in ClaimSubmissionDocument,
        where: d.claim_id == ^claim_id and is_nil(d.deleted_at),
        order_by: [asc: d.inserted_at]
    )
  end

  def count_claim_documents(claim_id) do
    ClaimSubmissionDocument
    |> where([d], d.claim_id == ^claim_id and is_nil(d.deleted_at))
    |> Repo.aggregate(:count, :id)
  end

  def create_claim_document(%MasterClaimSubmission{} = claim, attrs, user, portal) do
    attrs =
      attrs
      |> Map.put("claim_id", claim.id)
      |> Map.put("policy_id", claim.ref_policy_id)
      |> Map.put("created_by", user.id)
      |> Map.put("updated_by", user.id)

    Repo.transaction(fn ->
      case %ClaimSubmissionDocument{}
           |> ClaimSubmissionDocument.changeset(attrs)
           |> Repo.insert() do
        {:ok, document} ->
          create_log!(
            claim,
            user.id,
            portal_id_for(portal),
            "Document Uploaded",
            document.document_name
          )

          document

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
    |> unwrap_transaction()
  end

  def delete_claim_document(
        %ClaimSubmissionDocument{} = document,
        %MasterClaimSubmission{} = claim,
        user,
        portal
      ) do
    Repo.transaction(fn ->
      case document
           |> Ecto.Changeset.change(deleted_at: DateTime.utc_now(), updated_by: user.id)
           |> Repo.update() do
        {:ok, deleted_document} ->
          create_log!(
            claim,
            user.id,
            portal_id_for(portal),
            "Document Deleted",
            deleted_document.document_name
          )

          deleted_document

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
    |> unwrap_transaction()
  end

  def list_accessible_corporates(_user, :admin) do
    CorporatePolicy.Policies.list_corporates()
  end

  def list_accessible_corporates(user, portal) when portal in [:corporate, :employee] do
    case user.ref_corporate_id do
      nil ->
        []

      corporate_id ->
        Enum.filter(
          CorporatePolicy.Policies.list_corporates(),
          &(&1.corporate_id == corporate_id)
        )
    end
  end

  def list_accessible_policies(_user, :admin) do
    CorporatePolicy.Policies.list_active_policies()
  end

  def list_accessible_policies(user, portal) when portal in [:corporate, :employee] do
    CorporatePolicy.Policies.list_active_policies()
    |> Enum.filter(&(&1.ref_corporate_id == user.ref_corporate_id))
  end

  def list_policy_employees(policy_id) do
    Repo.all(
      from e in TrnMappingLiveEmployee,
        where: e.ref_policy_id == ^policy_id and is_nil(e.deleted_at),
        order_by: [asc: e.employee_code, asc: e.employee_name]
    )
  end

  def get_policy_employee(policy_id, employee_code, patient_name) do
    Repo.one(
      from e in TrnMappingLiveEmployee,
        where:
          e.ref_policy_id == ^policy_id and e.employee_code == ^employee_code and
            e.employee_name == ^patient_name and is_nil(e.deleted_at),
        limit: 1
    )
  end

  def get_policy(policy_id) do
    CorporatePolicy.Policies.get_policy_with_preloads(policy_id)
  end

  def policy_option_label(policy) do
    [policy.policy_number, policy.policy_type, policy.corporate_name]
    |> Enum.reject(&is_nil_or_blank/1)
    |> Enum.join(" | ")
  end

  def to_csv(claims) do
    header = [
      "Claim Number",
      "Intimation Number",
      "Corporate Name",
      "Policy Number",
      "Employee Code",
      "Patient Name",
      "Claim Type",
      "Hospitalization Date",
      "Discharge Date",
      "Estimated Amount",
      "Status",
      "Created At"
    ]

    rows =
      Enum.map(claims, fn claim ->
        [
          claim.claim_number,
          claim.intimation_number,
          claim.corporate_name,
          claim.policy_number,
          claim.employee_code,
          claim.patient_name,
          claim.claim_type,
          format_date(claim.hospitalization_date),
          format_date(claim.discharge_date),
          claim.estimated_amount,
          claim.claim_status,
          format_datetime(claim.inserted_at)
        ]
      end)

    Enum.map_join([header | rows], "\n", fn row ->
      Enum.map_join(row, ",", &csv_escape/1)
    end)
  end

  def to_report_csv(claims) do
    header = [
      "Claim Number",
      "Intimation Number",
      "Corporate Name",
      "Policy Number",
      "Employee Code",
      "Employee Name",
      "Patient Name",
      "Relationship",
      "Claim Type",
      "Claim Status",
      "Portal ID",
      "Hospitalization Date",
      "Discharge Date",
      "Hospital Name",
      "Estimated Amount",
      "Claim Reason",
      "Hospital Address",
      "City",
      "State",
      "Pincode",
      "Treatment Details",
      "Remarks",
      "Submitted At",
      "Created At",
      "Updated At"
    ]

    rows =
      Enum.map(claims, fn claim ->
        [
          claim.claim_number,
          claim.intimation_number,
          claim.corporate_name,
          claim.policy_number,
          claim.employee_code,
          claim.employee_name,
          claim.patient_name,
          claim.relationship,
          claim.claim_type,
          claim.claim_status,
          claim.portal_id,
          format_date(claim.hospitalization_date),
          format_date(claim.discharge_date),
          claim.hospital_name,
          claim.estimated_amount,
          claim.claim_reason,
          claim.hospital_address,
          claim.city,
          claim.state,
          claim.pincode,
          claim.treatment_details,
          claim.remarks,
          format_datetime(claim.submitted_at),
          format_datetime(claim.inserted_at),
          format_datetime(claim.updated_at)
        ]
      end)

    Enum.map_join([header | rows], "\n", fn row ->
      Enum.map_join(row, ",", &csv_escape/1)
    end)
  end

  defp accessible_to(query, _user, :admin), do: query

  defp accessible_to(query, user, :corporate) do
    where(query, [c], c.ref_corporate_id == ^user.ref_corporate_id)
  end

  defp accessible_to(query, user, :employee) do
    where(query, [c], c.created_by == ^user.id)
  end

  defp maybe_filter_search(query, ""), do: query

  defp maybe_filter_search(query, search) do
    like = "%#{search}%"

    where(
      query,
      [c],
      ilike(c.claim_number, ^like) or
        ilike(c.intimation_number, ^like) or
        ilike(c.corporate_name, ^like) or
        ilike(c.policy_number, ^like) or
        ilike(c.employee_code, ^like) or
        ilike(c.patient_name, ^like)
    )
  end

  defp maybe_filter_status(query, ""), do: query
  defp maybe_filter_status(query, status), do: where(query, [c], c.claim_status == ^status)

  defp sort_expression(sort_by, sort_dir) do
    direction = if sort_dir == "asc", do: :asc, else: :desc

    case sort_by do
      "claim_number" -> [{direction, dynamic([c], c.claim_number)}]
      "corporate_name" -> [{direction, dynamic([c], c.corporate_name)}]
      "policy_number" -> [{direction, dynamic([c], c.policy_number)}]
      "employee_code" -> [{direction, dynamic([c], c.employee_code)}]
      "patient_name" -> [{direction, dynamic([c], c.patient_name)}]
      "claim_status" -> [{direction, dynamic([c], c.claim_status)}]
      "hospitalization_date" -> [{direction, dynamic([c], c.hospitalization_date)}]
      "discharge_date" -> [{direction, dynamic([c], c.discharge_date)}]
      _ -> [{direction, dynamic([c], c.inserted_at)}]
    end
  end

  defp normalize_reference_fields(attrs) do
    attrs
    |> stringify_keys()
    |> Map.update("ref_policy_id", nil, &parse_int/1)
    |> Map.update("ref_corporate_id", nil, &parse_int/1)
  end

  defp enrich_claim_metadata(%{"ref_policy_id" => nil} = attrs), do: attrs

  defp enrich_claim_metadata(attrs) do
    policy = get_policy(attrs["ref_policy_id"])

    corporate_name =
      cond do
        attrs["ref_corporate_id"] ->
          case Enum.find(
                 CorporatePolicy.Policies.list_corporates(),
                 &(&1.corporate_id == attrs["ref_corporate_id"])
               ) do
            nil -> policy && policy.corporate_name
            corporate -> corporate.corporate_name
          end

        policy ->
          policy.corporate_name

        true ->
          nil
      end

    attrs
    |> Map.put_new("ref_corporate_id", policy && policy.ref_corporate_id)
    |> Map.put("corporate_name", corporate_name)
    |> Map.put("policy_number", policy && policy.policy_number)
    |> Map.put("policy_type", policy && policy.policy_type)
    |> Map.put("insurer_name", policy && policy.select_insurer)
    |> Map.put("tpa_name", policy && policy.select_tpa)
  end

  defp create_log!(claim, user_id, portal_id, action, remarks) do
    %ClaimLog{}
    |> ClaimLog.changeset(%{
      claim_id: claim.id,
      policy_id: claim.ref_policy_id,
      portal_id: portal_id,
      action: action,
      remarks: remarks,
      user_id: user_id
    })
    |> Repo.insert!()
  end

  defp stringify_keys(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp generate_reference(prefix) do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M%S")
    random = :crypto.strong_rand_bytes(3) |> Base.encode16(case: :upper)
    "#{prefix}-#{timestamp}-#{random}"
  end

  defp parse_int(value) when is_integer(value), do: value
  defp parse_int(value) when is_binary(value) and value != "", do: String.to_integer(value)
  defp parse_int(_value), do: nil

  defp positive_int(value, _default) when is_integer(value) and value > 0, do: value

  defp positive_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, ""} when parsed > 0 -> parsed
      _ -> default
    end
  end

  defp positive_int(_value, default), do: default

  defp unwrap_transaction({:ok, result}), do: {:ok, result}
  defp unwrap_transaction({:error, reason}), do: {:error, reason}

  defp format_date(nil), do: ""
  defp format_date(%Date{} = date), do: Calendar.strftime(date, "%d-%m-%Y")
  defp format_datetime(nil), do: ""
  defp format_datetime(%DateTime{} = datetime), do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp format_datetime(%NaiveDateTime{} = datetime),
    do: Calendar.strftime(datetime, "%d-%m-%Y %H:%M")

  defp csv_escape(nil), do: "\"\""
  defp csv_escape(%Decimal{} = value), do: csv_escape(Decimal.to_string(value))
  defp csv_escape(value), do: "\"#{value |> to_string() |> String.replace("\"", "\"\"")}\""

  defp is_nil_or_blank(nil), do: true
  defp is_nil_or_blank(""), do: true
  defp is_nil_or_blank(_value), do: false
end
