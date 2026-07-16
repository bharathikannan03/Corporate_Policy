defmodule CorporatePolicy.DataUploadService do
  alias CorporatePolicy.Repo

  alias CorporatePolicy.Policies.{
    MasterPolicyDataUpload,
    MasterInceptionDataUpload,
    MasterEndorsementDataUpload,
    MasterTotalClaimReport,
    MasterEcardsDataUpload
  }

  require Logger

  def process_upload(policy_id, data_type, remark, file_path, original_file_name) do
    upload_attrs = %{
      policy_id: policy_id,
      data_type: data_type,
      remark: remark,
      file_path: file_path,
      original_file_name: original_file_name,
      status: 1,
      is_dataupload: true,
      # default placeholder user id
      created_by: 1,
      updated_by: 1
    }

    Repo.transaction(fn ->
      case Repo.insert(MasterPolicyDataUpload.changeset(%MasterPolicyDataUpload{}, upload_attrs)) do
        {:ok, upload} ->
          process_file(data_type, file_path, policy_id, original_file_name)
          upload

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp process_file("Ecards", file_path, policy_id, original_file_name) do
    # For ecards, just record the uploaded PDF/ZIP as a single record for now.
    # A real implementation would parse the ZIP and create individual entries.
    Repo.insert!(%MasterEcardsDataUpload{
      ref_policy_id: policy_id,
      ecards_data_url: file_path,
      ecard_data_originalname: original_file_name,
      employee_code: extract_emp_code(original_file_name)
    })
  end

  defp process_file(data_type, file_path, policy_id, _original_file_name) do
    # For CSV types (Inception Data, Endorsement Data, Claim Dumps)
    content = File.read!(file_path)

    # Parse without headers (drop first row if it has headers, but here we just parse all and maybe skip first if we want)
    # For simplicity, we just take the parsed CSV rows. NimbleCSV.RFC4180.parse_string drops headers by default if skip_headers: true.
    rows = NimbleCSV.RFC4180.parse_string(content, skip_headers: true)

    case data_type do
      "Inception Data" -> process_inception(rows, policy_id)
      "Endorsement Data" -> process_endorsement(rows, policy_id)
      "Claim Dumps" -> process_claim_dumps(rows, policy_id)
      _ -> Logger.warning("Unknown data type #{data_type}")
    end
  end

  defp extract_emp_code(filename) do
    # basic heuristic: split by dot and take the first part
    filename |> String.split(".") |> List.first() |> String.upcase()
  end

  defp process_inception(rows, policy_id) do
    Enum.each(rows, fn row ->
      # Example row format (assuming based on DB structure):
      # [employee_code, employee_name, gender, relationship, dob, age, mobile_number, email, sum_insured, doj]
      [emp_code, emp_name, gender, rel, dob, age, mobile, email, sum_insured | rest] =
        pad_row(row, 10)

      Repo.insert!(%MasterInceptionDataUpload{
        ref_policy_id: policy_id,
        employee_code: emp_code,
        employee_name: emp_name,
        gender: gender,
        relationship: rel,
        dob: dob,
        age: parse_int(age),
        mobile_number: mobile,
        email: email,
        sum_insured: parse_float(sum_insured),
        doj: Enum.at(rest, 0)
      })
    end)
  end

  defp process_endorsement(rows, policy_id) do
    Enum.each(rows, fn row ->
      [emp_code, emp_name, gender, rel, dob, age, mobile, email, sum_insured | rest] =
        pad_row(row, 10)

      Repo.insert!(%MasterEndorsementDataUpload{
        ref_policy_id: policy_id,
        employee_code: emp_code,
        employee_name: emp_name,
        gender: gender,
        relationship: rel,
        dob: dob,
        age: age,
        mobile_number: mobile,
        email: email,
        sum_insured: sum_insured,
        doj: Enum.at(rest, 0)
      })
    end)
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
        employee_code: emp_code,
        employee_name: emp_name,
        patient_name: patient_name,
        relationship: rel,
        claim_type: claim_type,
        tpa_claim_no: tpa_no,
        date_of_hospitalization: date_hosp,
        date_of_discharge: date_dis,
        hospital_name: hosp_name,
        amount_claimed: parse_float(claimed),
        amount_sanctioned: parse_float(sanctioned)
      })
    end)
  end

  defp pad_row(row, min_length) do
    len = length(row)

    if len < min_length do
      row ++ List.duplicate("", min_length - len)
    else
      row
    end
  end

  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {num, _} -> num
      :error -> nil
    end
  end

  defp parse_float(val) do
    case Float.parse(to_string(val)) do
      {num, _} -> num
      :error -> nil
    end
  end
end
