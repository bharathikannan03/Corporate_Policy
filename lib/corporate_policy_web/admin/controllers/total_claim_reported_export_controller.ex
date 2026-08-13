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
      "Claim No",
      "Intimation No",
      "Policy Number",
      "Employee Code",
      "Employee Name",
      "Patient Name",
      "Relationship",
      "Claim Type",
      "Claim Status",
      "Insurer",
      "TPA",
      "Hospital Name",
      "Hospital Address",
      "City",
      "State",
      "Pincode",
      "Hospitalization Date",
      "Discharge Date",
      "Estimated Amount",
      "Claim Reason",
      "Treatment Details",
      "Remarks",
      "Submitted At"
    ]

    rows =
      Enum.map(claims, fn c ->
        [
          c.claim_number,
          c.intimation_number,
          if(c.policy, do: c.policy.policy_number, else: nil),
          c.employee_code,
          c.employee_name,
          c.patient_name,
          c.relationship,
          c.claim_type,
          c.claim_status,
          c.insurer_name,
          c.tpa_name,
          c.hospital_name,
          c.hospital_address,
          c.city,
          c.state,
          c.pincode,
          c.hospitalization_date,
          c.discharge_date,
          c.estimated_amount,
          c.claim_reason,
          c.treatment_details,
          c.remarks,
          c.submitted_at
        ]
      end)

    Enum.map_join([header | rows], "\n", fn row ->
      Enum.map_join(row, ",", &csv_escape/1)
    end)
  end

  defp csv_escape(nil), do: ""
  defp csv_escape(%Decimal{} = val), do: Decimal.to_string(val)
  defp csv_escape(val) when is_float(val), do: to_string(val)
  defp csv_escape(val) when is_integer(val), do: to_string(val)
  defp csv_escape(%DateTime{} = val), do: Calendar.strftime(val, "%d-%m-%Y %H:%M")
  defp csv_escape(%Date{} = val), do: Calendar.strftime(val, "%d-%m-%Y")

  defp csv_escape(val) do
    str = to_string(val)

    if String.contains?(str, [",", "\"", "\n"]) do
      "\"#{String.replace(str, "\"", "\"\"")}\""
    else
      str
    end
  end
end
