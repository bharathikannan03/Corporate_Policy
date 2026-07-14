defmodule CorporatePolicyWeb.CorporateExportController do
  use CorporatePolicyWeb, :controller

  alias CorporatePolicy.Corporates

  def export(conn, params) do
    status_filter = Map.get(params, "status", "all")

    corporates =
      case status_filter do
        "active" -> Corporates.list_corporates_by_status(1)
        "inactive" -> Corporates.list_corporates_by_status(0)
        _ -> Corporates.list_corporates()
      end

    csv_data = generate_csv(corporates)

    conn
    |> put_resp_content_type("text/csv")
    |> send_download({:binary, csv_data}, filename: "corporates_#{status_filter}.csv")
  end

  defp generate_csv(corporates) do
    headers = [
      "SI NO",
      "Corporate Name",
      "Group Code",
      "City",
      "State",
      "PAN Number",
      "Pincode",
      "Address",
      "Landline",
      "Email",
      "Status"
    ]

    rows =
      Enum.with_index(corporates, 1)
      |> Enum.map(fn {corp, index} ->
        status_text = if corp.corporate_status == 1, do: "Active", else: "Inactive"

        [
          index,
          corp.corporate_name,
          corp.corporate_group_code,
          corp.city,
          corp.state,
          corp.pan_number,
          corp.pincode,
          corp.corporate_address,
          corp.corporate_landline,
          corp.coporate_contact_email,
          status_text
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
