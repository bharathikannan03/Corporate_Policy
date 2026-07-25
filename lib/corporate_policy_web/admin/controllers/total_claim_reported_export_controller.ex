defmodule CorporatePolicyWeb.Admin.TotalClaimReportedExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Policies

  def export(conn, _params) do
    claims = Policies.list_total_claim_reports_for_export()
    csv = to_csv(claims)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=total-claim-reported.csv")
    |> send_resp(200, csv)
  end

  defp to_csv(claims) do
    header = [
      "Employee Code",
      "Employee Name",
      "Patient Name",
      "Relationship",
      "Claim Type",
      "TPA Claim No",
      "Insurance Claim No",
      "Claim Status",
      "Claim Sub Status",
      "Date of Hospitalization",
      "Date of Discharge",
      "Hospital Name",
      "Hospital State",
      "City",
      "Network Status",
      "Treatment Type",
      "Level of Care",
      "Amount Claimed",
      "Amount Sanctioned",
      "Claim Paid Amount",
      "Sum Insured",
      "TDS Amount",
      "Deduction Amount",
      "Deduction Reason",
      "Patient Gender",
      "Age",
      "Cause",
      "Disease Category",
      "ICD Code",
      "Intimation Method",
      "Claim Registered Date",
      "Claim File Submitted Date",
      "Claim Settled Date",
      "Deficiency Reason",
      "Close Reasons"
    ]

    rows =
      Enum.map(claims, fn c ->
        [
          c.employee_code,
          c.employee_name,
          c.patient_name,
          c.relationship,
          c.claim_type,
          c.tpa_claim_no,
          c.insurance_claim_no,
          c.claim_status,
          c.claim_sub_status,
          c.date_of_hospitalization,
          c.date_of_discharge,
          c.hospital_name,
          c.hospital_state,
          c.city,
          c.network_status,
          c.treatment_type,
          c.level_of_care,
          c.amount_claimed,
          c.amount_sanctioned,
          c.claim_paid_amount,
          c.sum_insured,
          c.tds_amount,
          c.deduction_amount,
          c.deduction_reason,
          c.patient_gender,
          c.age,
          c.cause,
          c.disease_category,
          c.icd_code,
          c.intimation_method,
          c.claim_registered_date,
          c.claim_file_submitted_dt,
          c.claim_settled_date,
          c.deficiency_reason,
          c.close_reasons
        ]
      end)

    Enum.map_join([header | rows], "\n", fn row ->
      Enum.map_join(row, ",", &csv_escape/1)
    end)
  end

  defp csv_escape(nil), do: ""
  defp csv_escape(val) when is_float(val), do: to_string(val)
  defp csv_escape(val) when is_integer(val), do: to_string(val)

  defp csv_escape(val) do
    str = to_string(val)

    if String.contains?(str, [",", "\"", "\n"]) do
      "\"#{String.replace(str, "\"", "\"\"")}\""
    else
      str
    end
  end
end
