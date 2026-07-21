defmodule CorporatePolicy.DataUploadService do
  alias CorporatePolicy.Repo

  alias CorporatePolicy.Policies.{
    MasterPolicyDataUpload,
    MasterInceptionDataUpload,
    MasterEndorsementDataUpload,
    MasterTotalClaimReport,
    MasterEcardsDataUpload,
    TrnMappingLiveEmployee,
    TrnEndorsementDeletionLog
  }

  require Logger

  @supported_endorsement_types ~w(
    employee_addition
    dependent_addition
    employee_deletion
    dependent_deletion
  )

  def process_upload(policy_id, data_type, remark, file_path, original_file_name, user_id \\ nil) do
    effective_user_id =
      user_id ||
        case Repo.get(CorporatePolicy.Policies.Policy, policy_id) do
          %{created_by: cid} when not is_nil(cid) -> cid
          _ -> nil
        end

    upload_attrs = %{
      policy_id: policy_id,
      data_type: data_type,
      remark: remark,
      file_path: file_path,
      original_file_name: original_file_name,
      status: 1,
      is_dataupload: true,
      created_by: effective_user_id,
      updated_by: effective_user_id
    }

    Repo.transaction(fn ->
      case Repo.insert(MasterPolicyDataUpload.changeset(%MasterPolicyDataUpload{}, upload_attrs)) do
        {:ok, upload} ->
          process_file(
            data_type,
            file_path,
            policy_id,
            original_file_name,
            effective_user_id,
            upload.id
          )

          upload

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp process_file("Ecards", file_path, policy_id, original_file_name, _user_id, _upload_id) do
    Repo.insert!(%MasterEcardsDataUpload{
      ref_policy_id: policy_id,
      ecards_data_url: file_path,
      ecard_data_originalname: original_file_name,
      employee_code: extract_emp_code(original_file_name)
    })
  end

  defp process_file(data_type, file_path, policy_id, _original_file_name, user_id, upload_id) do
    content = File.read!(file_path) |> sanitize_utf8()
    rows = NimbleCSV.RFC4180.parse_string(content, skip_headers: true)

    case data_type do
      "Inception Data" -> process_inception(rows, policy_id, user_id)
      "Endorsement Data" -> process_endorsement(rows, policy_id, user_id, upload_id)
      "Claim Dumps" -> process_claim_dumps(rows, policy_id)
      _ -> Logger.warning("Unknown data type #{data_type}")
    end
  end

  defp extract_emp_code(filename) do
    filename |> String.split(".") |> List.first() |> String.upcase()
  end

  defp process_inception(rows, policy_id, user_id) do
    Enum.each(rows, fn row ->
      [emp_code, emp_name, gender, rel, dob, age, mobile, email, sum_insured | rest] =
        pad_row(row, 10)

      code = clean_string(emp_code)

      if code != "" do
        Repo.insert!(%MasterInceptionDataUpload{
          ref_policy_id: policy_id,
          employee_code: code,
          employee_name: clean_string(emp_name),
          gender: clean_string(gender),
          relationship: normalize_relationship(rel, code),
          dob: clean_string(dob),
          age: parse_int(age),
          mobile_number: clean_string(mobile),
          email: clean_string(email),
          sum_insured: parse_float(sum_insured),
          doj: clean_string(Enum.at(rest, 0))
        })
      end
    end)

    save_trn_mapping_live_employees(rows, policy_id, "Inception", user_id)
  end

  defp process_endorsement(rows, policy_id, user_id, upload_id) do
    Enum.each(rows, fn row ->
      padded = pad_row(row, 16)

      emp_code = Enum.at(padded, 0) |> clean_string()
      emp_name = Enum.at(padded, 1) |> clean_string()
      gender = Enum.at(padded, 2) |> clean_string()
      rel = Enum.at(padded, 3) |> clean_string()
      dob = Enum.at(padded, 4) |> clean_string()
      age = Enum.at(padded, 5) |> clean_string()
      mobile = Enum.at(padded, 6) |> clean_string()
      email = Enum.at(padded, 7) |> clean_string()
      sum_insured = Enum.at(padded, 8) |> clean_string()
      doj = Enum.at(padded, 9) |> clean_string()
      end_no = Enum.at(padded, 10) |> clean_string()
      end_date = Enum.at(padded, 11) |> clean_string()
      end_type = Enum.at(padded, 12) |> clean_string()
      dol = Enum.at(padded, 13) |> clean_string()
      card_no = Enum.at(padded, 14) |> clean_string()
      designation = Enum.at(padded, 15) |> clean_string()

      if emp_code != "" do
        normalized_endorsement_type = normalize_endorsement_type!(end_type)

        Repo.insert!(%MasterEndorsementDataUpload{
          ref_policy_id: policy_id,
          employee_code: emp_code,
          employee_name: emp_name,
          gender: gender,
          relationship: normalize_relationship(rel, emp_code),
          dob: dob,
          age: age,
          mobile_number: mobile,
          email: email,
          sum_insured: sum_insured,
          doj: doj,
          endorsement_number: end_no,
          endorsement_date: end_date,
          endorsement_type: normalized_endorsement_type,
          dol: dol,
          member_card_number: card_no,
          designation: designation
        })
      end
    end)

    save_trn_mapping_live_employees(rows, policy_id, "Endorsement", user_id, upload_id)
  end

  defp process_claim_dumps(rows, policy_id) do
    Enum.each(rows, fn row ->
      [
        emp_code,
        emp_name,
        patient_name,
        rel,
        claim_type,
        tpa_no,
        date_hosp,
        date_dis,
        hosp_name,
        claimed,
        sanctioned | _
      ] = pad_row(row, 15)

      Repo.insert!(%MasterTotalClaimReport{
        ref_policy_id: policy_id,
        employee_code: clean_string(emp_code),
        employee_name: clean_string(emp_name),
        patient_name: clean_string(patient_name),
        relationship: clean_string(rel),
        claim_type: clean_string(claim_type),
        tpa_claim_no: clean_string(tpa_no),
        date_of_hospitalization: clean_string(date_hosp),
        date_of_discharge: clean_string(date_dis),
        hospital_name: clean_string(hosp_name),
        amount_claimed: parse_float(claimed),
        amount_sanctioned: parse_float(sanctioned)
      })
    end)
  end

  defp save_trn_mapping_live_employees(rows, policy_id, source_type, user_id, upload_id \\ nil) do
    now_naive = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    now_utc = DateTime.utc_now() |> DateTime.truncate(:second)

    policy = Repo.get(CorporatePolicy.Policies.Policy, policy_id)
    corporate_id = policy && policy.ref_corporate_id
    effective_user = user_id || (policy && policy.created_by) || 1

    Enum.each(rows, fn row ->
      padded = pad_row(row, 16)

      emp_code = Enum.at(padded, 0) |> clean_string()
      emp_name = Enum.at(padded, 1) |> clean_string()
      gender = Enum.at(padded, 2) |> clean_string()
      rel = Enum.at(padded, 3) |> clean_string()
      dob = Enum.at(padded, 4) |> clean_string()
      age = Enum.at(padded, 5)
      mobile = Enum.at(padded, 6) |> clean_string()
      email = Enum.at(padded, 7) |> clean_string()
      sum_insured = Enum.at(padded, 8)
      doj = Enum.at(padded, 9) |> clean_string()
      end_no = Enum.at(padded, 10) |> clean_string()
      end_date = Enum.at(padded, 11) |> clean_string()
      end_type = Enum.at(padded, 12) |> clean_string()
      dol = Enum.at(padded, 13) |> clean_string()
      card_no = Enum.at(padded, 14) |> clean_string()
      designation = Enum.at(padded, 15) |> clean_string()

      if emp_code != "" do
        relationship_value = normalize_relationship(rel, emp_code)

        normalized_endorsement_type =
          if source_type == "Endorsement", do: normalize_endorsement_type!(end_type), else: nil

        if source_type == "Endorsement" and deletion_type?(normalized_endorsement_type) do
          if String.downcase(relationship_value) in ["employee", "self"] do
            raise "Invalid data: Deletion requested for primary employee (Employee Code: #{emp_code}). Upload aborted."
          end

          deactivate_inception_member(policy_id, emp_code, relationship_value, now_utc)
          deactivate_live_member(policy_id, emp_code, relationship_value, now_utc)

          Repo.insert!(%TrnEndorsementDeletionLog{
            ref_policy_id: policy_id,
            ref_corporate_id: corporate_id,
            upload_id: upload_id,
            employee_code: emp_code,
            employee_name: emp_name,
            relationship: relationship_value,
            endorsement_number: end_no,
            endorsement_date: end_date,
            endorsement_type: normalized_endorsement_type,
            deletion_category: deletion_category(normalized_endorsement_type),
            action: deletion_action(normalized_endorsement_type),
            deleted_at: now_utc,
            created_by: effective_user,
            updated_by: effective_user
          })
        else
          # Standard Addition / Upsert
          attrs = %{
            ref_policy_id: policy_id,
            ref_corporate_id: corporate_id,
            employee_code: emp_code,
            employee_name: emp_name,
            gender: gender,
            relationship: relationship_value,
            dob: dob,
            age: parse_int(age),
            mobile_number: mobile,
            email: email,
            sum_insured: parse_float(sum_insured),
            doj: doj,
            endorsement_number: end_no,
            endorsement_date: end_date,
            endorsement_type: normalized_endorsement_type,
            dol: dol,
            member_card_number: card_no,
            designation: designation,
            status: "active",
            source_type: source_type,
            created_by: effective_user,
            updated_by: effective_user,
            inserted_at: now_naive,
            updated_at: now_naive,
            deleted_at: nil
          }

          Repo.insert!(
            struct(TrnMappingLiveEmployee, attrs),
            on_conflict: {:replace_all_except, [:id, :inserted_at, :created_by]},
            conflict_target: [:ref_policy_id, :employee_code, :relationship]
          )
        end
      end
    end)
  end

  defp deletion_type?(end_type) when is_binary(end_type),
    do: end_type in ["employee_deletion", "dependent_deletion"]

  defp deletion_type?(_), do: false

  defp normalize_endorsement_type!(endorsement_type) do
    cleaned =
      endorsement_type
      |> clean_string()
      |> String.downcase()
      |> String.replace(~r/[\s-]+/, "_")

    normalized =
      case cleaned do
        "addition" -> "employee_addition"
        "add" -> "employee_addition"
        "emp_addition" -> "employee_addition"
        "employee_addition" -> "employee_addition"
        "dependent_addition" -> "dependent_addition"
        "dependant_addition" -> "dependent_addition"
        "dep_addition" -> "dependent_addition"
        "deletion" -> "employee_deletion"
        "del" -> "employee_deletion"
        "emp_deletion" -> "employee_deletion"
        "employee_deletion" -> "employee_deletion"
        "dependent_deletion" -> "dependent_deletion"
        "dependant_deletion" -> "dependent_deletion"
        "dep_deletion" -> "dependent_deletion"
        other -> other
      end

    if normalized in @supported_endorsement_types do
      normalized
    else
      raise "Invalid endorsement_type. Only employee_addition, dependent_addition, employee_deletion, and dependent_deletion are supported."
    end
  end

  defp deactivate_inception_member(policy_id, employee_code, relationship, now_utc) do
    case Repo.get_by(MasterInceptionDataUpload,
           ref_policy_id: policy_id,
           employee_code: employee_code,
           relationship: relationship
         ) do
      nil ->
        :ok

      member ->
        member
        |> Ecto.Changeset.change(status: "inactive", deleted_at: now_utc)
        |> Repo.update!()
    end
  end

  defp deactivate_live_member(policy_id, employee_code, relationship, now_utc) do
    case Repo.get_by(TrnMappingLiveEmployee,
           ref_policy_id: policy_id,
           employee_code: employee_code,
           relationship: relationship
         ) do
      nil ->
        :ok

      member ->
        member
        |> Ecto.Changeset.change(status: "inactive", deleted_at: now_utc)
        |> Repo.update!()
    end
  end

  defp deletion_category("employee_deletion"), do: "Employee Deletion"
  defp deletion_category("dependent_deletion"), do: "Dependant Deletion"

  defp deletion_action("employee_deletion"), do: "employee_deletion"
  defp deletion_action("dependent_deletion"), do: "dependent_deletion"

  defp clean_string(nil), do: ""

  defp clean_string(val) when is_binary(val) do
    val
    |> sanitize_utf8()
    |> String.replace(~r/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\xA0]/, " ")
    |> String.replace("\u00A0", " ")
    |> String.trim()
  end

  defp clean_string(val) do
    to_string(val)
    |> clean_string()
  end

  defp sanitize_utf8(binary) when is_binary(binary) do
    if String.valid?(binary) do
      binary
      |> String.replace(<<160>>, " ")
      |> String.replace("\u00A0", " ")
    else
      case :unicode.characters_to_binary(binary, :latin1, :utf8) do
        utf8 when is_binary(utf8) ->
          utf8
          |> String.replace(<<160>>, " ")
          |> String.replace("\u00A0", " ")

        _ ->
          binary
          |> :binary.bin_to_list()
          |> Enum.filter(&(&1 in 32..126 or &1 in [9, 10, 13]))
          |> List.to_string()
      end
    end
  end

  defp pad_row(row, min_length) do
    len = length(row)

    if len < min_length do
      row ++ List.duplicate("", min_length - len)
    else
      row
    end
  end

  defp parse_int(nil), do: nil

  defp parse_int(val) do
    case Integer.parse(clean_string(val)) do
      {num, _} -> num
      :error -> nil
    end
  end

  defp parse_float(nil), do: nil

  defp parse_float(val) do
    str = clean_string(val)

    case Float.parse(str) do
      {num, _} ->
        num

      :error ->
        case Integer.parse(str) do
          {num, _} -> num / 1.0
          :error -> nil
        end
    end
  end

  defp normalize_relationship(rel, emp_code) do
    cleaned = clean_string(rel)

    cond do
      cleaned == "" ->
        raise "Invalid data: Relationship is missing for record (Employee Code: #{emp_code}). Upload aborted."

      String.downcase(cleaned) in ["self", "employee"] ->
        "Employee"

      true ->
        cleaned
    end
  end
end
