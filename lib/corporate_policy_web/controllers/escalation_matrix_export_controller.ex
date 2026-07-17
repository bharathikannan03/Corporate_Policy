defmodule CorporatePolicyWeb.EscalationMatrixExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.EscalationMatrices

  def export(conn, _params) do
    records = EscalationMatrices.list_escalation_matrices()
    csv_data = generate_csv(records)

    conn
    |> put_resp_content_type("text/csv")
    |> send_download({:binary, csv_data}, filename: "escalation_matrix_users.csv")
  end

  defp generate_csv(records) do
    headers = [
      "SI NO",
      "Full Name",
      "Phone Number",
      "Mobile Number",
      "Email",
      "Alt Email",
      "Address",
      "Type",
      "Status",
      "Created At"
    ]

    rows =
      Enum.with_index(records, 1)
      |> Enum.map(fn {rec, index} ->
        status_text = if rec.status == 1, do: "Active", else: "Inactive"

        created_at_text =
          case rec.created_at do
            nil -> ""
            dt -> Calendar.strftime(dt, "%d-%m-%Y")
          end

        [
          index,
          rec.fullname,
          rec.phone_number,
          rec.mobile_number,
          rec.email_id,
          rec.alt_email_id,
          rec.company_fulladdress,
          rec.type,
          status_text,
          created_at_text
        ]
        |> Enum.map(&escape_csv_field/1)
        |> Enum.join(",")
      end)

    ([Enum.join(headers, ",")] ++ rows)
    |> Enum.join("\r\n")
  end

  defp escape_csv_field(nil), do: ""

  defp escape_csv_field(value) do
    str = to_string(value)

    if String.contains?(str, [",", "\"", "\n", "\r"]) do
      "\"" <> String.replace(str, "\"", "\"\"") <> "\""
    else
      str
    end
  end
end
